@Tags(['golden'])
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/content/catalog_source.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/elements/element_assets.dart';
import 'package:auvie/features/editor/elements/element_assets_provider.dart';
import 'package:auvie/features/editor/elements/elements_painter.dart';
import 'package:auvie/features/editor/elements/frame_renderer.dart';
import 'package:auvie/features/editor/elements/overlay_renderer.dart';
import 'package:auvie/features/editor/elements/text_presets.dart';
import 'package:auvie/features/editor/elements/text_renderer.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';

void main() {
  Future<TestApp> openEditor(WidgetTester tester, Brightness brightness) async {
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final app = (await tester.runAsync(TestApp.create))!;
    final project = (await tester.runAsync(
      () => app.container
          .read(projectRepositoryProvider)
          .create(photoMedia, name: 'Roll 014 · 07'),
    ))!;
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.photoEditor(project.id)));
    await tester.pumpAndSettle();
    return app;
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> expectScreen(String name) => expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('screens/$name.png'),
  );

  Future<void> drawWave(
    WidgetTester tester,
    Finder area, {
    double dy = 0,
  }) async {
    final start = tester.getCenter(area) - Offset(150, -dy);
    final gesture = await tester.startGesture(start);
    for (var i = 1; i <= 30; i++) {
      await gesture.moveTo(
        start + Offset(i * 10.0, -50 * math.sin(i / 30 * math.pi)),
      );
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  for (final brightness in Brightness.values) {
    testWidgets('type with text brush, ${brightness.name}', (tester) async {
      await openEditor(tester, brightness);
      await tap(tester, 'tool-type');
      await tap(tester, 'type-mode-Text brush');
      await drawWave(tester, find.byKey(const Key('elements-draw')));
      await tester.enterText(
        find.byKey(const Key('text-input')),
        'after the rain, Marrakech —',
      );
      await tap(tester, 'typing-done');
      await expectScreen('editor_type_${brightness.name}');
      await tester.pump(EditorController.saveDelay);
    });
  }

  testWidgets('set type: typing, then the selected text', (tester) async {
    await openEditor(tester, Brightness.dark);
    await tap(tester, 'tool-type');
    await tap(tester, 'elements-gestures');
    await tester.enterText(find.byKey(const Key('text-input')), 'Riviera');
    await tester.pump();
    await expectScreen('editor_typing_dark');
    await tap(tester, 'typing-done');
    await expectScreen('editor_type_set_dark');
    await tester.pump(EditorController.saveDelay);
  });

  testWidgets('tall panels on a small phone', (tester) async {
    await openEditor(tester, Brightness.dark);
    tester.view.physicalSize = const Size(1080, 2160); // 360 × 720 pt.
    await tester.pumpAndSettle();
    await tap(tester, 'tool-type');
    await tap(tester, 'elements-gestures');
    await tester.enterText(find.byKey(const Key('text-input')), 'Riviera');
    await tap(tester, 'typing-done');
    await expectScreen('editor_type_small_dark');
    await tap(tester, 'tool-add');
    await tap(tester, 'add-tab-Overlays');
    await tap(tester, 'asset-overlay_leak_warm');
    await expectScreen('editor_add_overlays_small_dark');
    await tap(tester, 'tool-adjust');
    await tap(tester, 'family-hsl');
    await expectScreen('editor_hsl_small_dark');
    await tester.pump(EditorController.saveDelay);
  });

  testWidgets('add, every tab', (tester) async {
    await openEditor(tester, Brightness.dark);
    await tap(tester, 'tool-add');
    await tap(tester, 'asset-sticker_star');
    await expectScreen('editor_add_stickers_dark');
    await tap(tester, 'add-tab-Overlays');
    await tap(tester, 'asset-overlay_leak_warm');
    await expectScreen('editor_add_overlays_dark');
    await tap(tester, 'add-tab-Frames');
    await tap(tester, 'asset-frame_film35');
    await expectScreen('editor_add_frames_dark');
    await tester.pump(EditorController.saveDelay);
  });

  group('drawing', () {
    late ElementAssets assets;
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      assets = await loadElementAssets(
        await BundledCatalogSource(rootBundle).load(),
      );
    });

    Widget canvas(CustomPainter painter) => Center(
      child: RepaintBoundary(
        child: SizedBox(
          width: 390,
          height: 520,
          child: ColoredBox(
            color: const Color(0xFF6F7A80),
            child: CustomPaint(painter: painter),
          ),
        ),
      ),
    );

    testWidgets('a composition of every element kind', (tester) async {
      await tester.pumpWidget(
        canvas(
          ElementsPainter(
            assets: assets,
            elements: const [
              EditElement.overlay(
                id: 'o',
                assetId: 'overlay_leak_warm',
                opacity: 0.8,
              ),
              EditElement.overlay(
                id: 'd',
                assetId: 'overlay_dust',
                blend: OverlayBlend.normal,
              ),
              EditElement.sticker(
                id: 's',
                assetId: 'sticker_sun',
                transform: ElementTransform(
                  x: 0.72,
                  y: 0.25,
                  scale: 0.6,
                  rotation: 0.2,
                ),
              ),
              EditElement.text(
                id: 't',
                text: 'Summer, 1998',
                style: TextStyleSpec(
                  fontFamily: 'Caveat',
                  fontSize: 0.09,
                  fontWeight: 500,
                  shadow: TextShadowSpec(),
                ),
                transform: ElementTransform(y: 0.62, rotation: -0.08),
              ),
              EditElement.textPath(
                id: 'p',
                text: 'along the line —',
                path: [
                  StrokePoint(x: 0.1, y: 0.82),
                  StrokePoint(x: 0.5, y: 0.74),
                  StrokePoint(x: 0.9, y: 0.82),
                ],
                style: TextStyleSpec(italic: true, fontSize: 0.055),
              ),
              EditElement.frame(id: 'f', assetId: 'frame_print'),
            ],
          ),
        ),
      );
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('screens/elements_composition.png'),
      );
    });

    /// Three columns of paintings over a neutral grey.
    Widget sheet(List<CustomPainter> painters) => Center(
      child: RepaintBoundary(
        child: SizedBox(
          width: 602,
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            textDirection: TextDirection.ltr,
            children: [
              for (final painter in painters)
                ClipRect(
                  child: SizedBox(
                    width: 198,
                    height: 148,
                    child: ColoredBox(
                      color: const Color(0xFF6F7A80),
                      child: CustomPaint(painter: painter),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    testWidgets('every frame', (tester) async {
      final frames = assets.catalog.assets.where(
        (a) => a.type == ContentAssetType.frame,
      );
      await tester.pumpWidget(
        sheet([for (final a in frames) _FramePainter(assets.params(a.id))]),
      );
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('screens/frames.png'),
      );
    });

    testWidgets('every sticker', (tester) async {
      final stickers = assets.catalog.assets.where(
        (a) => a.type == ContentAssetType.sticker,
      );
      await tester.pumpWidget(
        Center(
          child: RepaintBoundary(
            child: SizedBox(
              width: 600,
              child: Wrap(
                textDirection: TextDirection.ltr,
                children: [
                  for (final a in stickers)
                    SizedBox.square(
                      dimension: 100,
                      child: ColoredBox(
                        color: const Color(0xFF6F7A80),
                        child: CustomPaint(
                          painter: _StickerPainter(assets.stickers[a.id]!),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('screens/stickers.png'),
      );
    });

    testWidgets('every text preset', (tester) async {
      await tester.pumpWidget(
        Center(
          child: RepaintBoundary(
            child: Container(
              width: 760,
              color: const Color(0xFF15120F),
              child: Wrap(
                textDirection: TextDirection.ltr,
                children: [
                  for (final preset in TextPreset.values)
                    SizedBox(
                      width: 380,
                      height: 68,
                      child: Center(
                        child: Text(
                          preset.style.uppercase
                              ? 'CORAÇÃO, 12.08'
                              : 'Coração, 12.08',
                          textDirection: TextDirection.ltr,
                          maxLines: 1,
                          style: TextRenderer.textStyle(
                            preset.style.copyWith(color: 0xFFF6F0E6),
                            const Size(520, 520),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('screens/type_presets.png'),
      );
    });

    testWidgets('every overlay', (tester) async {
      final overlays = assets.catalog.assets.where(
        (a) => a.type == ContentAssetType.overlay,
      );
      await tester.pumpWidget(
        sheet([for (final a in overlays) _OverlayPainter(assets.params(a.id))]),
      );
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('screens/overlays.png'),
      );
    });
  });
}

class _OverlayPainter extends CustomPainter {
  new(this.params);

  final Map<String, Object?> params;

  @override
  void paint(Canvas canvas, Size size) =>
      OverlayRenderer.paint(canvas, size, params, seed: 'golden');

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) => false;
}

class _StickerPainter extends CustomPainter {
  new(this.sticker);

  final PictureInfo sticker;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..translate(14, 14)
      ..scale((size.width - 28) / sticker.size.width)
      ..drawPicture(sticker.picture);
  }

  @override
  bool shouldRepaint(_StickerPainter oldDelegate) => false;
}

class _FramePainter extends CustomPainter {
  new(this.params);

  final Map<String, Object?> params;

  @override
  void paint(Canvas canvas, Size size) =>
      FrameRenderer.paint(canvas, size, params);

  @override
  bool shouldRepaint(_FramePainter old) => false;
}
