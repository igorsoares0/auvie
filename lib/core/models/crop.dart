import 'dart:math' as math;

import 'package:auvie/core/models/crop_geometry.dart';
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

  double get centerX => left + width / 2;
  double get centerY => top + height / 2;
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

  /// Smallest crop, as a fraction of the frame's shorter side.
  static const minSize = 0.1;

  /// Width / height the crop keeps.
  double targetRatio(double mediaRatio) =>
      aspect.ratio ?? orientedRatio(mediaRatio);

  /// Selects [newAspect] and resets the crop to the largest centred area
  /// that fits the (straightened) image.
  CropTransform withAspect(CropAspect newAspect, {required double mediaRatio}) {
    final next = copyWith(aspect: newAspect);
    return next.copyWith(
      rect: CropGeometry.fit(
        targetRatio: next.targetRatio(mediaRatio),
        degrees: straighten,
        orientedRatio: orientedRatio(mediaRatio),
      ),
    );
  }

  /// Turns 90° clockwise, keeping the chosen aspect (recentred in the new
  /// orientation).
  CropTransform rotatedClockwise({required double mediaRatio}) =>
      copyWith(quarterTurns: (quarterTurns + 1) % 4)
          .withAspect(aspect, mediaRatio: mediaRatio);

  /// Straightens by [degrees] (clockwise, ±45). The crop keeps its centre
  /// and grows or shrinks to the largest area with no empty corners.
  CropTransform withStraighten(double degrees, {required double mediaRatio}) {
    final angle = degrees.clamp(-maxStraighten, maxStraighten);
    return copyWith(
      straighten: angle,
      rect: CropGeometry.fit(
        targetRatio: targetRatio(mediaRatio),
        degrees: angle,
        orientedRatio: orientedRatio(mediaRatio),
        centerX: rect.centerX,
        centerY: rect.centerY,
      ),
    );
  }

  CropTransform flippedHorizontally() =>
      copyWith(flipHorizontal: !flipHorizontal);

  /// Moves the crop by ([dx], [dy]) in frame fractions, as far as it can
  /// go on each axis without leaving the image.
  CropTransform moved(double dx, double dy, {required double mediaRatio}) {
    final ratio = orientedRatio(mediaRatio);
    bool fits(NormalizedRect r) => CropGeometry.fits(r, straighten, ratio);

    NormalizedRect slide(NormalizedRect from, double ddx, double ddy) {
      NormalizedRect at(double t) =>
          from.copyWith(left: from.left + ddx * t, top: from.top + ddy * t);
      if (fits(at(1))) return at(1);
      var (lo, hi) = (0.0, 1.0);
      for (var i = 0; i < 20; i++) {
        final mid = (lo + hi) / 2;
        if (fits(at(mid))) {
          lo = mid;
        } else {
          hi = mid;
        }
      }
      return at(lo);
    }

    return copyWith(rect: slide(slide(rect, dx, 0), 0, dy));
  }

  /// Resizes by dragging [corner] by ([dx], [dy]) in frame fractions; the
  /// opposite corner stays put and the aspect is kept.
  CropTransform resizedFromCorner(
    CropCorner corner,
    double dx,
    double dy, {
    required double mediaRatio,
  }) {
    final ratio = orientedRatio(mediaRatio);
    final target = targetRatio(mediaRatio);
    // Rect height in frame fractions for a given width keeps the aspect.
    double heightFor(double width) => width * ratio / target;

    final grow = (x: corner.isLeft ? -dx : dx, y: corner.isTop ? -dy : dy);
    final fromX = rect.width + grow.x;
    final fromY = (rect.height + grow.y) * target / ratio;
    final minWidth = math.max(minSize, minSize * target / ratio);
    final wanted = math.max(minWidth, (fromX + fromY) / 2);

    NormalizedRect sized(double width) {
      final height = heightFor(width);
      final right = rect.left + rect.width;
      final bottom = rect.top + rect.height;
      return NormalizedRect(
        left: corner.isLeft ? right - width : rect.left,
        top: corner.isTop ? bottom - height : rect.top,
        width: width,
        height: height,
      );
    }

    bool fits(NormalizedRect r) => CropGeometry.fits(r, straighten, ratio);
    if (fits(sized(wanted))) return copyWith(rect: sized(wanted));
    // Grow only as far as the image allows.
    var (lo, hi) = (math.min(rect.width, wanted), math.max(rect.width, wanted));
    if (!fits(sized(lo))) return this;
    for (var i = 0; i < 20; i++) {
      final mid = (lo + hi) / 2;
      if (fits(sized(mid))) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return copyWith(rect: sized(lo));
  }
}

enum CropCorner {
  topLeft,
  topRight,
  bottomRight,
  bottomLeft;

  bool get isLeft => this == topLeft || this == bottomLeft;
  bool get isTop => this == topLeft || this == topRight;
}
