import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/subscription/entitlement.dart';
import 'package:auvie/core/subscription/revenuecat_entitlement_service.dart';
import 'package:auvie/core/subscription/simulated_entitlement_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RevenueCat mapping', () {
    EntitlementInfo info({
      bool active = true,
      String product = 'auvie_pro_yearly',
      PeriodType period = PeriodType.normal,
      String? expires = '2027-10-12T10:00:00Z',
    }) => EntitlementInfo(
      'pro',
      active,
      true,
      '2026-10-12T10:00:00Z',
      '2026-10-12T10:00:00Z',
      product,
      false,
      periodType: period,
      expirationDate: expires,
    );

    test('an active pro entitlement is Pro', () {
      expect(
        entitlementFromInfo(info()),
        Entitlement(
          isPro: true,
          period: ProPeriod.yearly,
          expiresAt: DateTime.utc(2027, 10, 12, 10),
        ),
      );
      expect(
        entitlementFromInfo(info(product: 'auvie_pro_monthly')).period,
        ProPeriod.monthly,
      );
      expect(
        entitlementFromInfo(info(period: PeriodType.trial)).inTrial,
        isTrue,
      );
    });

    test('no entitlement, or an inactive one, is free', () {
      expect(entitlementFromInfo(null), Entitlement.free);
      expect(entitlementFromInfo(info(active: false)), Entitlement.free);
    });

    Package package(PackageType type, {SubscriptionOption? option}) => Package(
      type == PackageType.annual ? r'$rc_annual' : r'$rc_monthly',
      type,
      StoreProduct(
        'auvie_pro',
        'Auvie Pro',
        'Auvie Pro',
        type == PackageType.annual ? 39.99 : 5.99,
        type == PackageType.annual ? r'$39.99' : r'$5.99',
        'USD',
        defaultOption: option,
        pricePerMonthString: type == PackageType.annual ? r'$3.33' : r'$5.99',
      ),
      const PresentedOfferingContext('default', null, null),
    );

    const week = Period(PeriodUnit.week, 1, 'P1W');
    const trial = SubscriptionOption(
      'trial',
      'auvie_pro:yearly',
      'auvie_pro',
      [],
      [],
      false,
      null,
      false,
      null,
      PricingPhase(week, null, 1, Price('Free', 0, 'USD'), null),
      null,
      null,
      null,
    );

    test('packages become plans', () {
      expect(
        planFromPackage(package(PackageType.annual, option: trial)),
        const ProPlan(
          id: r'$rc_annual',
          period: ProPeriod.yearly,
          price: r'$39.99',
          amount: 39.99,
          pricePerMonth: r'$3.33',
          trialDays: 7,
        ),
      );
      final monthly = planFromPackage(package(PackageType.monthly))!;
      expect(monthly.period, ProPeriod.monthly);
      expect(monthly.pricePerMonth, isNull);
      expect(monthly.trialDays, isNull);
      expect(planFromPackage(package(PackageType.lifetime)), isNull);
    });

    test('trial lengths in days', () {
      expect(trialDays(const Period(PeriodUnit.day, 3, 'P3D')), 3);
      expect(trialDays(const Period(PeriodUnit.week, 2, 'P2W')), 14);
      expect(trialDays(const Period(PeriodUnit.month, 1, 'P1M')), 30);
    });
  });

  group('simulated store', () {
    late AppSettings settings;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      settings = AppSettings(await SharedPreferences.getInstance());
    });

    test('buying turns Pro on and is remembered', () async {
      final store = SimulatedEntitlementService(settings, delay: Duration.zero);
      expect(store.current.isPro, isFalse);
      final changes = <Entitlement>[];
      store.changes.listen(changes.add);

      final outcome = await store.purchase(SimulatedEntitlementService.yearly);

      expect(outcome, isA<PurchaseDone>());
      expect(store.current.isPro, isTrue);
      expect(store.current.inTrial, isTrue);
      expect(changes.single.isPro, isTrue);
      final again = SimulatedEntitlementService(settings, delay: Duration.zero);
      expect((await again.restore()).isPro, isTrue);
      expect(cachedEntitlement(settings).isPro, isTrue);
    });

    test('back to free', () async {
      final store = SimulatedEntitlementService(settings, delay: Duration.zero);
      await store.purchase(SimulatedEntitlementService.monthly);
      await store.resetSimulation();
      expect(store.current, Entitlement.free);
      expect(
        SimulatedEntitlementService(settings, delay: Duration.zero).current,
        Entitlement.free,
      );
    });

    test('offers yearly first, saving against monthly', () async {
      final plans = await SimulatedEntitlementService(settings).plans();
      expect(plans.map((p) => p.period), [ProPeriod.yearly, ProPeriod.monthly]);
    });
  });

  test('the unavailable store sells nothing', () async {
    SharedPreferences.setMockInitialValues({});
    final store = UnavailableEntitlementService(
      AppSettings(await SharedPreferences.getInstance()),
    );
    expect(store.available, isFalse);
    expect(await store.plans(), isEmpty);
    expect(
      await store.purchase(SimulatedEntitlementService.yearly),
      isA<PurchaseFailed>(),
    );
  });
}
