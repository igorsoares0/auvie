import 'package:auvie/core/models/adjustments.dart';
import 'package:auvie/core/models/tone_curve.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preset.freezed.dart';
part 'preset.g.dart';

/// `"#rrggbb"` in JSON ↔ opaque ARGB int.
class HexColorConverter implements JsonConverter<int, String> {
  const new();

  @override
  int fromJson(String json) {
    final hex = json.startsWith('#') ? json.substring(1) : json;
    if (hex.length != 6) throw FormatException('Expected #rrggbb', json);
    return 0xFF000000 | int.parse(hex, radix: 16);
  }

  @override
  String toJson(int object) =>
      '#${(object & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

/// Highlight / mid / shadow swatches shown under a preset card.
@freezed
abstract class ToneStrip with _$ToneStrip {
  const factory({
    @HexColorConverter() required int highlight,
    @HexColorConverter() required int mid,
    @HexColorConverter() required int shadow,
  }) = _ToneStrip;

  factory fromJson(Map<String, dynamic> json) => _$ToneStripFromJson(json);
}

/// A declarative look (spec §12). [settings] are deltas added to the user's
/// adjustments, scaled by intensity. Works on photo and video alike.
@freezed
abstract class Preset with _$Preset {
  const factory({
    required String id,
    required String name,
    required String collectionId,
    @Default(1) int version,
    @Default(false) bool isPremium,
    @Default(Adjustments()) Adjustments settings,
    ToneCurves? curves,
    ToneStrip? tone,

    /// Film stock line under the name, e.g. "Colour neg." and ISO.
    String? stock,
    int? iso,
    String? description,
  }) = _Preset;

  factory fromJson(Map<String, dynamic> json) => _$PresetFromJson(json);
}

/// The preset applied to a project and how strongly.
@freezed
abstract class PresetRef with _$PresetRef {
  const factory({required String presetId, @Default(1) double intensity}) =
      _PresetRef;

  factory fromJson(Map<String, dynamic> json) => _$PresetRefFromJson(json);
}
