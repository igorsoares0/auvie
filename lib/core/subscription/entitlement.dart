import 'package:freezed_annotation/freezed_annotation.dart';

part 'entitlement.freezed.dart';
part 'entitlement.g.dart';

/// How often a Pro plan renews.
enum ProPeriod { monthly, yearly }

/// Whether the user has Pro (spec §49: the `pro` entitlement).
@freezed
abstract class Entitlement with _$Entitlement {
  const factory({
    @Default(false) bool isPro,
    ProPeriod? period,
    DateTime? expiresAt,
    @Default(false) bool inTrial,
  }) = _Entitlement;

  factory fromJson(Map<String, dynamic> json) => _$EntitlementFromJson(json);

  static const free = Entitlement();
}

/// A plan offered on the paywall, priced by the store.
@freezed
abstract class ProPlan with _$ProPlan {
  const factory({
    /// Store package id, used to buy it.
    required String id,
    required ProPeriod period,

    /// "$39.99", formatted by the store in the user's currency.
    required String price,

    /// [price] as a number, to compare plans.
    required double amount,

    /// "$3.33" for yearly plans, when the store provides it.
    String? pricePerMonth,

    /// Free days before the first charge, if the plan has a trial.
    int? trialDays,
  }) = _ProPlan;
}

/// How a purchase ended.
sealed class PurchaseOutcome {
  const new();
}

class PurchaseDone extends PurchaseOutcome {
  const new(this.entitlement);

  final Entitlement entitlement;
}

class PurchaseCancelled extends PurchaseOutcome {
  const new();
}

/// The store accepted the order but the payment is still being processed
/// (e.g. cash at a shop); Pro arrives when it clears.
class PurchasePending extends PurchaseOutcome {
  const new();
}

class PurchaseFailed extends PurchaseOutcome {
  const new([this.message]);

  final String? message;
}
