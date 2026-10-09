import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/adjustments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Adjustment ranges', () {
    test('bipolar parameters go from -1 to 1', () {
      expect(Adjustment.exposure.min, -1);
      expect(Adjustment.exposure.clamp(-3), -1);
      expect(Adjustment.temperature.clamp(2), 1);
    });

    test('sharpen, grain and fade go from 0 to 1', () {
      for (final a in [Adjustment.sharpen, Adjustment.grain, Adjustment.fade]) {
        expect(a.min, 0, reason: a.name);
        expect(a.clamp(-0.4), 0, reason: a.name);
      }
    });
  });

  group('Adjustments', () {
    test('starts neutral and reads missing values as 0', () {
      const adjustments = Adjustments();
      expect(adjustments.isNeutral, isTrue);
      expect(adjustments[Adjustment.contrast], 0);
    });

    test('clamps values to their range', () {
      final a = const Adjustments()
          .withValue(Adjustment.exposure, 2)
          .withValue(Adjustment.grain, -0.5);
      expect(a[Adjustment.exposure], 1);
      expect(a[Adjustment.grain], 0);
    });

    test('drops neutral values so equal edits compare equal', () {
      final edited = const Adjustments()
          .withValue(Adjustment.exposure, 0.3)
          .withValue(Adjustment.exposure, 0);
      expect(edited, const Adjustments());
      expect(edited.hashCode, const Adjustments().hashCode);
      expect(edited.isNeutral, isTrue);
    });

    test(
      'equal values have equal hash codes regardless of insertion order',
      () {
        final a = Adjustments.of(const {
          Adjustment.exposure: 0.1,
          Adjustment.tint: -0.2,
        });
        final b = Adjustments.of(const {
          Adjustment.tint: -0.2,
          Adjustment.exposure: 0.1,
        });
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      },
    );

    test('serializes as a flat map (spec §12 settings format)', () {
      final a = Adjustments.of(const {
        Adjustment.exposure: 0.05,
        Adjustment.grain: 0.25,
      });
      expect(a.toJson(), {'exposure': 0.05, 'grain': 0.25});
      expect(Adjustments.fromJson(a.toJson()), a);
    });

    test('reads JSON leniently: ignores unknown keys, clamps values', () {
      final a = Adjustments.fromJson(const {
        'exposure': 3,
        'fade': 0.1,
        'bloom': 0.4,
        'contrast': 'high',
      });
      expect(a.values, {Adjustment.exposure: 1.0, Adjustment.fade: 0.1});
    });

    group('combine (preset intensity, spec §13)', () {
      final manual = Adjustments.of(const {Adjustment.exposure: 0.1});
      final preset = Adjustments.of(const {
        Adjustment.exposure: 0.2,
        Adjustment.grain: 0.5,
      });

      test('adds delta × weight', () {
        final result = manual.combine(preset, weight: 0.5);
        expect(result[Adjustment.exposure], closeTo(0.2, 1e-9));
        expect(result[Adjustment.grain], closeTo(0.25, 1e-9));
      });

      test('weight 0 keeps the manual values', () {
        expect(manual.combine(preset, weight: 0), manual);
      });

      test('full weight adds the whole preset', () {
        final result = manual.combine(preset);
        expect(result[Adjustment.exposure], closeTo(0.3, 1e-9));
        expect(result[Adjustment.grain], 0.5);
      });

      test('clamps the sum', () {
        final high = Adjustments.of(const {Adjustment.exposure: 0.9});
        expect(high.combine(preset)[Adjustment.exposure], 1);
      });
    });
  });
}
