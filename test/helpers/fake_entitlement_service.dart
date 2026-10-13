import 'dart:async';

import 'package:auvie/core/platform/link_opener.dart';
import 'package:auvie/core/subscription/entitlement.dart';
import 'package:auvie/core/subscription/entitlement_service.dart';

/// A store whose plans and answers the test decides.
class FakeEntitlementService implements EntitlementService {
  new({bool pro = false, this.available = true})
    : _current = pro ? proYearly : Entitlement.free;

  static const proYearly = Entitlement(isPro: true, period: ProPeriod.yearly);

  static const yearly = ProPlan(
    id: 'yearly',
    period: ProPeriod.yearly,
    price: r'$39.99',
    amount: 39.99,
    pricePerMonth: r'$3.33',
    trialDays: 7,
  );

  static const monthly = ProPlan(
    id: 'monthly',
    period: ProPeriod.monthly,
    price: r'$5.99',
    amount: 5.99,
  );

  @override
  final bool available;

  @override
  bool simulated = false;

  List<ProPlan> offered = const [yearly, monthly];

  /// What [purchase] answers (default: Pro bought).
  PurchaseOutcome? outcome;

  /// What [restore] finds.
  bool restorable = false;

  final purchased = <ProPlan>[];
  int restores = 0;

  final _changes = StreamController<Entitlement>.broadcast();
  Entitlement _current;

  @override
  Entitlement get current => _current;

  @override
  Stream<Entitlement> get changes => _changes.stream;

  /// Turns Pro on or off, as a renewal or an expiration would.
  void setPro({required bool pro}) => _set(pro ? proYearly : Entitlement.free);

  void _set(Entitlement next) {
    _current = next;
    _changes.add(next);
  }

  @override
  Uri get manageUrl => playSubscriptionsUrl;

  @override
  Future<void> start() async {}

  @override
  Future<List<ProPlan>> plans() async => available ? offered : const [];

  @override
  Future<PurchaseOutcome> purchase(ProPlan plan) async {
    purchased.add(plan);
    final answer = outcome;
    if (answer != null) return answer;
    _set(Entitlement(isPro: true, period: plan.period));
    return PurchaseDone(_current);
  }

  @override
  Future<Entitlement> restore() async {
    restores++;
    if (restorable) _set(proYearly);
    return _current;
  }

  @override
  Future<void> resetSimulation() async => _set(Entitlement.free);
}

/// Records the pages the app opens.
class FakeLinkOpener implements LinkOpener {
  final opened = <Uri>[];

  @override
  Future<bool> open(Uri url) async {
    opened.add(url);
    return true;
  }
}
