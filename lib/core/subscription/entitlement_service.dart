import 'package:auvie/core/subscription/entitlement.dart';

/// Where Pro is bought and checked (spec §49). The UI depends only on this;
/// `RevenueCatEntitlementService` is the store, the simulated one stands in
/// until the store accounts exist, and tests use a fake.
abstract interface class EntitlementService {
  /// False when Pro can't be bought in this build (no store configured).
  bool get available;

  /// True for the stand-in used before the store is set up.
  bool get simulated;

  /// The last known state; cached, so it is right offline and at startup.
  Entitlement get current;

  /// Every change of [current] (purchases, renewals, expirations).
  Stream<Entitlement> get changes;

  /// Connects to the store and refreshes [current]. Safe to call again.
  Future<void> start();

  /// The plans to offer, yearly first. Empty when none can be bought.
  Future<List<ProPlan>> plans();

  Future<PurchaseOutcome> purchase(ProPlan plan);

  /// Looks for Pro bought earlier with this store account.
  Future<Entitlement> restore();

  /// Where the subscription is managed or cancelled.
  Uri get manageUrl;

  /// Simulated only: back to free.
  Future<void> resetSimulation();
}

/// Google Play's subscriptions page.
final Uri playSubscriptionsUrl = Uri.parse(
  'https://play.google.com/store/account/subscriptions',
);
