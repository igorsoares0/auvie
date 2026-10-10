import 'package:auvie/core/models/elements.dart';
import 'package:auvie/features/editor/video/timeline_scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scale = TimelineScale(durationMs: 10000, width: 300);

  group('TimelineScale', () {
    test('maps the whole clip onto the width', () {
      expect(scale.xOf(0), 0);
      expect(scale.xOf(5000), 150);
      expect(scale.xOf(10000), 300);
      expect(scale.msAt(150), 5000);
      expect(scale.msFor(30), 1000);
    });

    test('keeps positions inside the clip', () {
      expect(scale.xOf(-500), 0);
      expect(scale.xOf(12000), 300);
      expect(scale.msAt(-10), 0);
      expect(scale.msAt(400), 10000);
    });

    test('an empty clip maps everything to zero', () {
      const empty = TimelineScale(durationMs: 0, width: 300);
      expect(empty.xOf(1000), 0);
      expect(empty.msAt(100), 0);
      expect(empty.ticks(), [0]);
    });

    test('ruler ticks are whole seconds, far enough apart', () {
      // 30 px per second: 2 s steps would be 60 px; 1 s only 30.
      expect(scale.ticks(), [0, 2000, 4000, 6000, 8000, 10000]);
      expect(scale.ticks(minSpacing: 80), [0, 3000, 6000, 9000]);
      const long = TimelineScale(durationMs: 125000, width: 300);
      expect(long.ticks().take(3), [0, 15000, 30000]);
    });
  });

  group('timecodes', () {
    test('show minutes, seconds and hundredths', () {
      expect(timecode(0), '00:00.00');
      expect(timecode(4120), '00:04.12');
      expect(timecode(61999), '01:01.99');
      expect(timecode(-5), '00:00.00');
    });

    test('short times round to the second', () {
      expect(shortTime(10000), '00:10');
      expect(shortTime(9600), '00:10');
      expect(shortTime(125400), '02:05');
    });
  });

  group('hitBar', () {
    const a = (id: 'a', range: TimeRange(startMs: 1000, endMs: 5000));
    const b = (id: 'b', range: TimeRange(startMs: 4000, endMs: 8000));

    test('picks the topmost bar under the finger', () {
      // 4500 ms = 135 px is inside both: b is on top.
      expect(hitBar([a, b], 135, scale), (id: 'b', drag: BarDrag.move));
      expect(hitBar([a, b], 60, scale), (id: 'a', drag: BarDrag.move));
      expect(hitBar([a, b], 280, scale), isNull);
    });

    test('the selected bar wins over the ones above it', () {
      // 4600 ms = 138 px: within the handle reach of a's end (150 px).
      expect(hitBar([a, b], 140, scale, selectedId: 'a'), (
        id: 'a',
        drag: BarDrag.end,
      ));
      expect(hitBar([a, b], 125, scale, selectedId: 'a'), (
        id: 'a',
        drag: BarDrag.move,
      ));
    });

    test('only the selected bar has handles, reaching past its ends', () {
      expect(hitBar([a, b], 22, scale, selectedId: 'a'), (
        id: 'a',
        drag: BarDrag.start,
      ));
      expect(hitBar([a, b], 22, scale), isNull);
      expect(hitBar([a, b], 160, scale, selectedId: 'a'), (
        id: 'a',
        drag: BarDrag.end,
      ));
    });

    test('a short bar splits its width between the handles', () {
      const tiny = (id: 't', range: TimeRange(startMs: 5000, endMs: 5400));
      // 150…162 px: the left half starts, the right half ends.
      expect(hitBar([tiny], 152, scale, selectedId: 't'), (
        id: 't',
        drag: BarDrag.start,
      ));
      expect(hitBar([tiny], 160, scale, selectedId: 't'), (
        id: 't',
        drag: BarDrag.end,
      ));
    });
  });

  group('dragRange', () {
    const range = TimeRange(startMs: 2000, endMs: 5000);

    test('moving keeps the length and stays in the clip', () {
      expect(
        dragRange(range, BarDrag.move, 30, scale),
        const TimeRange(startMs: 3000, endMs: 6000),
      );
      expect(
        dragRange(range, BarDrag.move, 300, scale),
        const TimeRange(startMs: 7000, endMs: 10000),
      );
      expect(
        dragRange(range, BarDrag.move, -300, scale),
        const TimeRange(startMs: 0, endMs: 3000),
      );
    });

    test('handles move one end, keeping the minimum length', () {
      expect(
        dragRange(range, BarDrag.start, -30, scale),
        const TimeRange(startMs: 1000, endMs: 5000),
      );
      expect(
        dragRange(range, BarDrag.start, 300, scale),
        const TimeRange(startMs: 4700, endMs: 5000),
      );
      expect(
        dragRange(range, BarDrag.end, 300, scale),
        const TimeRange(startMs: 2000, endMs: 10000),
      );
      expect(
        dragRange(range, BarDrag.end, -300, scale),
        const TimeRange(startMs: 2000, endMs: 2300),
      );
    });
  });
}
