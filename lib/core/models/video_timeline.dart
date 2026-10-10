import 'dart:math' as math;

import 'package:auvie/core/models/elements.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_timeline.freezed.dart';
part 'video_timeline.g.dart';

/// Trim and sound settings of a video project (spec §16–17).
@freezed
abstract class VideoTimeline with _$VideoTimeline {
  const factory({
    @Default(0) int trimStartMs,

    /// Null means the end of the clip.
    int? trimEndMs,
    @Default(false) bool muted,
  }) = _VideoTimeline;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$VideoTimelineFromJson(json);

  /// Shortest clip the trim handles allow.
  static const minDurationMs = 500;

  int endMs(int durationMs) => trimEndMs ?? durationMs;

  int trimmedDurationMs(int durationMs) => endMs(durationMs) - trimStartMs;

  /// Moves the trim handles, keeping them inside the clip and at least
  /// [minDurationMs] apart. Clips shorter than that are not trimmed.
  VideoTimeline withTrim({required int durationMs, int? startMs, int? endMs}) {
    if (durationMs <= minDurationMs) {
      return copyWith(trimStartMs: 0, trimEndMs: null);
    }
    var start = startMs ?? trimStartMs;
    var end = math.min(endMs ?? this.endMs(durationMs), durationMs);
    // A moving start yields to a fixed end; otherwise only the clip bounds it.
    final startLimit = startMs != null && endMs == null ? end : durationMs;
    start = start.clamp(0, math.max(0, startLimit - minDurationMs));
    end = end.clamp(start + minDurationMs, durationMs);
    return copyWith(
      trimStartMs: start,
      trimEndMs: end == durationMs ? null : end,
    );
  }

  /// When a new element shows (decision M6): from the playhead to the end
  /// of the trim, starting earlier if less than [TimeRange.minDurationMs]
  /// is left.
  TimeRange defaultElementTime({
    required int playheadMs,
    required int durationMs,
  }) {
    final end = endMs(durationMs);
    final minimum = math.min(TimeRange.minDurationMs, end - trimStartMs);
    final start = playheadMs.clamp(trimStartMs, end - minimum);
    return TimeRange(startMs: start, endMs: end);
  }
}
