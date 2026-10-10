import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'elements.freezed.dart';
part 'elements.g.dart';

// Coordinates are normalized to the cropped media (0…1, origin top-left) and
// sizes are fractions of its shorter side, so elements land in the same place
// in the preview and in a full-resolution export.

enum TextAlignment { left, center, right }

/// Brush types of the freehand BRUSH tool (spec §21).
enum BrushType { pen, marker, pencil, chalk, paint, highlighter }

/// How an overlay (light leak, dust, film burn…) blends with the media.
enum OverlayBlend { screen, multiply, overlay, softLight, normal }

/// Position (center), scale and rotation of an element.
@freezed
abstract class ElementTransform with _$ElementTransform {
  const factory({
    @Default(0.5) double x,
    @Default(0.5) double y,
    @Default(1) double scale,

    /// Radians, clockwise.
    @Default(0) double rotation,
  }) = _ElementTransform;

  factory fromJson(Map<String, dynamic> json) =>
      _$ElementTransformFromJson(json);
}

/// When a video element is visible (spec §23). Null on an element means the
/// whole clip; photos ignore it.
@freezed
abstract class TimeRange with _$TimeRange {
  const factory({required int startMs, required int endMs}) = _TimeRange;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$TimeRangeFromJson(json);

  bool contains(int ms) => ms >= startMs && ms < endMs;

  int get durationMs => endMs - startMs;

  /// Shortest range the timeline handles allow.
  static const minDurationMs = 300;

  /// Shifted by [deltaMs], kept inside the clip, length unchanged.
  TimeRange moved(int deltaMs, {required int durationMs}) {
    final length = math.min(this.durationMs, durationMs);
    final start = (startMs + deltaMs).clamp(0, durationMs - length);
    return TimeRange(startMs: start, endMs: start + length);
  }

  /// Moves one end to [startMs] or [endMs], inside the clip and at least
  /// [minDurationMs] long.
  TimeRange resized({required int durationMs, int? startMs, int? endMs}) {
    final minimum = math.min(minDurationMs, durationMs);
    var start = startMs ?? this.startMs;
    var end = endMs ?? this.endMs;
    if (startMs != null) start = start.clamp(0, end - minimum);
    if (endMs != null) end = end.clamp(start + minimum, durationMs);
    return TimeRange(startMs: start, endMs: end);
  }
}

@freezed
abstract class TextShadowSpec with _$TextShadowSpec {
  const factory({
    @Default(0x66000000) int color,
    @Default(0.01) double blur,
    @Default(0) double dx,
    @Default(0.004) double dy,
  }) = _TextShadowSpec;

  factory fromJson(Map<String, dynamic> json) => _$TextShadowSpecFromJson(json);
}

@freezed
abstract class TextOutlineSpec with _$TextOutlineSpec {
  const factory({
    @Default(0xFF161412) int color,
    @Default(0.003) double width,
  }) = _TextOutlineSpec;

  factory fromJson(Map<String, dynamic> json) =>
      _$TextOutlineSpecFromJson(json);
}

@freezed
abstract class TextBackgroundSpec with _$TextBackgroundSpec {
  const factory({
    @Default(0xFFEFE8DC) int color,
    @Default(0.01) double padding,
  }) = _TextBackgroundSpec;

  factory fromJson(Map<String, dynamic> json) =>
      _$TextBackgroundSpecFromJson(json);
}

/// Text appearance (spec §19). Colors are ARGB ints.
@freezed
abstract class TextStyleSpec with _$TextStyleSpec {
  const factory({
    @Default('Newsreader') String fontFamily,

    /// Fraction of the media's shorter side.
    @Default(0.06) double fontSize,
    @Default(400) int fontWeight,
    @Default(false) bool italic,
    @Default(TextAlignment.center) TextAlignment align,
    @Default(0xFFEFE8DC) int color,

    /// In em.
    @Default(0) double letterSpacing,
    @Default(1.2) double lineHeight,

    /// Set in capitals (Grotesk).
    @Default(false) bool uppercase,
    TextShadowSpec? shadow,
    TextOutlineSpec? outline,
    TextBackgroundSpec? background,
  }) = _TextStyleSpec;

