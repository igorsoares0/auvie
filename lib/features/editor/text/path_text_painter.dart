import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Lays text out along a path: each character sits on the path, rotated to
/// its direction. The rendering behind Text Brush (TYPE → TEXT BRUSH).
class PathTextPainter extends CustomPainter {
  new({
    required this.text,
    required this.style,
    required this.points,
    this.guide,
  });

  final String text;
  final TextStyle style;

  /// Baseline points, in the painter's coordinates.
  final List<Offset> points;

  /// When set, also draws the dashed path guide in this color.
  final Color? guide;

  /// A smooth path through [points] (quadratic segments through midpoints).
  static Path smoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points.first.dx, points.first.dy);
    if (points.length < 3) {
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      return path;
    }
    for (var i = 1; i < points.length - 1; i++) {
      final mid = (points[i] + points[i + 1]) / 2;
      path.quadraticBezierTo(points[i].dx, points[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = smoothPath(points);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;

    if (guide != null) _drawDashed(canvas, metric, guide!);

    var distance = 0.0;
    for (final char in text.characters) {
      final painter = TextPainter(
        text: TextSpan(text: char, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      final width = painter.width;
      if (distance + width > metric.length) break;
      final tangent = metric.getTangentForOffset(distance + width / 2);
      if (tangent != null) {
        final baseline = painter.computeDistanceToActualBaseline(
          TextBaseline.alphabetic,
        );
        canvas
          ..save()
          ..translate(tangent.position.dx, tangent.position.dy)
          ..rotate(-tangent.angle);
        painter.paint(canvas, Offset(-width / 2, -baseline));
        canvas.restore();
      }
      painter.dispose();
      distance += width;
    }
  }

  void _drawDashed(Canvas canvas, ui.PathMetric metric, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const dash = 4.0;
    const gap = 4.0;
    for (var d = 0.0; d < metric.length; d += dash + gap) {
      canvas.drawPath(metric.extractPath(d, d + dash), paint);
    }
    final end = metric.getTangentForOffset(metric.length);
    if (end != null) canvas.drawCircle(end.position, 11, paint);
  }

  @override
  bool shouldRepaint(PathTextPainter old) =>
      old.text != text ||
      old.style != style ||
      old.guide != guide ||
      !_samePoints(old.points, points);

  static bool _samePoints(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
