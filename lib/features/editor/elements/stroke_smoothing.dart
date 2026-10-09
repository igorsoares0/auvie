import 'dart:math' as math;

import 'package:auvie/core/models/elements.dart';

/// Moving average over [window] points, keeping both ends where the finger
/// put them. Text laid on a jittery line overlaps itself on tight turns;
/// smoothing the line first keeps letters apart.
List<StrokePoint> smoothStroke(List<StrokePoint> points, {int window = 7}) {
  if (points.length < 3 || window < 2) return points;
  final half = window ~/ 2;
  return [
    for (var i = 0; i < points.length; i++)
      if (i == 0 || i == points.length - 1)
        points[i]
      else
        () {
          final from = math.max(0, i - half);
          final to = math.min(points.length - 1, i + half);
          var x = 0.0;
          var y = 0.0;
          for (var j = from; j <= to; j++) {
            x += points[j].x;
            y += points[j].y;
          }
          final n = to - from + 1;
          return StrokePoint(x: x / n, y: y / n, pressure: points[i].pressure);
        }(),
  ];
}
