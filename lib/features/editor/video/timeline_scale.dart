import 'dart:math' as math;

import 'package:auvie/core/models/elements.dart';
import 'package:flutter/foundation.dart';

/// Maps the whole clip onto [width] pixels of the timeline (handoff 05:
/// the FILM strip shows the entire clip, veiled outside the trim).
@immutable
class TimelineScale {
  const new({required this.durationMs, required this.width});

  final int durationMs;
  final double width;

  double xOf(int ms) =>
      durationMs <= 0 ? 0 : (ms / durationMs * width).clamp(0, width);

  int msAt(double x) => durationMs <= 0 || width <= 0
      ? 0
      : (x / width * durationMs).round().clamp(0, durationMs);

  /// A distance in pixels as a duration.
  int msFor(double dx) => width <= 0 ? 0 : (dx / width * durationMs).round();

  /// Ruler marks, in ms: whole seconds at the smallest step that keeps
  /// labels [minSpacing] apart.
  List<int> ticks({double minSpacing = 36}) {
    if (durationMs <= 0 || width <= 0) return const [0];
    const steps = [1, 2, 3, 5, 10, 15, 30, 60, 120, 300, 600];
    final pxPerSecond = width / (durationMs / 1000);
    final step = steps.firstWhere(
      (s) => s * pxPerSecond >= minSpacing,
      orElse: () => steps.last,
    );
    return [for (var s = 0; s * 1000 <= durationMs; s += step) s * 1000];
  }

  @override
  bool operator ==(Object other) =>
      other is TimelineScale &&
      other.durationMs == durationMs &&
      other.width == width;

  @override
  int get hashCode => Object.hash(durationMs, width);
}

/// "00:04.12": minutes, seconds and hundredths.
String timecode(int ms) {
  final clamped = math.max(0, ms);
  final minutes = clamped ~/ 60000;
  final seconds = clamped ~/ 1000 % 60;
  final hundredths = clamped % 1000 ~/ 10;
  return '${_two(minutes)}:${_two(seconds)}.${_two(hundredths)}';
}

/// "00:10": minutes and seconds, rounded.
String shortTime(int ms) {
  final seconds = (math.max(0, ms) / 1000).round();
  return '${_two(seconds ~/ 60)}:${_two(seconds % 60)}';
}

String _two(int n) => n.toString().padLeft(2, '0');

/// What dragging a lane bar does.
enum BarDrag { move, start, end }

/// A bar of a TYPE / BRUSH / ADD lane.
typedef LaneBar = ({String id, TimeRange range});

/// Which bar is under [x], and what a drag there does. The selected bar
/// wins (its handles reach [handleSlop] past its ends), then the topmost
/// (last); only the selected bar can be resized.
({String id, BarDrag drag})? hitBar(
  List<LaneBar> bars,
  double x,
  TimelineScale scale, {
  String? selectedId,
  double handleSlop = 12,
}) {
  final selected = bars.where((b) => b.id == selectedId).firstOrNull;
  if (selected != null) {
    final left = scale.xOf(selected.range.startMs);
    final right = scale.xOf(selected.range.endMs);
    // Short bars split their width between the two handles.
    final slop = math.min(handleSlop, (right - left) / 2);
    if ((x - left).abs() <= slop) {
      return (id: selected.id, drag: BarDrag.start);
    }
    if ((x - right).abs() <= slop) return (id: selected.id, drag: BarDrag.end);
    if (x >= left && x <= right) return (id: selected.id, drag: BarDrag.move);
  }
  for (final bar in bars.reversed) {
    if (x >= scale.xOf(bar.range.startMs) && x <= scale.xOf(bar.range.endMs)) {
      return (id: bar.id, drag: BarDrag.move);
    }
  }
  return null;
}

/// [range] after dragging by [dx] pixels in [drag] mode.
TimeRange dragRange(
  TimeRange range,
  BarDrag drag,
  double dx,
  TimelineScale scale,
) {
  final delta = scale.msFor(dx);
  final duration = scale.durationMs;
  return switch (drag) {
    BarDrag.move => range.moved(delta, durationMs: duration),
    BarDrag.start => range.resized(
      durationMs: duration,
      startMs: range.startMs + delta,
    ),
    BarDrag.end => range.resized(
      durationMs: duration,
      endMs: range.endMs + delta,
    ),
  };
}
