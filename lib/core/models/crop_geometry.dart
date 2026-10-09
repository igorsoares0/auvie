import 'dart:math' as math;

import 'package:auvie/core/models/crop.dart';
import 'package:auvie/core/models/project.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// A 2D affine transform: `x' = a·x + b·y + tx`, `y' = c·x + d·y + ty`.
@immutable
class Affine2 {
  const new(this.a, this.b, this.c, this.d, this.tx, this.ty);

  factory fromList(List<double> v) {
    if (v.length != 6) throw ArgumentError.value(v, 'v', 'needs 6 values');
    return Affine2(v[0], v[1], v[2], v[3], v[4], v[5]);
  }

  static const identity = Affine2(1, 0, 0, 1, 0, 0);

  final double a;
  final double b;
  final double c;
  final double d;
  final double tx;
  final double ty;

  (double, double) apply(double x, double y) =>
      (a * x + b * y + tx, c * x + d * y + ty);

  /// This transform followed by [next].
  Affine2 then(Affine2 next) => Affine2(
    next.a * a + next.b * c,
    next.a * b + next.b * d,
    next.c * a + next.d * c,
    next.c * b + next.d * d,
    next.a * tx + next.b * ty + next.tx,
    next.c * tx + next.d * ty + next.ty,
  );

  /// `[a, b, c, d, tx, ty]`, the order the engine reads.
  Float64List toList() => Float64List.fromList([a, b, c, d, tx, ty]);

  @override
  bool operator ==(Object other) =>
      other is Affine2 &&
      const ListEquality<double>().equals(toList(), other.toList());

  @override
  int get hashCode => Object.hash(a, b, c, d, tx, ty);

  @override
  String toString() => 'Affine2(${toList().join(', ')})';
}

/// Geometry of [CropTransform], shared by the preview and the export: the
/// engine samples the original through [matrix], so both see the same crop.
///
/// Spaces, from the original outwards:
/// - *source*: the decoded photo, uv 0…1;
/// - *turned*: after `quarterTurns` clockwise; ratio `orientedRatio`;
/// - *oriented*: turned, then flipped;
/// - *frame*: the oriented image rotated by `straighten` degrees (clockwise)
///   around its centre, in a canvas the size of the oriented image. The crop
///   rect lives here. Positions in *height units* (x × ratio) keep angles
///   true while rotating.
abstract final class CropGeometry {
  /// Output uv (0…1 across the crop, or across the whole frame when
  /// [includeCrop] is false) → source uv.
  static Affine2 matrix(
    CropTransform crop,
    double mediaRatio, {
    bool includeCrop = true,
  }) {
    final ratio = crop.orientedRatio(mediaRatio);
    final rect = includeCrop ? crop.rect : NormalizedRect.full;
    return Affine2(
          ratio * rect.width,
          0,
          0,
          rect.height,
          ratio * rect.left,
          rect.top,
        )
        // Frame → oriented image: undo the straighten rotation.
        .then(_rotation(-crop.straighten, ratio / 2, 0.5))
        .then(Affine2(1 / ratio, 0, 0, 1, 0, 0))
        .then(
          crop.flipHorizontal
              ? const Affine2(-1, 0, 0, 1, 1, 0)
              : Affine2.identity,
        )
        .then(
          crop.flipVertical
              ? const Affine2(1, 0, 0, -1, 0, 1)
              : Affine2.identity,
        )
        .then(_unturn(crop.quarterTurns));
  }

  /// Whether [rect] lies on the image once rotated by [degrees].
  static bool fits(
    NormalizedRect rect,
    double degrees,
    double orientedRatio, {
    double tolerance = 1e-9,
  }) {
    final toImage = _rotation(-degrees, orientedRatio / 2, 0.5);
    for (final (x, y) in [
      (rect.left, rect.top),
      (rect.left + rect.width, rect.top),
      (rect.left, rect.top + rect.height),
      (rect.left + rect.width, rect.top + rect.height),
    ]) {
      final (px, py) = toImage.apply(x * orientedRatio, y);
      if (px < -tolerance ||
          px > orientedRatio + tolerance ||
          py < -tolerance ||
          py > 1 + tolerance) {
        return false;
      }
    }
    return true;
  }

