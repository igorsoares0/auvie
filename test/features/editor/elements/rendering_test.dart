import 'dart:io';
import 'dart:ui' as ui;

import 'package:auvie/core/content/catalog_source.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/storage/app_paths.dart';
import 'package:auvie/features/editor/elements/brush_renderer.dart';
import 'package:auvie/features/editor/elements/element_assets.dart';
import 'package:auvie/features/editor/elements/element_assets_provider.dart';
import 'package:auvie/features/editor/elements/elements_painter.dart';
import 'package:auvie/features/editor/elements/overlay_renderer.dart';
import 'package:auvie/features/editor/elements/stable_hash.dart';
import 'package:auvie/features/editor/elements/stroke_smoothing.dart';
import 'package:auvie/features/editor/elements/text_presets.dart';
import 'package:auvie/features/editor/shell/edit_caption.dart';
import 'package:auvie/features/export/element_layers.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Uint8List> _render(Size size, void Function(Canvas) draw) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder));
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.round(), size.height.round());
  final bytes = await image.toByteData();
  image.dispose();
  return bytes!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ElementAssets assets;
  setUpAll(() async {
    assets = await loadElementAssets(
      await BundledCatalogSource(rootBundle).load(),
    );
  });

  test('smoothing a line keeps its ends and calms the zigzag', () {
    final zigzag = [
      for (var i = 0; i < 20; i++)
        StrokePoint(x: i / 19, y: 0.5 + (i.isEven ? 0.05 : -0.05)),
    ];
    final smooth = smoothStroke(zigzag);
    expect(smooth.first, zigzag.first);
    expect(smooth.last, zigzag.last);
    double swing(List<StrokePoint> p) => p
        .sublist(3, 16)
        .map((s) => (s.y - 0.5).abs())
        .reduce((a, b) => a > b ? a : b);
    expect(swing(smooth), lessThan(swing(zigzag) / 3));
    expect(smoothStroke(zigzag.sublist(0, 2)), zigzag.sublist(0, 2));
  });

  test('stable hash does not change across runs', () {
    expect(stableHash('abc'), 0x1a47e90b);
    expect(stableHash(''), 0x811c9dc5);
  });

  test('text presets keep colour and STYLE options when switching', () {
    const current = TextStyleSpec(
      color: 0xFFE0573C,
      align: TextAlignment.left,
      shadow: TextShadowSpec(),
    );
    final hand = TextPreset.hand.apply(current);
    expect(hand.fontFamily, 'Caveat');
    expect(hand.color, 0xFFE0573C);
    expect(hand.align, TextAlignment.left);
    expect(hand.shadow, isNotNull);
    expect(TextPreset.grotesk.style.uppercase, isTrue);
    expect(TextPreset.byId('typewriter'), TextPreset.typewriter);
    expect(TextPreset.byId('nope'), isNull);
  });

  test('brushes and overlays draw the same every time', () async {
    Future<Uint8List> brush() => _render(const Size(120, 80), (canvas) {
      BrushRenderer.paintStroke(
        canvas,
        type: BrushType.chalk,
        points: const [Offset(10, 40), Offset(60, 20), Offset(110, 60)],
        pressure: const [null, null, null],
        width: 6,
        color: const Color(0xFFFFFFFF),
        seed: 42,
      );
    });
    expect(await brush(), await brush());

    Future<Uint8List> dust() => _render(const Size(120, 80), (canvas) {
      OverlayRenderer.paint(canvas, const Size(120, 80), const {
        'generator': 'dust',
      }, seed: 'x');
    });
    expect(await dust(), await dust());
  });

  test('every brush and overlay draws something', () async {
    for (final type in BrushType.values) {
      final pixels = await _render(const Size(80, 40), (canvas) {
        BrushRenderer.paintStroke(
          canvas,
          type: type,
          points: const [Offset(5, 20), Offset(40, 10), Offset(75, 30)],
          pressure: const [0.2, 0.8, 0.5],
          width: 3,
          color: const Color(0xFFFFFFFF),
          seed: 1,
        );
      });
      expect(pixels.any((b) => b != 0), isTrue, reason: type.name);
    }
    for (final generator in ['leak', 'burn', 'streak', 'dust', 'scratches']) {
      final pixels = await _render(const Size(80, 60), (canvas) {
        OverlayRenderer.paint(canvas, const Size(80, 60), {
          'generator': generator,
        }, seed: 'x');
      });
      expect(pixels.any((b) => b != 0), isTrue, reason: generator);
    }
  });

  group('export layers', () {
    const output = Size(4000, 3000);

    test('a sticker gets a tight layer, an overlay the whole frame', () {
      const sticker = EditElement.sticker(id: 's', assetId: 'sticker_star');
      final plan = FlutterElementRasterizer.plan(sticker, output, assets)!;
      expect(plan.bounds.center.dx, closeTo(2000, 1));
      expect(plan.bounds.width, lessThan(1500));
      expect(plan.scale, 1);

      const overlay = EditElement.overlay(
        id: 'o',
        assetId: 'overlay_leak_warm',
      );
      final full = FlutterElementRasterizer.plan(overlay, output, assets)!;
      expect(full.bounds, Offset.zero & output);
      expect(full.width, lessThanOrEqualTo(FlutterElementRasterizer.maxSide));
      expect(full.scale, 1); // 4000 px fits under the 4096 cap.
    });

    test('elements off the frame have no layer', () {
      const away = EditElement.sticker(
        id: 's',
        assetId: 'sticker_star',
        transform: ElementTransform(x: 5, y: 5),
      );
      expect(FlutterElementRasterizer.plan(away, output, assets), isNull);
    });

    test('rasterizes each element to a PNG with its place and blend', () async {
      final root = await Directory.systemTemp.createTemp('auvie_layers_');
      addTearDown(() => root.delete(recursive: true));
      final rasterizer = FlutterElementRasterizer(
        paths: Future.value(AppPaths(root)),
        assets: Future.value(assets),
      );
      final layers = await rasterizer.rasterize(
        jobId: 'job',
        elements: const [
          EditElement.text(id: 't', text: 'Riviera'),
          EditElement.overlay(
            id: 'o',
            assetId: 'overlay_leak_warm',
            opacity: 0.5,
          ),
          EditElement.frame(id: 'f', assetId: 'frame_paper'),
        ],
        output: (width: 1200, height: 900),
      );

      expect(layers, hasLength(3));
      expect(layers[1].blend, LayerBlend.screen);
      expect(layers[1].opacity, 0.5);
      expect(layers[2].width, 1200);
      for (final layer in layers) {
        final bytes = File(layer.path).readAsBytesSync();
        expect(bytes.sublist(1, 4), 'PNG'.codeUnits);
      }

      await rasterizer.clean('job');
      expect(File(layers.first.path).existsSync(), isFalse);
    });
  });

  test('the caption counts elements', () {
    final edit = const EditState()
        .addElement(const EditElement.sticker(id: 'a', assetId: 's'))
        .addElement(const EditElement.text(id: 'b', text: 'x'));
    expect(describeEdit(edit, null), 'Two elements');
  });

  test('ElementsPainter repaints only when something changes', () {
    final a = ElementsPainter(elements: const [], assets: assets);
    expect(
      a.shouldRepaint(ElementsPainter(elements: const [], assets: assets)),
      isFalse,
    );
    expect(
      a.shouldRepaint(
        ElementsPainter(
          elements: const [EditElement.frame(id: 'f', assetId: 'x')],
          assets: assets,
        ),
      ),
      isTrue,
    );
  });
}
