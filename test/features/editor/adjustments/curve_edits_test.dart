import 'package:auvie/core/models/tone_curve.dart';
import 'package:auvie/features/editor/adjustments/curve_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const identity = ToneCurve();

  test('adds a point in x order', () {
    final (curve, index) = CurveEdits.add(identity, 0.5, 0.6);
    expect(index, 1);
    expect(curve.points.map((p) => (p.x, p.y)), [(0, 0), (0.5, 0.6), (1, 1)]);
  });

  test('refuses a point too close to another', () {
    final (curve, index) = CurveEdits.add(identity, 0.01, 0.5);
    expect(index, -1);
    expect(curve, identity);
  });

  test('moves middle points between their neighbours', () {
    final (curve, _) = CurveEdits.add(identity, 0.5, 0.5);
    final moved = CurveEdits.move(curve, 1, 2, 0.7);
    expect(moved.points[1].x, closeTo(1 - CurveEdits.minGap, 1e-9));
    expect(moved.points[1].y, 0.7);
  });

  test('endpoints only move vertically', () {
    final moved = CurveEdits.move(identity, 0, 0.4, 0.2);
    expect(moved.points.first.x, 0);
    expect(moved.points.first.y, 0.2);
  });

  test('removes middle points but keeps endpoints', () {
    final (curve, _) = CurveEdits.add(identity, 0.5, 0.5);
    expect(CurveEdits.remove(curve, 1), identity);
    expect(CurveEdits.remove(identity, 0), identity);
  });

  test('channels read and write the right curve', () {
    const red = ToneCurve(
      points: [CurvePoint(x: 0, y: 0.2), CurvePoint(x: 1, y: 1)],
    );
    final curves = const ToneCurves().withChannel(CurveChannel.red, red);
    expect(curves.channel(CurveChannel.red), red);
    expect(curves.channel(CurveChannel.rgb), identity);
    expect(curves.channel(CurveChannel.green), identity);
    expect(
      curves.withChannel(CurveChannel.blue, red).channel(CurveChannel.blue),
      red,
    );
  });
}
