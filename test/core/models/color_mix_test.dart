import 'package:auvie/core/models/color_mix.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Decodes entry [i] of a color LUT: (hue shift, saturation, luminance).
List<double> entry(List<int> lut, int i) => [
  for (var c = 0; c < 3; c++) (lut[i * 4 + c] - colorLutZero) / 127,
];

/// The entry whose hue is closest to [degrees].
int at(double degrees) => (degrees / 360 * colorLutSize).floor();

void main() {
  group('ColorMix', () {
    test('is sparse: neutral values are dropped and the rest clamped', () {
      final mix = ColorMix.of(const {
        (ColorBand.red, ColorChannel.hue): 0,
        (ColorBand.blue, ColorChannel.saturation): -3,
      });
      expect(
        mix,
        ColorMix.of(const {(ColorBand.blue, ColorChannel.saturation): -1}),
      );
      expect(mix(ColorBand.blue, ColorChannel.saturation), -1);
      expect(mix(ColorBand.red, ColorChannel.hue), 0);
      expect(const ColorMix().isNeutral, isTrue);
      expect(
        mix.withValue(ColorBand.blue, ColorChannel.saturation, 0),
        const ColorMix(),
      );
    });

    test('knows which ranges are edited', () {
      final mix = const ColorMix().withValue(
        ColorBand.aqua,
        ColorChannel.luminance,
        0.3,
      );
      expect(mix.isEdited(ColorBand.aqua), isTrue);
      expect(mix.isEdited(ColorBand.red), isFalse);
    });

    test('round-trips through JSON, ignoring unknown keys', () {
      final mix = ColorMix.of(const {
        (ColorBand.orange, ColorChannel.hue): -0.2,
        (ColorBand.orange, ColorChannel.luminance): 0.4,
        (ColorBand.magenta, ColorChannel.saturation): 0.7,
      });
      expect(mix.toJson(), {
        'orange': {'hue': -0.2, 'luminance': 0.4},
        'magenta': {'saturation': 0.7},
      });
      expect(ColorMix.fromJson(mix.toJson()), mix);
      expect(
        ColorMix.fromJson(const {
          'teal': {'hue': 1},
          'red': {'warmth': 1, 'hue': 0.5},
        }),
        ColorMix.of(const {(ColorBand.red, ColorChannel.hue): 0.5}),
      );
    });

    test('edits without a color mix read as neutral', () {
      final edit = EditState.fromJson(const {});
      expect(edit.colorMix, const ColorMix());
      final mixed = EditState(
        colorMix: ColorMix.of(const {(ColorBand.green, ColorChannel.hue): 0.3}),
      );
      expect(EditState.fromJson(mixed.toJson()), mixed);
      expect(mixed.isUnedited, isFalse);
    });

    test('copy and paste carry it', () {
      final mixed = EditState(
        colorMix: ColorMix.of(const {(ColorBand.green, ColorChannel.hue): 0.3}),
      );
      expect(const EditState().pasteEdits(mixed.copyEdits()), mixed);
    });
  });

  group('buildColorLut', () {
    test('a neutral mix is 128 everywhere with opaque alpha', () {
      final lut = buildColorLut(const ColorMix());
      expect(lut.length, colorLutSize * 4);
      for (var i = 0; i < colorLutSize; i++) {
        expect(lut.sublist(i * 4, i * 4 + 4), [128, 128, 128, 255]);
      }
      expect(identityColorLut, lut);
    });

    test('each range gets its full value at its own hue', () {
      for (final band in ColorBand.values) {
        final lut = buildColorLut(
          ColorMix.of({(band, ColorChannel.saturation): 1}),
        );
        expect(
          entry(lut, at(band.hue))[1],
          closeTo(1, 0.03),
          reason: band.name,
        );
      }
    });

    test('values ease between neighbouring ranges and nowhere else', () {
      final lut = buildColorLut(
        ColorMix.of(const {(ColorBand.green, ColorChannel.luminance): -1}),
      );
      // Green is at 120°, between yellow (60°) and aqua (180°).
      expect(entry(lut, at(90))[2], closeTo(-0.5, 0.03));
      expect(entry(lut, at(150))[2], closeTo(-0.5, 0.03));
      expect(entry(lut, at(30))[2], 0);
      expect(entry(lut, at(240))[2], 0);
      for (var i = 0; i < colorLutSize; i++) {
        expect(entry(lut, i)[0], 0);
        expect(entry(lut, i)[1], 0);
      }
    });

    test('wraps from magenta back to red', () {
      final lut = buildColorLut(
        ColorMix.of(const {(ColorBand.red, ColorChannel.hue): 1}),
      );
      expect(entry(lut, at(330))[0], closeTo(0.5, 0.03));
      expect(entry(lut, at(15))[0], closeTo(0.5, 0.03));
      expect(entry(lut, colorLutSize - 1)[0], greaterThan(0.95));
      expect(entry(lut, 0)[0], greaterThan(0.95));
    });

    test('the extremes stay in the byte range', () {
      final lut = buildColorLut(
        ColorMix.of(const {
          (ColorBand.red, ColorChannel.hue): -1,
          (ColorBand.red, ColorChannel.saturation): 1,
        }),
      );
      expect(lut[at(0) * 4], 1);
      expect(lut[at(0) * 4 + 1], 255);
    });
  });
}
