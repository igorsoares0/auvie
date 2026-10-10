import 'dart:convert';

import 'package:auvie/core/models/elements.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  for (final element in allElements) {
    test('${element.runtimeType} round-trips through JSON text', () {
      final json = jsonDecode(jsonEncode(element)) as Map<String, dynamic>;
      expect(EditElement.fromJson(json), element);
    });
  }

  test('JSON names the variant in "type"', () {
    final types = [for (final e in allElements) e.toJson()['type']];
    expect(types, ['text', 'textPath', 'brush', 'sticker', 'overlay', 'frame']);
  });

  test('pressure is optional (devices without pressure, spec §22)', () {
    const point = StrokePoint(x: 0.1, y: 0.2);
    expect(StrokePoint.fromJson(point.toJson()).pressure, isNull);
  });

  test('TimeRange is start-inclusive and end-exclusive', () {
    const range = TimeRange(startMs: 1000, endMs: 2000);
    expect(range.contains(999), isFalse);
    expect(range.contains(1000), isTrue);
    expect(range.contains(1999), isTrue);
    expect(range.contains(2000), isFalse);
  });

  group('TimeRange', () {
    const range = TimeRange(startMs: 2000, endMs: 5000);

    test('contains its start, not its end', () {
      expect(range.contains(2000), isTrue);
      expect(range.contains(4999), isTrue);
      expect(range.contains(5000), isFalse);
      expect(range.durationMs, 3000);
    });

    test('moves inside the clip', () {
      expect(
        range.moved(4000, durationMs: 8000),
        const TimeRange(startMs: 5000, endMs: 8000),
      );
      expect(
        range.moved(-9000, durationMs: 8000),
        const TimeRange(startMs: 0, endMs: 3000),
      );
    });

    test('resizes, keeping the minimum length', () {
      expect(
        range.resized(durationMs: 8000, startMs: 4900),
        const TimeRange(startMs: 4700, endMs: 5000),
      );
      expect(
        range.resized(durationMs: 8000, endMs: 9000),
        const TimeRange(startMs: 2000, endMs: 8000),
      );
    });
  });

  group('element timing', () {
    test('elements without a time always show', () {
      final sticker = allElements.firstWhere((e) => e is StickerElement);
      expect(sticker.time, isNull);
      expect(sticker.visibleAt(99999), isTrue);
    });

    test('timed elements show only in their range', () {
      final text = allElements.first;
      expect(text.visibleAt(500), isFalse);
      expect(text.visibleAt(1000), isTrue);
      expect(text.visibleAt(4000), isFalse);
    });

    test('every timed type takes a new time; frames ignore it', () {
      const time = TimeRange(startMs: 10, endMs: 20);
      for (final element in allElements) {
        final timed = element.withTime(time);
        expect(timed.time, element is FrameElement ? isNull : time);
      }
    });
  });
}
