import 'dart:math' as math;
import 'dart:ui';

import 'package:auvie/core/models/elements.dart';
import 'package:auvie/features/editor/elements/element_assets.dart';
import 'package:auvie/features/editor/elements/text_renderer.dart';

/// Where an element sits in an output of a given size: content drawn
/// around [pivot] in local coordinates ([local]), then rotated and scaled
/// and moved by [offset].
class ElementFrame {
  const new({
    required this.pivot,
    required this.offset,
    required this.rotation,
    required this.scale,
    required this.local,
  });

  final Offset pivot;
  final Offset offset;
  final double rotation;
  final double scale;

  /// Content box around the pivot, before rotation and scale.
  final Rect local;

  Offset get center => pivot + offset;

  /// Local point → output point.
  Offset toOutput(Offset p) {
    final s = p * scale;
    final cos = math.cos(rotation);
    final sin = math.sin(rotation);
    return center + Offset(s.dx * cos - s.dy * sin, s.dx * sin + s.dy * cos);
  }

  /// Output point → local point.
  Offset toLocal(Offset p) {
    final d = p - center;
    final cos = math.cos(-rotation);
    final sin = math.sin(-rotation);
    return Offset(d.dx * cos - d.dy * sin, d.dx * sin + d.dy * cos) / scale;
  }

  /// Hit-test with a finger-sized [slop] in output pixels.
  bool contains(Offset p, {double slop = 0}) =>
      local.inflate(slop / scale).contains(toLocal(p));

  /// The four corners in output space (TL, TR, BR, BL).
  List<Offset> get corners => [
    toOutput(local.topLeft),
    toOutput(local.topRight),
    toOutput(local.bottomRight),
    toOutput(local.bottomLeft),
  ];

  /// Axis-aligned box around the transformed content.
  Rect get bounds {
    final c = corners;
    final xs = c.map((p) => p.dx);
    final ys = c.map((p) => p.dy);
    return Rect.fromLTRB(
      xs.reduce(math.min),
      ys.reduce(math.min),
      xs.reduce(math.max),
      ys.reduce(math.max),
    );
  }

  /// Applies this frame to [canvas]: afterwards draw in local coordinates.
  void transform(Canvas canvas) {
    canvas
      ..translate(center.dx, center.dy)
      ..rotate(rotation)
      ..scale(scale);
  }
}

/// Element sizes, as fractions of the output's shorter side.
abstract final class ElementSizes {
  /// A sticker at scale 1.
  static const sticker = 0.3;
}

abstract final class ElementGeometry {
  /// The frame of [element] in an output of [size], or null for elements
  /// that cover the whole output (overlays and frames).
  static ElementFrame? of(
    EditElement element,
    Size size,
    ElementAssets assets,
  ) {
    final short = size.shortestSide;
    Offset at(ElementTransform t) =>
        Offset(t.x * size.width, t.y * size.height);

    ElementFrame pathFrame(
      List<StrokePoint> points,
      ElementTransform t,
      double inflate,
    ) {
      final pts = [
        for (final p in points) Offset(p.x * size.width, p.y * size.height),
      ];
      if (pts.isEmpty) {
        return ElementFrame(
          pivot: at(t),
          offset: Offset.zero,
          rotation: 0,
          scale: 1,
          local: Rect.zero,
        );
      }
      final xs = pts.map((p) => p.dx);
      final ys = pts.map((p) => p.dy);
      final box = Rect.fromLTRB(
        xs.reduce(math.min),
        ys.reduce(math.min),
        xs.reduce(math.max),
        ys.reduce(math.max),
      ).inflate(inflate);
      return ElementFrame(
        pivot: box.center,
        offset: Offset((t.x - 0.5) * size.width, (t.y - 0.5) * size.height),
        rotation: t.rotation,
        scale: t.scale,
        local: box.shift(-box.center),
      );
    }

    return switch (element) {
      final TextElement e => () {
        final box = TextRenderer.boxSize(e.text, e.style, size);
        return ElementFrame(
          pivot: at(e.transform),
          offset: Offset.zero,
          rotation: e.transform.rotation,
          scale: e.transform.scale,
          local: Rect.fromCenter(
            center: Offset.zero,
            width: box.width,
            height: box.height,
          ),
        );
      }(),
      final TextPathElement e => pathFrame(
        e.path,
        e.transform,
        e.style.fontSize * short * 1.2,
      ),
      final BrushElement e => pathFrame(
        [for (final s in e.strokes) ...s.points],
        e.transform,
        e.size * short * 2,
      ),
      final StickerElement e => () {
        final side = ElementSizes.sticker * short;
        final ratio = assets.stickerRatio(e.assetId);
        final (w, h) = ratio >= 1 ? (side, side / ratio) : (side * ratio, side);
        return ElementFrame(
          pivot: at(e.transform),
          offset: Offset.zero,
          rotation: e.transform.rotation,
          scale: e.transform.scale,
          local: Rect.fromCenter(center: Offset.zero, width: w, height: h),
        );
      }(),
      OverlayElement() || FrameElement() => null,
    };
  }

  /// The topmost movable element under [point], if any.
  static String? hit(
    List<EditElement> elements,
    Offset point,
    Size size,
    ElementAssets assets, {
    double slop = 16,
  }) {
    for (final e in elements.reversed) {
      final frame = of(e, size, assets);
      if (frame != null && frame.contains(point, slop: slop)) return e.id;
    }
    return null;
  }

  /// [element] moved by [delta] output pixels, scaled by [scale] and turned
  /// by [rotation] radians (one gesture update).
  static EditElement transformed(
    EditElement element,
    Size size, {
    Offset delta = Offset.zero,
    double scale = 1,
    double rotation = 0,
  }) {
    ElementTransform apply(ElementTransform t) => t.copyWith(
      x: t.x + delta.dx / size.width,
      y: t.y + delta.dy / size.height,
      scale: (t.scale * scale).clamp(0.1, 12),
      rotation: t.rotation + rotation,
    );
    return switch (element) {
      final TextElement e => e.copyWith(transform: apply(e.transform)),
      final TextPathElement e => e.copyWith(transform: apply(e.transform)),
      final BrushElement e => e.copyWith(transform: apply(e.transform)),
      final StickerElement e => e.copyWith(transform: apply(e.transform)),
      OverlayElement() || FrameElement() => element,
    };
  }
}
