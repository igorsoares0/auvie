import 'package:auvie/core/models/crop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NormalizedRect.centered', () {
    test('square on a 3:2 landscape keeps full height', () {
      final r = NormalizedRect.centered(targetRatio: 1, sourceRatio: 1.5);
      expect(r.height, 1);
      expect(r.width, closeTo(2 / 3, 1e-9));
      expect(r.left, closeTo(1 / 6, 1e-9));
      expect(r.top, 0);
    });

    test('16:9 on a 3:4 portrait keeps full width', () {
      final r = NormalizedRect.centered(targetRatio: 16 / 9, sourceRatio: 0.75);
      expect(r.width, 1);
      expect(r.height, closeTo(0.75 / (16 / 9), 1e-9));
      expect(r.top, closeTo((1 - r.height) / 2, 1e-9));
    });
  });

  group('CropTransform', () {
    test('default is the identity', () {
      expect(const CropTransform().isIdentity, isTrue);
      expect(const CropTransform(flipHorizontal: true).isIdentity, isFalse);
    });

    for (final mediaRatio in [4 / 3, 3 / 4, 1.0, 16 / 9]) {
      for (final aspect in CropAspect.values) {
        test('$aspect on media ${mediaRatio.toStringAsFixed(2)} '
            'gives that output ratio', () {
          final crop = const CropTransform().withAspect(
            aspect,
            mediaRatio: mediaRatio,
          );
          expect(
            crop.outputRatio(mediaRatio),
            closeTo(aspect.ratio ?? mediaRatio, 1e-9),
          );
          expect(crop.rect.left, greaterThanOrEqualTo(0));
          expect(crop.rect.top, greaterThanOrEqualTo(0));
          expect(crop.rect.left + crop.rect.width, lessThanOrEqualTo(1 + 1e-9));
          expect(crop.rect.top + crop.rect.height, lessThanOrEqualTo(1 + 1e-9));
        });
      }
    }

    test('original aspect uses the whole media', () {
      final crop = const CropTransform().withAspect(
        CropAspect.original,
        mediaRatio: 1.5,
      );
      expect(crop.rect, NormalizedRect.full);
    });

    test('odd quarter turns swap the media orientation', () {
      const crop = CropTransform(quarterTurns: 1);
      expect(crop.orientedRatio(1.5), closeTo(1 / 1.5, 1e-9));
      expect(const CropTransform(quarterTurns: 2).orientedRatio(1.5), 1.5);
    });

    test('rotating keeps the chosen aspect in the new orientation', () {
      final crop = const CropTransform()
          .withAspect(CropAspect.portrait4x5, mediaRatio: 1.5)
          .rotatedClockwise(mediaRatio: 1.5);
      expect(crop.quarterTurns, 1);
      expect(crop.aspect, CropAspect.portrait4x5);
      expect(crop.outputRatio(1.5), closeTo(4 / 5, 1e-9));
    });

    test('four turns come back to the start', () {
      var crop = const CropTransform();
      for (var i = 0; i < 4; i++) {
        crop = crop.rotatedClockwise(mediaRatio: 1.5);
      }
      expect(crop, const CropTransform());
    });

    test('straighten is limited to ±45°', () {
      CropTransform s(double d) =>
          const CropTransform().withStraighten(d, mediaRatio: 1.5);
      expect(s(60).straighten, 45);
      expect(s(-50).straighten, -45);
      expect(s(12).straighten, 12);
    });

    test('round-trips through JSON', () {
      const crop = CropTransform(
        aspect: CropAspect.story9x16,
        rect: NormalizedRect(left: 0.2, width: 0.6),
        quarterTurns: 3,
        straighten: -2,
        flipVertical: true,
      );
      expect(CropTransform.fromJson(crop.toJson()), crop);
    });
  });
}
