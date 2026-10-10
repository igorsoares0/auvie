import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/video_timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const duration = 10000;
  const timeline = VideoTimeline();

  test('untrimmed clip plays whole', () {
    expect(timeline.endMs(duration), duration);
    expect(timeline.trimmedDurationMs(duration), duration);
  });

  test('stores trim handles', () {
    final t = timeline.withTrim(
      durationMs: duration,
      startMs: 2000,
      endMs: 8000,
    );
    expect(t.trimStartMs, 2000);
    expect(t.trimEndMs, 8000);
    expect(t.trimmedDurationMs(duration), 6000);
  });

  test('an end at the clip end is stored as open', () {
    final t = timeline.withTrim(durationMs: duration, endMs: duration);
    expect(t.trimEndMs, isNull);
  });

  test('keeps handles inside the clip', () {
    final t = timeline.withTrim(
      durationMs: duration,
      startMs: -300,
      endMs: 12000,
    );
    expect(t.trimStartMs, 0);
    expect(t.trimEndMs, isNull);
  });

  test('keeps the minimum duration when the start moves', () {
    final t = timeline.withTrim(durationMs: duration, startMs: 9800);
    expect(t.trimStartMs, duration - VideoTimeline.minDurationMs);
  });

  test('keeps the minimum duration when the end moves', () {
    final t = timeline
        .withTrim(durationMs: duration, startMs: 2000)
        .withTrim(durationMs: duration, endMs: 2100);
    expect(t.trimStartMs, 2000);
    expect(t.trimEndMs, 2000 + VideoTimeline.minDurationMs);
  });

  test('moving both handles keeps them in order', () {
    final t = timeline.withTrim(
      durationMs: duration,
      startMs: 9900,
      endMs: 100,
    );
    expect(t.trimStartMs, duration - VideoTimeline.minDurationMs);
    expect(t.trimEndMs, isNull);
  });

  test('a stale end beyond a shorter clip is pulled back', () {
    const stale = VideoTimeline(trimStartMs: 1000, trimEndMs: 20000);
    final t = stale.withTrim(durationMs: duration, startMs: 1200);
    expect(t.trimStartMs, 1200);
    expect(t.trimEndMs, isNull);
  });

  test('a stale start beyond a shorter clip is pulled back', () {
    const stale = VideoTimeline(trimStartMs: 15000);
    final t = stale.withTrim(durationMs: duration, endMs: 8000);
    // The start is pulled into the clip, then the end keeps the minimum gap.
    expect(t.trimStartMs, duration - VideoTimeline.minDurationMs);
    expect(t.trimEndMs, isNull);
  });

  test('clips shorter than the minimum are not trimmed', () {
    final t = timeline.withTrim(durationMs: 400, startMs: 100, endMs: 300);
    expect(t, const VideoTimeline());
  });

  test('round-trips through JSON', () {
    const t = VideoTimeline(trimStartMs: 100, trimEndMs: 900, muted: true);
    expect(VideoTimeline.fromJson(t.toJson()), t);
  });

  group('defaultElementTime', () {
    const trimmed = VideoTimeline(trimStartMs: 1000, trimEndMs: 8000);

    test('runs from the playhead to the end of the trim', () {
      expect(
        trimmed.defaultElementTime(playheadMs: 3000, durationMs: duration),
        const TimeRange(startMs: 3000, endMs: 8000),
      );
      expect(
        timeline.defaultElementTime(playheadMs: 0, durationMs: duration),
        const TimeRange(startMs: 0, endMs: duration),
      );
    });

    test('a playhead outside the trim starts inside it', () {
      expect(
        trimmed.defaultElementTime(playheadMs: 200, durationMs: duration),
        const TimeRange(startMs: 1000, endMs: 8000),
      );
    });

    test('near the end it starts earlier to stay visible', () {
      expect(
        trimmed.defaultElementTime(playheadMs: 7900, durationMs: duration),
        const TimeRange(startMs: 7700, endMs: 8000),
      );
    });
  });
}
