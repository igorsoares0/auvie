import 'dart:math' as math;
import 'dart:ui';

import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/features/editor/elements/element_assets.dart';
import 'package:auvie/features/editor/elements/element_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const size = Size(1000, 800);
  const assets = ElementAssets(catalog: Catalog(catalogVersion: 1));

  EditElement sticker(
    String id, {
    double x = 0.5,
    double y = 0.5,
    double scale = 1,
    double rotation = 0,
  }) => EditElement.sticker(
    id: id,
    assetId: 'star',
    transform: ElementTransform(x: x, y: y, scale: scale, rotation: rotation),
  );

  test('a sticker is a square of 30% of the shorter side, centred', () {
    final frame = ElementGeometry.of(sticker('a'), size, assets)!;
    expect(frame.center, const Offset(500, 400));
    expect(frame.local.width, closeTo(240, 1e-9));
    expect(frame.bounds.center, const Offset(500, 400));
  });

  test('rotation and scale move the corners', () {
    final frame = ElementGeometry.of(
      sticker('a', scale: 2, rotation: math.pi / 4),
      size,
      assets,
    )!;
    // A square turned 45° is a diamond √2 × wider.
    expect(frame.bounds.width, closeTo(240 * 2 * math.sqrt2, 1e-6));
    expect(frame.contains(const Offset(500, 400)), isTrue);
    // The unrotated corner lies outside the diamond.
    expect(frame.contains(const Offset(500 + 239, 400 + 239)), isFalse);
  });

  test('hit picks the topmost element and respects the slop', () {
    final elements = [sticker('below'), sticker('above')];
    expect(
      ElementGeometry.hit(elements, const Offset(500, 400), size, assets),
      'above',
    );
    expect(
      ElementGeometry.hit(elements, const Offset(10, 10), size, assets),
      isNull,
    );
    // Just outside the sticker, within the finger slop.
    expect(
      ElementGeometry.hit(elements, const Offset(500 + 125, 400), size, assets),
      'above',
    );
  });

  test('overlays and frames are not movable', () {
    const overlay = EditElement.overlay(id: 'o', assetId: 'leak');
    expect(ElementGeometry.of(overlay, size, assets), isNull);
    expect(
      ElementGeometry.hit([overlay], const Offset(500, 400), size, assets),
      isNull,
    );
    expect(
      ElementGeometry.transformed(overlay, size, delta: const Offset(10, 0)),
      overlay,
    );
  });

  test('a brush is framed around its strokes and moves with its transform', () {
    const brush = EditElement.brush(
      id: 'b',
      strokes: [
        BrushStroke(
          points: [StrokePoint(x: 0.1, y: 0.1), StrokePoint(x: 0.3, y: 0.2)],
        ),
      ],
    );
    final frame = ElementGeometry.of(brush, size, assets)!;
    expect(frame.pivot.dx, closeTo(200, 1e-9));
    final moved = ElementGeometry.transformed(
      brush,
      size,
      delta: const Offset(100, 0),
    );
    expect(
      ElementGeometry.of(moved, size, assets)!.center.dx,
      closeTo(300, 1e-9),
    );
  });

  test('transforms accumulate and keep the scale within limits', () {
    var e = sticker('a');
    e = ElementGeometry.transformed(
      e,
      size,
      delta: const Offset(100, -80),
      scale: 1.5,
      rotation: 0.2,
    );
    final t = (e as StickerElement).transform;
    expect(t.x, closeTo(0.6, 1e-9));
    expect(t.y, closeTo(0.4, 1e-9));
    expect(t.scale, closeTo(1.5, 1e-9));
    expect(t.rotation, closeTo(0.2, 1e-9));
    final tiny =
        ElementGeometry.transformed(e, size, scale: 0.0001) as StickerElement;
    expect(tiny.transform.scale, 0.1);
  });

  test('a text box grows with its text', () {
    const short = EditElement.text(id: 't', text: 'Hi');
    const long = EditElement.text(id: 't', text: 'Hello there, Riviera');
    final a = ElementGeometry.of(short, size, assets)!.local.width;
    final b = ElementGeometry.of(long, size, assets)!.local.width;
    expect(b, greaterThan(a));
  });
}
