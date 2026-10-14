import 'dart:async';
import 'dart:convert';

import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/subscription/entitlement.dart';
import 'package:auvie/core/subscription/entitlement_service.dart';
import 'package:auvie/core/subscription/revenuecat_entitlement_service.dart';

/// Stands in for the store before the RevenueCat and Play Console accounts
/// exist (debug and profile builds only): the design's sample prices, and
/// "buying" just turns Pro on, remembered across restarts.
class SimulatedEntitlementService implements EntitlementService {
  new(this._settings, {this.delay = const Duration(milliseconds: 600)})
    : _current = _load(_settings);

  final AppSettings _settings;

  /// Pause before a purchase or restore answers, like a store would.
  final Duration delay;
  final _changes = StreamController<Entitlement>.broadcast();
  Entitlement _current;

  static const yearly = ProPlan(
    id: 'simulated_yearly',
    period: ProPeriod.yearly,
    price: r'$39.99',
    amount: 39.99,
    pricePerMonth: r'$3.33',
    trialDays: 7,
  );

  static const monthly = ProPlan(
    id: 'simulated_monthly',
    period: ProPeriod.monthly,
    price: r'$5.99',
    amount: 5.99,
  );

  static Entitlement _load(AppSettings settings) {
    final json = settings.simulatedEntitlement;
    if (json == null) return Entitlement.free;
    return Entitlement.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  bool get available => true;

  @override
  bool get simulated => true;

  @override
  Entitlement get current => _current;

  @override
  Stream<Entitlement> get changes => _changes.stream;

  @override
  Uri get manageUrl => playSubscriptionsUrl;

  @override
  Future<void> start() async {}

  @override
  Future<List<ProPlan>> plans() async => const [yearly, monthly];

  @override
  Future<PurchaseOutcome> purchase(ProPlan plan) async {
    await Future<void>.delayed(delay);
    final days = plan.trialDays ?? 0;
    await _set(
      Entitlement(
        isPro: true,
        period: plan.period,
        inTrial: days > 0,
        expiresAt: DateTime.now().add(
          Duration(
            days: days > 0
                ? days
                : plan.period == ProPeriod.yearly
                ? 365
                : 30,
          ),
        ),
      ),
    );
    return PurchaseDone(_current);
  }

  @override
  Future<Entitlement> restore() async {
    await Future<void>.delayed(delay);
    return _current;
  }

  @override
  Future<void> paywallShown() async {}

  @override
  Future<void> resetSimulation() => _set(Entitlement.free);

  Future<void> _set(Entitlement next) async {
    _current = next;
    _changes.add(next);
    final json = jsonEncode(next.toJson());
    await _settings.saveSimulatedEntitlement(next.isPro ? json : null);
    await _settings.saveEntitlementCache(json);
  }
}

/// Release builds without a store key: Pro can't be bought yet.
class UnavailableEntitlementService implements EntitlementService {
  new(AppSettings settings) : current = cachedEntitlement(settings);

  @override
  bool get available => false;

  @override
  bool get simulated => false;

  @override
  final Entitlement current;

  @override
  Stream<Entitlement> get changes => const Stream.empty();

  @override
  Uri get manageUrl => playSubscriptionsUrl;

  @override
  Future<void> start() async {}

  @override
  Future<List<ProPlan>> plans() async => const [];

  @override
  Future<PurchaseOutcome> purchase(ProPlan plan) async =>
      const PurchaseFailed("Pro isn't available yet.");

  @override
  Future<Entitlement> restore() async => current;

  @override
  Future<void> paywallShown() async {}

  @override
  Future<void> resetSimulation() async {}
}
