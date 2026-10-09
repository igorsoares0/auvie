import 'dart:math' as math;

import 'package:auvie/core/models/crop.dart';
import 'package:auvie/core/models/crop_geometry.dart';
import 'package:auvie/core/models/project.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher near((double, double) expected) => predicate<(double, double)>(
  (p) => (p.$1 - expected.$1).abs() < 1e-9 && (p.$2 - expected.$2).abs() < 1e-9,
  'is near $expected',
);

void main() {
  const media = MediaRef(
    uri: 'content://p',
    type: MediaType.photo,
    width: 4000,
    height: 3000,
  );
  const ratio = 4000 / 3000;

  group('Affine2', () {
    test('then composes in order', () {
      const scale = Affine2(2, 0, 0, 2, 0, 0);
      const shift = Affine2(1, 0, 0, 1, 1, 0);
      expect(scale.then(shift).apply(1, 1), near((3, 2)));
      expect(shift.then(scale).apply(1, 1), near((4, 2)));
    });

    test('round-trips through its list form', () {
      const m = Affine2(1, 2, 3, 4, 5, 6);
      expect(Affine2.fromList(m.toList()), m);
      expect(() => Affine2.fromList(const [1, 2]), throwsArgumentError);
    });
  });

  group('matrix', () {
    Affine2 m(CropTransform crop) => CropGeometry.matrix(crop, ratio);

    test('no crop is the identity', () {
      expect(m(const CropTransform()), Affine2.identity);
    });

    test('a quarter turn clockwise brings the left edge to the top', () {
      final turn = m(const CropTransform(quarterTurns: 1));
      expect(turn.apply(0, 0), near((0, 1))); // top-left ← bottom-left
      expect(turn.apply(1, 0), near((0, 0))); // top-right ← top-left
      expect(turn.apply(1, 1), near((1, 0)));
    });

    test('half and three-quarter turns', () {
      expect(m(const CropTransform(quarterTurns: 2)).apply(0, 0), near((1, 1)));
      final three = m(const CropTransform(quarterTurns: 3));
      expect(three.apply(0, 0), near((1, 0)));
      expect(three.apply(0, 1), near((0, 0)));
    });

    test('flips mirror the output', () {
      expect(
        m(const CropTransform(flipHorizontal: true)).apply(0, 0.3),
        near((1, 0.3)),
      );
      expect(
        m(const CropTransform(flipVertical: true)).apply(0.3, 0),
        near((0.3, 1)),
      );
    });

    test('a crop samples only its area', () {
      final crop = m(
        const CropTransform(rect: NormalizedRect(left: 0.25, width: 0.5)),
      );
      expect(crop.apply(0, 0.5), near((0.25, 0.5)));
      expect(crop.apply(1, 0.5), near((0.75, 0.5)));
    });

    test('straightening keeps the crop on the image', () {
      for (final degrees in [-45.0, -12.5, 7.0, 30.0, 45.0]) {
        final crop = const CropTransform().withStraighten(
          degrees,
          mediaRatio: ratio,
        );
        final matrix = m(crop);
        for (final (x, y) in [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)]) {
          final (u, v) = matrix.apply(x, y);
          expect(u, inInclusiveRange(-1e-9, 1 + 1e-9), reason: '$degrees°');
          expect(v, inInclusiveRange(-1e-9, 1 + 1e-9), reason: '$degrees°');
        }
      }
    });

    test('crop mode shows the whole frame', () {
      const crop = CropTransform(rect: NormalizedRect(left: 0.25, width: 0.5));
      expect(
        CropGeometry.matrix(crop, ratio, includeCrop: false),
        Affine2.identity,
      );
    });
  });

  group('fit', () {
    test('is the largest centred rect when nothing is rotated', () {
      final rect = CropGeometry.fit(
        targetRatio: 1,
        degrees: 0,
        orientedRatio: ratio,
      );
      expect(rect.height, closeTo(1, 1e-9));
      expect(rect.width, closeTo(1 / ratio, 1e-9));
    });

    for (final r in [ratio, 1 / ratio, 1.0]) {
      test(
        'fits at every angle, and only just (ratio ${r.toStringAsFixed(2)})',
        () {
          for (var deg = -45.0; deg <= 45; deg += 0.5) {
            final rect = CropGeometry.fit(
              targetRatio: 4 / 5,
              degrees: deg,
              orientedRatio: r,
            );
            expect(
              CropGeometry.fits(rect, deg, r, tolerance: 1e-7),
              isTrue,
              reason: '$deg°',
            );
            if (deg != 0) {
              final bigger = NormalizedRect(
                left: rect.centerX - rect.width * 0.51,
                top: rect.centerY - rect.height * 0.51,
                width: rect.width * 1.02,
                height: rect.height * 1.02,
              );
              expect(
                CropGeometry.fits(bigger, deg, r),
                isFalse,
                reason: '$deg°',
              );
            }
          }
        },
      );
    }

    test('fitting again changes nothing', () {
      final once = CropGeometry.fit(
        targetRatio: 1,
        degrees: 20,
        orientedRatio: ratio,
        centerX: 0.4,
        centerY: 0.55,
      );
      final twice = CropGeometry.fit(
        targetRatio: 1,
        degrees: 20,
        orientedRatio: ratio,
        centerX: once.centerX,
        centerY: once.centerY,
      );
      expect(twice.left, closeTo(once.left, 1e-9));
      expect(twice.width, closeTo(once.width, 1e-9));
    });

    test('a centre off the image recentres the crop', () {
      final rect = CropGeometry.fit(
        targetRatio: 1,
        degrees: 45,
        orientedRatio: 1,
        centerX: 0.01,
        centerY: 0.01,
      );
      expect(rect.centerX, closeTo(0.5, 1e-9));
      expect(rect.centerY, closeTo(0.5, 1e-9));
    });
  });

  group('sizes', () {
    test('output keeps the cropped original, capped by pixels', () {
      expect(
        CropGeometry.outputSize(
          const CropTransform(),
          media,
          maxPixels: 32000000,
        ),
        (width: 4000, height: 3000),
      );
      final web = CropGeometry.outputSize(
        const CropTransform(),
        media,
        maxPixels: 2000000,
      );
      expect(web.width * web.height, lessThanOrEqualTo(2000000));
      expect(web.width / web.height, closeTo(ratio, 0.01));
    });

    test('a quarter turn swaps the output sides', () {
      expect(
        CropGeometry.outputSize(
          const CropTransform(quarterTurns: 1),
          media,
          maxPixels: 32000000,
        ),
        (width: 3000, height: 4000),
      );
    });

    test('a crop shrinks the output', () {
      expect(
        CropGeometry.outputSize(
          const CropTransform(rect: NormalizedRect(left: 0.25, width: 0.5)),
          media,
          maxPixels: 32000000,
        ),
        (width: 2000, height: 3000),
      );
    });

    test('decodes only as large as the output needs', () {
      const crop = CropTransform(rect: NormalizedRect(left: 0.25, width: 0.5));
      expect(CropGeometry.decodeLongSide(crop, media, outputWidth: 2000), 4000);
      expect(CropGeometry.decodeLongSide(crop, media, outputWidth: 1000), 2000);
    });
  });

  group('CropTransform editing', () {
    final square = const CropTransform().withAspect(
      CropAspect.square,
      mediaRatio: ratio,
    );

    test('moving stops at the image edge', () {
      final moved = square.moved(1, 0.5, mediaRatio: ratio);
      expect(moved.rect.left + moved.rect.width, closeTo(1, 1e-6));
      expect(moved.rect.top, closeTo(0, 1e-9)); // Full height: can't move.
    });

    test('resizing keeps the aspect and the opposite corner', () {
      final smaller = square.resizedFromCorner(
        CropCorner.topLeft,
        0.2,
        0.2,
        mediaRatio: ratio,
      );
      expect(smaller.outputRatio(ratio), closeTo(1, 1e-9));
      expect(
        smaller.rect.left + smaller.rect.width,
        closeTo(square.rect.left + square.rect.width, 1e-9),
      );
      expect(
        smaller.rect.top + smaller.rect.height,
        closeTo(square.rect.top + square.rect.height, 1e-9),
      );
      expect(smaller.rect.width, lessThan(square.rect.width));
    });

    test('resizing never goes below the minimum or off the image', () {
      final tiny = square.resizedFromCorner(
        CropCorner.bottomRight,
        -5,
        -5,
        mediaRatio: ratio,
      );
      expect(
        math.min(tiny.rect.width * ratio, tiny.rect.height),
        greaterThanOrEqualTo(CropTransform.minSize - 1e-9),
      );
      final huge = square.resizedFromCorner(
        CropCorner.bottomRight,
        5,
        5,
        mediaRatio: ratio,
      );
      expect(CropGeometry.fits(huge.rect, 0, ratio), isTrue);
    });

    test('straightening refits around the current centre', () {
      final tilted = square.withStraighten(15, mediaRatio: ratio);
      expect(tilted.rect.width, lessThan(square.rect.width));
      expect(tilted.rect.centerX, closeTo(square.rect.centerX, 1e-9));
      final back = tilted.withStraighten(0, mediaRatio: ratio);
      expect(back.rect.width, closeTo(square.rect.width, 1e-9));
    });

    test('flipping toggles', () {
      expect(square.flippedHorizontally().flipHorizontal, isTrue);
      expect(square.flippedHorizontally().flippedHorizontally(), square);
    });
  });
}
