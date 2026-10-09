import 'package:auvie/core/models/tone_curve.dart';
import 'package:flutter_test/flutter_test.dart';

ToneCurve curve(List<(double, double)> points) => ToneCurve(
  points: [for (final (x, y) in points) CurvePoint(x: x, y: y)],
);

void main() {
  group('ToneCurve', () {
    test('default is the identity', () {
      const c = ToneCurve();
      expect(c.isIdentity, isTrue);
      for (var i = 0; i <= 20; i++) {
        expect(c.evaluate(i / 20), closeTo(i / 20, 1e-9));
      }
    });

    test('passes through its control points', () {
      final c = curve([(0, 0.1), (0.3, 0.5), (0.7, 0.6), (1, 0.9)]);
      expect(c.isIdentity, isFalse);
      expect(c.evaluate(0), closeTo(0.1, 1e-9));
      expect(c.evaluate(0.3), closeTo(0.5, 1e-9));
      expect(c.evaluate(0.7), closeTo(0.6, 1e-9));
      expect(c.evaluate(1), closeTo(0.9, 1e-9));
    });

    test('does not overshoot: increasing points give an increasing curve', () {
      final c = curve([(0, 0), (0.1, 0.6), (0.2, 0.65), (1, 1)]).sampler();
      var previous = -1.0;
      for (var i = 0; i <= 1000; i++) {
        final y = c(i / 1000);
        expect(y, greaterThanOrEqualTo(previous));
        expect(y, inInclusiveRange(0, 1));
        previous = y;
      }
    });

    test('is flat outside the first and last points', () {
      final c = curve([(0.2, 0.1), (0.8, 0.9)]);
      expect(c.evaluate(0), 0.1);
      expect(c.evaluate(1), 0.9);
    });

    test('accepts unsorted points', () {
      final c = curve([(1, 1), (0, 0.2), (0.5, 0.4)]);
      expect(c.evaluate(0), closeTo(0.2, 1e-9));
      expect(c.evaluate(0.5), closeTo(0.4, 1e-9));
    });

    test('degenerate curves do not crash', () {
      expect(const ToneCurve(points: []).evaluate(0.4), 0.4);
      expect(curve([(0.5, 0.7)]).evaluate(0.1), 0.7);
      expect(curve([(0.5, 0.2), (0.5, 0.8)]).evaluate(0.5), isNotNaN);
    });

    test('round-trips through JSON', () {
      final c = curve([(0, 0.1), (1, 0.9)]);
      expect(ToneCurve.fromJson(c.toJson()), c);
    });
  });

  group('buildCurveLut', () {
    int channel(List<int> lut, int i, int c) => lut[i * 4 + c];

    test('identity curves give an identity table with opaque alpha', () {
      final lut = buildCurveLut(user: const ToneCurves());
      expect(lut.length, curveLutSize * 4);
      for (var i = 0; i < curveLutSize; i++) {
        for (var c = 0; c < 3; c++) {
          expect(channel(lut, i, c), i);
        }
        expect(channel(lut, i, 3), 255);
      }
    });

    final lifted = ToneCurves(master: curve([(0, 0.2), (1, 1)]));

    test('preset curves at intensity 0 have no effect', () {
      final lut = buildCurveLut(
        user: const ToneCurves(),
        preset: lifted,
        intensity: 0,
      );
      expect(lut, buildCurveLut(user: const ToneCurves()));
    });

    test('preset curves blend toward identity by intensity', () {
      int black(double intensity) => channel(
        buildCurveLut(
          user: const ToneCurves(),
          preset: lifted,
          intensity: intensity,
        ),
        0,
        0,
      );
      expect(black(1), (0.2 * 255).round());
      expect(black(0.5), (0.1 * 255).round());
    });

    test("the user's curves apply on top of the preset", () {
      final invert = ToneCurves(master: curve([(0, 1), (1, 0)]));
      final lut = buildCurveLut(user: invert, preset: lifted);
      // black → preset lifts to 0.2 → user inverts to 0.8.
      expect(channel(lut, 0, 0), (0.8 * 255).round());
    });

    test('a channel curve only affects its channel', () {
      final warm = ToneCurves(red: curve([(0, 0.3), (1, 1)]));
      final lut = buildCurveLut(user: warm);
      expect(channel(lut, 0, 0), (0.3 * 255).round());
      expect(channel(lut, 0, 1), 0);
      expect(channel(lut, 0, 2), 0);
    });

    test('channel curves see the master curve output', () {
      final c = ToneCurves(
        master: curve([(0, 0.5), (1, 1)]),
        blue: curve([(0, 0), (0.5, 0), (1, 1)]),
      );
      final lut = buildCurveLut(user: c);
      // master(0) = 0.5, blue(0.5) = 0.
      expect(channel(lut, 0, 2), 0);
      expect(channel(lut, 0, 0), (0.5 * 255).round());
    });
  });
}
