import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// The eight color ranges of the HSL tool, by their hue (degrees on the
/// HSV wheel) and the swatch shown for them.
enum ColorBand {
  red(0, 0xFFD2483C),
  orange(30, 0xFFE08A3C),
  yellow(60, 0xFFE2C64A),
  green(120, 0xFF6FA84F),
  aqua(180, 0xFF4FB3B0),
  blue(240, 0xFF4A6FD0),
  purple(270, 0xFF8A5CC8),
  magenta(300, 0xFFC855A8);

  new(this.hue, this.swatch);

  final double hue;

  /// Opaque ARGB.
  final int swatch;
}

/// What the HSL tool changes in a color range. Values go from −1 to +1,
/// 0 neutral: hue turns toward the neighbouring ranges, saturation and
/// luminance scale (develop.frag says by how much).
enum ColorChannel { hue, saturation, luminance }

/// Per-range hue / saturation / luminance (the HSL tool, also called a
/// color mixer). Sparse like `Adjustments`: values are clamped to −1…+1 and
/// neutral ones dropped, so mixes that render the same compare equal.
///
/// JSON: `{"red": {"hue": 0.1, "saturation": -0.3}, "blue": {…}}`. Unknown
/// keys are ignored so older app versions can read newer edits.
@immutable
class ColorMix {
  const new() : _values = const {};

  const new _(this._values);

  factory of(Map<(ColorBand, ColorChannel), double> values) {
    final canonical = <(ColorBand, ColorChannel), double>{};
    for (final band in ColorBand.values) {
      for (final channel in ColorChannel.values) {
        final value = values[(band, channel)];
        if (value == null) continue;
        final clamped = value.clamp(-1.0, 1.0);
        if (clamped.abs() >= _epsilon) canonical[(band, channel)] = clamped;
      }
    }
    return ColorMix._(Map.unmodifiable(canonical));
  }

  factory fromJson(Map<String, dynamic> json) => ColorMix.of({
    for (final band in ColorBand.values)
      if (json[band.name] case final Map<String, dynamic> shift)
        for (final channel in ColorChannel.values)
          if (shift[channel.name] case final num value)
            (band, channel): value.toDouble(),
  });

  static const _epsilon = 1e-6;

  final Map<(ColorBand, ColorChannel), double> _values;

  double call(ColorBand band, ColorChannel channel) =>
      _values[(band, channel)] ?? 0;

  bool get isNeutral => _values.isEmpty;

  /// Whether any channel of [band] is changed.
  bool isEdited(ColorBand band) => _values.keys.any((k) => k.$1 == band);

  ColorMix withValue(ColorBand band, ColorChannel channel, double value) =>
      ColorMix.of({..._values, (band, channel): value});

  Map<String, dynamic> toJson() => {
    for (final band in ColorBand.values)
      if (isEdited(band))
        band.name: {
          for (final channel in ColorChannel.values)
            channel.name: ?_values[(band, channel)],
        },
  };

  @override
  bool operator ==(Object other) =>
      other is ColorMix &&
      const MapEquality<(ColorBand, ColorChannel), double>().equals(
        _values,
        other._values,
      );

  @override
  int get hashCode =>
      const MapEquality<(ColorBand, ColorChannel), double>().hash(_values);

  @override
  String toString() => 'ColorMix(${toJson()})';
}

/// Entries of the color lookup table: entry `i` holds the mix at hue
/// `(i + 0.5) / colorLutSize` of the wheel.
const colorLutSize = 256;

/// The byte that stands for 0 in the color lookup table: `v → 128 + 127·v`.
const colorLutZero = 128;

/// The 256×1 RGBA table develop.frag looks up by a pixel's hue: hue shift,
/// saturation and luminance in R, G, B (128 = neutral), alpha 255. Between
/// two ranges each value eases from one to the other, so a hue halfway
/// between red and orange gets half of each.
Uint8List buildColorLut(ColorMix mix) {
  final lut = Uint8List(colorLutSize * 4);
  const bands = ColorBand.values;
  for (var i = 0; i < colorLutSize; i++) {
    final hue = (i + 0.5) / colorLutSize * 360;
    // The ranges around this hue, going round the wheel after magenta.
    var next = bands.indexWhere((b) => b.hue > hue);
    if (next < 0) next = 0;
    final from = bands[(next - 1) % bands.length];
    final to = bands[next];
    final span = (to.hue - from.hue) % 360;
    final t = ((hue - from.hue) % 360) / span;
    final eased = t * t * (3 - 2 * t);
    for (final channel in ColorChannel.values) {
      final a = mix(from, channel);
      final b = mix(to, channel);
      final value = a + (b - a) * eased;
      lut[i * 4 + channel.index] = (colorLutZero + value * 127).round().clamp(
        1,
        255,
      );
    }
    lut[i * 4 + 3] = 255;
  }
  return lut;
}

/// The table for a neutral mix: every entry 128, 128, 128, 255.
final Uint8List identityColorLut = buildColorLut(const ColorMix());
