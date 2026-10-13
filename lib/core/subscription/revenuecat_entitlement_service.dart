import 'dart:async';
import 'dart:convert';

import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/subscription/entitlement.dart';
import 'package:auvie/core/subscription/entitlement_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// The RevenueCat entitlement that unlocks Pro (spec §49).
const proEntitlementId = 'pro';

/// Pro through RevenueCat and Google Play (docs/REVENUECAT-SETUP.md).
class RevenueCatEntitlementService implements EntitlementService {
  new(this._apiKey, this._settings) : _current = cachedEntitlement(_settings);

  final String _apiKey;
  final AppSettings _settings;
  final _changes = StreamController<Entitlement>.broadcast();
  Entitlement _current;
  bool _configured = false;
  Uri? _manageUrl;
  final _packages = <String, Package>{};

  @override
  bool get available => true;

  @override
  bool get simulated => false;

  @override
  Entitlement get current => _current;

  @override
  Stream<Entitlement> get changes => _changes.stream;

  @override
  Uri get manageUrl => _manageUrl ?? playSubscriptionsUrl;

  @override
  Future<void> start() async {
    if (!_configured) {
      await Purchases.configure(PurchasesConfiguration(_apiKey));
      Purchases.addCustomerInfoUpdateListener(_update);
      _configured = true;
    }
    try {
      _update(await Purchases.getCustomerInfo());
    } on PlatformException catch (e) {
      // Offline: keep the cached state.
      debugPrint('RevenueCat customer info: ${e.message}');
    }
  }

  @override
  Future<List<ProPlan>> plans() async {
    await start();
    final offering = (await Purchases.getOfferings()).current;
    if (offering == null) return const [];
    _packages.clear();
    final plans = <ProPlan>[];
    for (final package in [offering.annual, offering.monthly].nonNulls) {
      final plan = planFromPackage(package);
      if (plan == null) continue;
      _packages[plan.id] = package;
      plans.add(plan);
    }
    return plans;
  }

  @override
  Future<PurchaseOutcome> purchase(ProPlan plan) async {
    final package = _packages[plan.id];
    if (package == null) return const PurchaseFailed('That plan is gone.');
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _update(result.customerInfo);
      return _current.isPro
          ? PurchaseDone(_current)
          : const PurchaseFailed("The store didn't confirm Pro.");
    } on PlatformException catch (e) {
      return switch (PurchasesErrorHelper.getErrorCode(e)) {
        PurchasesErrorCode.purchaseCancelledError => const PurchaseCancelled(),
        PurchasesErrorCode.paymentPendingError => const PurchasePending(),
        PurchasesErrorCode.productAlreadyPurchasedError => PurchaseDone(
          await restore(),
        ),
        _ => PurchaseFailed(e.message),
      };
    }
  }

  @override
  Future<Entitlement> restore() async {
    await start();
    _update(await Purchases.restorePurchases());
    return _current;
  }

  @override
  Future<void> resetSimulation() async {}

  void _update(CustomerInfo info) {
    final url = info.managementURL;
    if (url != null) _manageUrl = Uri.tryParse(url);
    final next = entitlementFromInfo(
      info.entitlements.active[proEntitlementId],
    );
    if (next == _current) return;
    _current = next;
    _changes.add(next);
    unawaited(_settings.saveEntitlementCache(jsonEncode(next.toJson())));
  }
}

/// The last state saved by any [EntitlementService]; free if none.
Entitlement cachedEntitlement(AppSettings settings) {
  final json = settings.entitlementCache;
  if (json == null) return Entitlement.free;
  try {
    return Entitlement.fromJson(jsonDecode(json) as Map<String, dynamic>);
  } on Object {
    return Entitlement.free;
  }
}

/// [info] is the active `pro` entitlement, if any.
@visibleForTesting
Entitlement entitlementFromInfo(EntitlementInfo? info) {
  if (info == null || !info.isActive) return Entitlement.free;
  final product =
      '${info.productIdentifier} ${info.productPlanIdentifier ?? ''}'
          .toLowerCase();
  return Entitlement(
    isPro: true,
    period: product.contains('year') || product.contains('annual')
        ? ProPeriod.yearly
        : product.contains('month')
        ? ProPeriod.monthly
        : null,
    expiresAt: DateTime.tryParse(info.expirationDate ?? ''),
    inTrial: info.periodType == PeriodType.trial,
  );
}

/// A yearly or monthly package as a plan; null for other packages.
@visibleForTesting
ProPlan? planFromPackage(Package package) {
  final period = switch (package.packageType) {
    PackageType.annual => ProPeriod.yearly,
    PackageType.monthly => ProPeriod.monthly,
    _ => null,
  };
  if (period == null) return null;
  final product = package.storeProduct;
  final trial = product.defaultOption?.freePhase?.billingPeriod;
  return ProPlan(
    id: package.identifier,
    period: period,
    price: product.priceString,
    amount: product.price,
    pricePerMonth: period == ProPeriod.yearly
        ? product.pricePerMonthString
        : null,
    trialDays: trial == null ? null : trialDays(trial),
  );
}

/// A store period in days (months as 30).
@visibleForTesting
int trialDays(Period period) => switch (period.unit) {
  PeriodUnit.day => period.value,
  PeriodUnit.week => period.value * 7,
  PeriodUnit.month => period.value * 30,
  PeriodUnit.year => period.value * 365,
  PeriodUnit.unknown => 0,
};
