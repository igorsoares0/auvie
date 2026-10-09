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
}
