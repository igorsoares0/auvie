import 'package:freezed_annotation/freezed_annotation.dart';

part 'crop.freezed.dart';
part 'crop.g.dart';

/// Aspect ratios offered by the crop tool (spec §15).
enum CropAspect {
  original(null),
  square(1),
  portrait4x5(4 / 5),
  portrait3x4(3 / 4),
  story9x16(9 / 16),
  landscape16x9(16 / 9);

  new(this.ratio);

  /// Width / height, or null for the media's own ratio.
  final double? ratio;
}

/// A rectangle in normalized coordinates (0…1) of the oriented media.
@freezed
abstract class NormalizedRect with _$NormalizedRect {
  const factory({
    @Default(0) double left,
    @Default(0) double top,
    @Default(1) double width,
    @Default(1) double height,
  }) = _NormalizedRect;

  /// The largest rectangle of [targetRatio] centered in a source whose
  /// ratio (width / height) is [sourceRatio].
  factory centered({required double targetRatio, required double sourceRatio}) {
    if (targetRatio > sourceRatio) {
      final height = sourceRatio / targetRatio;
      return NormalizedRect(top: (1 - height) / 2, height: height);
    }
    final width = targetRatio / sourceRatio;
    return NormalizedRect(left: (1 - width) / 2, width: width);
  }

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$NormalizedRectFromJson(json);

  static const full = NormalizedRect();
}

/// Crop, rotation and flip. Applied before adjustments and elements.
@freezed
abstract class CropTransform with _$CropTransform {
  const factory({
    @Default(CropAspect.original) CropAspect aspect,

    /// Crop area in the media after [quarterTurns] are applied.
    @Default(NormalizedRect.full) NormalizedRect rect,

    /// Clockwise 90° turns, 0…3.
    @Default(0) int quarterTurns,

    /// Fine rotation in degrees, −45…45.
    @Default(0) double straighten,
    @Default(false) bool flipHorizontal,
    @Default(false) bool flipVertical,
  }) = _CropTransform;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$CropTransformFromJson(json);

  static const maxStraighten = 45.0;

  bool get isIdentity => this == const CropTransform();

  /// Ratio (width / height) of the media once [quarterTurns] are applied.
  double orientedRatio(double mediaRatio) =>
      quarterTurns.isOdd ? 1 / mediaRatio : mediaRatio;

  /// Ratio (width / height) of the output.
  double outputRatio(double mediaRatio) {
    final oriented = orientedRatio(mediaRatio);
    return oriented * rect.width / rect.height;
  }

  /// Selects [newAspect] and resets the crop to the largest centered area.
  CropTransform withAspect(CropAspect newAspect, {required double mediaRatio}) {
    final oriented = orientedRatio(mediaRatio);
    return copyWith(
      aspect: newAspect,
      rect: NormalizedRect.centered(
        targetRatio: newAspect.ratio ?? oriented,
        sourceRatio: oriented,
      ),
    );
  }

  /// Turns 90° clockwise, keeping the chosen aspect (recentred in the new
  /// orientation).
  CropTransform rotatedClockwise({required double mediaRatio}) =>
      copyWith(quarterTurns: (quarterTurns + 1) % 4)
          .withAspect(aspect, mediaRatio: mediaRatio);

  CropTransform withStraighten(double degrees) =>
      copyWith(straighten: degrees.clamp(-maxStraighten, maxStraighten));
}