  factory fromJson(Map<String, dynamic> json) => _$TextStyleSpecFromJson(json);
}

/// A touch sample. [pressure] is null on devices without pressure (spec §22).
@freezed
abstract class StrokePoint with _$StrokePoint {
  const factory({required double x, required double y, double? pressure}) =
      _StrokePoint;

  factory fromJson(Map<String, dynamic> json) => _$StrokePointFromJson(json);
}

@freezed
abstract class BrushStroke with _$BrushStroke {
  const factory({@Default(<StrokePoint>[]) List<StrokePoint> points}) =
      _BrushStroke;

  factory fromJson(Map<String, dynamic> json) => _$BrushStrokeFromJson(json);
}

/// Something placed on the media (spec §18). The `type` key in JSON selects
/// the variant.
@Freezed(unionKey: 'type')
sealed class EditElement with _$EditElement {
  /// Free text box (TYPE → SET TYPE).
  const factory text({
    required String id,
    required String text,
    @Default(TextStyleSpec()) TextStyleSpec style,
    String? textPresetId,
    @Default(ElementTransform()) ElementTransform transform,
    @Default(1) double opacity,
    TimeRange? time,
  }) = TextElement;

  /// Text set along a path drawn with the finger (TYPE → TEXT BRUSH).
  /// [path] is the baseline, in normalized media coordinates.
  const factory textPath({
    required String id,
    required String text,
    required List<StrokePoint> path,
    @Default(TextStyleSpec()) TextStyleSpec style,
    @Default(ElementTransform()) ElementTransform transform,
    @Default(1) double opacity,
    TimeRange? time,
  }) = TextPathElement;

  /// Freehand drawing (BRUSH). [size] is a fraction of the shorter side.
  const factory brush({
    required String id,
    @Default(BrushType.pen) BrushType brushType,
    @Default(0.01) double size,
    @Default(0xFFEFE8DC) int color,
    @Default(0.5) double smoothing,
    @Default(<BrushStroke>[]) List<BrushStroke> strokes,
    @Default(ElementTransform()) ElementTransform transform,
    @Default(1) double opacity,
    TimeRange? time,
  }) = BrushElement;

  /// A line-art sticker tinted with [color] (its SVG uses currentColor).
  const factory sticker({
    required String id,
    required String assetId,
    @Default(0xFFF6F0E6) int color,
    @Default(ElementTransform()) ElementTransform transform,
    @Default(1) double opacity,
    TimeRange? time,
  }) = StickerElement;

  /// Full-frame texture blended over the media.
  const factory overlay({
    required String id,
    required String assetId,
    @Default(OverlayBlend.screen) OverlayBlend blend,
    @Default(1) double opacity,
    TimeRange? time,
  }) = OverlayElement;

  /// Border around the whole image (spec §26).
  const factory frame({required String id, required String assetId}) =
      FrameElement;

  factory fromJson(Map<String, dynamic> json) => _$EditElementFromJson(json);
}

/// When elements show in a video (spec §23). Frames always cover the
/// whole clip.
extension ElementTiming on EditElement {
  TimeRange? get time => switch (this) {
    TextElement(:final time) ||
    TextPathElement(:final time) ||
    BrushElement(:final time) ||
    StickerElement(:final time) ||
    OverlayElement(:final time) => time,
    FrameElement() => null,
  };

  bool visibleAt(int ms) => time?.contains(ms) ?? true;

  EditElement withTime(TimeRange? time) => switch (this) {
    final TextElement e => e.copyWith(time: time),
    final TextPathElement e => e.copyWith(time: time),
    final BrushElement e => e.copyWith(time: time),
    final StickerElement e => e.copyWith(time: time),
    final OverlayElement e => e.copyWith(time: time),
    final FrameElement e => e,
  };
}
