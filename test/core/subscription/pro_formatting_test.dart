import 'package:auvie/core/subscription/entitlement.dart';
import 'package:auvie/core/subscription/pro_formatting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const yearly = ProPlan(
    id: 'y',
    period: ProPeriod.yearly,
    price: r'$39.99',
    amount: 39.99,
    pricePerMonth: r'$3.33',
    trialDays: 7,
  );
  const monthly = ProPlan(
    id: 'm',
    period: ProPeriod.monthly,
    price: r'$5.99',
    amount: 5.99,
  );

  test('yearly saves against twelve months', () {
    // 39.99 / 71.88 = 0.556 → 44% saved (the design's SAVE 44%).
    expect(savePercent(yearly: yearly, monthly: monthly), 44);
    expect(
      savePercent(yearly: yearly.copyWith(amount: 80), monthly: monthly),
      isNull,
    );
    expect(
      savePercent(yearly: yearly, monthly: monthly.copyWith(amount: 0)),
      isNull,
    );
  });

  test('plan notes', () {
    expect(planNote(yearly), r'$3.33 / MONTH · 7 DAYS FREE');
    expect(planNote(monthly), 'BILLED MONTHLY');
    expect(
      planNote(yearly.copyWith(pricePerMonth: null, trialDays: null)),
      'BILLED YEARLY',
    );
  });

  test('terms and button follow the trial', () {
    expect(
      termsSentence(yearly),
      r'Free for 7 days, then $39.99 a year. Cancel in Google Play before '
      'the trial ends and you won’t be charged.',
    );
    expect(
      termsSentence(monthly),
      r'$5.99 a month, renewing automatically. Cancel anytime in Google Play.',
    );
    expect(purchaseLabel(yearly), 'START FREE TRIAL');
    expect(purchaseLabel(monthly), 'CONTINUE');
  });
}