  /// The largest rect of [targetRatio] (output width / height) centred at
  /// ([centerX], [centerY]) that stays on the image rotated by [degrees],
  /// at most [maxScale] times the largest such rect without rotation. If the
  /// centre itself is off the image, the rect is centred on the frame.
  static NormalizedRect fit({
    required double targetRatio,
    required double degrees,
    required double orientedRatio,
    double centerX = 0.5,
    double centerY = 0.5,
    double maxScale = 1,
  }) {
    final base = NormalizedRect.centered(
      targetRatio: targetRatio,
      sourceRatio: orientedRatio,
    );
    final w0 = base.width * orientedRatio;
    final h0 = base.height;
    final toImage = _rotation(-degrees, orientedRatio / 2, 0.5);

    var (cx, cy) = (centerX * orientedRatio, centerY);
    var (ax, ay) = toImage.apply(cx, cy);
    final outside = ax < 0 || ax > orientedRatio || ay < 0 || ay > 1;
    if (outside) {
      (cx, cy) = (orientedRatio / 2, 0.5);
      (ax, ay) = (cx, cy);
    }

    var k = maxScale;
    final linear = Affine2(toImage.a, toImage.b, toImage.c, toImage.d, 0, 0);
    for (final (sx, sy) in [
      (-1.0, -1.0),
      (1.0, -1.0),
      (-1.0, 1.0),
      (1.0, 1.0),
    ]) {
      final (bx, by) = linear.apply(sx * w0 / 2, sy * h0 / 2);
      k = math.min(k, _limit(ax, bx, orientedRatio));
      k = math.min(k, _limit(ay, by, 1));
    }
    k = math.max(k, 0);
    final width = k * w0 / orientedRatio;
    final height = k * h0;
    return NormalizedRect(
      left: cx / orientedRatio - width / 2,
      top: cy - height / 2,
      width: width,
      height: height,
    );
  }

  /// Output size in pixels of [crop] on [media], at most [maxPixels].
  /// Never larger than the cropped original.
  static ({int width, int height}) outputSize(
    CropTransform crop,
    MediaRef media, {
    required int maxPixels,
  }) {
    final (ow, oh) = _orientedSize(crop, media);
    final w0 = crop.rect.width * ow;
    final h0 = crop.rect.height * oh;
    final scale = math.sqrt(maxPixels / (w0 * h0));
    // Rounding down when scaling keeps the result within maxPixels.
    int side(double v) =>
        math.max(1, scale >= 1 ? v.round() : (v * scale).floor());
    return (width: side(w0), height: side(h0));
  }

  /// Longer side to decode the original at so the crop has at least
  /// [outputWidth] pixels across.
  static int decodeLongSide(
    CropTransform crop,
    MediaRef media, {
    required int outputWidth,
  }) {
    final (ow, _) = _orientedSize(crop, media);
    final longSide = math.max(media.width, media.height);
    final scale = outputWidth / (crop.rect.width * ow);
    return (longSide * scale).ceil().clamp(1, longSide);
  }

  static (int, int) _orientedSize(CropTransform crop, MediaRef media) =>
      crop.quarterTurns.isOdd
      ? (media.height, media.width)
      : (media.width, media.height);

  /// Largest k ≥ 0 keeping `a + k·b` within 0…max.
  static double _limit(double a, double b, double max) {
    if (b > 0) return (max - a) / b;
    if (b < 0) return a / -b;
    return double.infinity;
  }

  /// Rotation by [degrees] (clockwise on screen, y down) around (cx, cy).
  static Affine2 _rotation(double degrees, double cx, double cy) {
    final r = degrees * math.pi / 180;
    final cos = math.cos(r);
    final sin = math.sin(r);
    return Affine2(
      cos,
      -sin,
      sin,
      cos,
      cx - cos * cx + sin * cy,
      cy - sin * cx - cos * cy,
    );
  }

  /// Oriented uv → source uv, undoing [quarterTurns] clockwise turns.
  static Affine2 _unturn(int quarterTurns) => switch (quarterTurns % 4) {
    1 => const Affine2(0, 1, -1, 0, 0, 1),
    2 => const Affine2(-1, 0, 0, -1, 1, 1),
    3 => const Affine2(0, -1, 1, 0, 1, 0),
    _ => Affine2.identity,
  };
}
