import 'dart:math' as math;
import 'dart:ui';

import 'package:auvie/core/models/elements.dart';
import 'package:auvie/features/editor/elements/stable_hash.dart';
import 'package:auvie/features/editor/text/path_text_painter.dart';

/// Draws the six brushes of spec §21. Textures are seeded by the element id
/// and stroke index, and laid out in units of the brush width, so a stroke
/// looks the same in the preview and in a full-size export.
abstract final class BrushRenderer {
  /// Width multiplier per brush (relative to the element's size).
  static double widthFactor(BrushType type) => switch (type) {
    BrushType.pen => 1,
    BrushType.marker => 2.2,
    BrushType.pencil => 0.6,
    BrushType.chalk => 1.8,
    BrushType.paint => 2.6,
    BrushType.highlighter => 3.6,
  };

  /// [points] in output pixels; [pressure] 0…1 or null per point.
  static void paintStroke(
    Canvas canvas, {
    required BrushType type,
    required List<Offset> points,
    required List<double?> pressure,
    required double width,
    required Color color,
    required int seed,
  }) {
    if (points.isEmpty) return;
    final w = width * widthFactor(type);
    final random = math.Random(seed);
    final path = PathTextPainter.smoothPath(points);
    final hasPressure = pressure.any((p) => p != null);

    Paint stroke(
      double strokeWidth, {
      double alpha = 1,
      StrokeCap cap = StrokeCap.round,
    }) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = cap
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: color.a * alpha);

    if (points.length == 1) {
      canvas.drawCircle(points.first, w / 2, Paint()..color = color);
      return;
    }

    switch (type) {
      case BrushType.pen:
        if (hasPressure) {
          for (var i = 1; i < points.length; i++) {
            final p = ((pressure[i] ?? 0.5) + (pressure[i - 1] ?? 0.5)) / 2;
            canvas.drawLine(
              points[i - 1],
              points[i],
              stroke(w * (0.4 + p * 1.2)),
            );
          }
        } else {
          canvas.drawPath(path, stroke(w));
        }
      case BrushType.marker:
        canvas.drawPath(path, stroke(w, alpha: 0.9, cap: StrokeCap.square));
      case BrushType.highlighter:
        canvas.drawPath(path, stroke(w, alpha: 0.4, cap: StrokeCap.butt));
      case BrushType.paint:
        canvas
          ..drawPath(
            path,
            stroke(w)..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.12),
          )
          ..drawPath(path, stroke(w * 0.7));
      case BrushType.pencil:
        canvas.drawPath(path, stroke(w, alpha: 0.55));
        for (final metric in path.computeMetrics()) {
          for (var d = 0.0; d < metric.length; d += w * 0.8) {
            final t = metric.getTangentForOffset(d);
            if (t == null) continue;
            final jitter =
                Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5) *
                w;
            canvas.drawLine(
              t.position + jitter,
              t.position + jitter + t.vector * w * 1.2,
              stroke(w * 0.35, alpha: 0.25 + random.nextDouble() * 0.3),
            );
          }
        }
      case BrushType.chalk:
        final dot = Paint()..color = color.withValues(alpha: color.a * 0.85);
        for (final metric in path.computeMetrics()) {
          for (var d = 0.0; d < metric.length; d += w * 0.3) {
            final t = metric.getTangentForOffset(d);
            if (t == null) continue;
            for (var i = 0; i < 5; i++) {
              if (random.nextDouble() < 0.25) continue; // Gaps in the chalk.
              final angle = random.nextDouble() * math.pi * 2;
              final r = random.nextDouble() * w / 2;
              canvas.drawCircle(
                t.position + Offset(math.cos(angle), math.sin(angle)) * r,
                w * (0.06 + random.nextDouble() * 0.1),
                dot,
              );
            }
          }
        }
    }
  }

  /// Draws all strokes of [element] in an output of [size] (element frame
  /// already applied by the caller, with points relative to the pivot).
  static void paintElement(
    Canvas canvas,
    BrushElement element,
    Size size, {
    Offset origin = Offset.zero,
  }) {
    final width = element.size * size.shortestSide;
    final base = stableHash(element.id);
    for (final (i, stroke) in element.strokes.indexed) {
      paintStroke(
        canvas,
        type: element.brushType,
        points: [
          for (final p in stroke.points)
            Offset(p.x * size.width, p.y * size.height) - origin,
        ],
        pressure: [for (final p in stroke.points) p.pressure],
        width: width,
        color: Color(element.color),
        seed: base ^ (i * 0x9E3779B1),
      );
    }
  }
}
