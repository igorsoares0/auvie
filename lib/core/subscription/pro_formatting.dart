import 'package:auvie/core/subscription/entitlement.dart';

/// "44" when [yearly] costs 44% less than twelve months of [monthly]; null
/// when it doesn't save anything.
int? savePercent({required ProPlan yearly, required ProPlan monthly}) {
  final full = monthly.amount * 12;
  if (full <= 0) return null;
  final percent = ((1 - yearly.amount / full) * 100).floor();
  return percent > 0 ? percent : null;
}

/// "a year" / "a month".
String perPeriod(ProPeriod period) => switch (period) {
  ProPeriod.yearly => 'a year',
  ProPeriod.monthly => 'a month',
};

/// The caps line under a plan: "$3.33 / MONTH · 7 DAYS FREE",
/// "BILLED MONTHLY".
String planNote(ProPlan plan) {
  final parts = [
    if (plan.period == ProPeriod.yearly && plan.pricePerMonth != null)
      '${plan.pricePerMonth} / MONTH'
    else if (plan.period == ProPeriod.monthly)
      'BILLED MONTHLY'
    else
      'BILLED YEARLY',
    if (plan.trialDays case final days? when days > 0) '$days DAYS FREE',
  ];
  return parts.join(' · ');
}

/// The full terms under the button, as a sentence (handoff 08).
String termsSentence(ProPlan plan) {
  final price = '${plan.price} ${perPeriod(plan.period)}';
  final days = plan.trialDays ?? 0;
  if (days > 0) {
    return 'Free for $days days, then $price. Cancel in Google Play before '
        'the trial ends and you won’t be charged.';
  }
  return '$price, renewing automatically. Cancel anytime in Google Play.';
}

/// START FREE TRIAL when the plan has one, else CONTINUE.
String purchaseLabel(ProPlan plan) =>
    (plan.trialDays ?? 0) > 0 ? 'START FREE TRIAL' : 'CONTINUE';
