import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/features/editor/adjustments/adjustment_family.dart';
import 'package:auvie/features/editor/adjustments/ruler_scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every adjustment belongs to exactly one family', () {
    final all = [
      for (final family in AdjustmentFamily.values) ...family.adjustments,
    ];
    expect(all.toSet(), Adjustment.values.toSet());
    expect(all, hasLength(Adjustment.values.length));
  });

  test('curve and crop have their own controls instead of a ruler', () {
    expect(AdjustmentFamily.values.where((f) => !f.usesRuler), [
      AdjustmentFamily.curve,
      AdjustmentFamily.crop,
    ]);
  });

  test('labels and value formats', () {
    expect(Adjustment.exposure.label, 'Exposure');
    expect(Adjustment.exposure.format(-0.34), '−0.34');
    expect(Adjustment.exposure.format(0.2), '+0.20');
    expect(Adjustment.exposure.format(0.001), '0.00');
    expect(Adjustment.grain.format(0.25), '0.25');
  });

  group('RulerScale', () {
    final exposure = RulerScale.forAdjustment(Adjustment.exposure);
    final grain = RulerScale.forAdjustment(Adjustment.grain);

    test('positions values across the ruler', () {
      expect(exposure.fraction(-1), 0);
      expect(exposure.fraction(0), 0.5);
      expect(exposure.fraction(1), 1);
      expect(grain.fraction(0), 0);
      expect(grain.fraction(0.5), 0.5);
    });

    test('a full-width drag covers the whole range, clamped', () {
      expect(exposure.drag(0, 100, 400), closeTo(0.5, 1e-9));
      expect(exposure.drag(0.8, 400, 400), 1);
      expect(grain.drag(0.1, -400, 400), 0);
    });

    test('majors depend on polarity', () {
      expect(exposure.majors, [-1, -0.5, 0, 0.5, 1]);
      expect(grain.majors, [0, 0.5, 1]);
    });

    test('reports the major tick a move crosses or lands on', () {
      expect(exposure.crossedMajor(-0.1, 0.1), 0);
      expect(exposure.crossedMajor(0.1, -0.1), 0);
      expect(exposure.crossedMajor(0.4, 0.5), 0.5);
      expect(exposure.crossedMajor(0.1, 0.2), isNull);
      // Leaving a tick doesn't report it again.
      expect(exposure.crossedMajor(0, 0.05), isNull);
      expect(exposure.crossedMajor(0.3, 0.3), isNull);
    });
  });
}
