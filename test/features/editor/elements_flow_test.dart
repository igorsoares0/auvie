import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/photo/photo_editor_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  late TestApp app;
  late Project project;

  Future<void> openEditor(WidgetTester tester) async {
    app = (await tester.runAsync(TestApp.create))!;
    project = (await tester.runAsync(
      () => app.container
          .read(projectRepositoryProvider)
          .create(photoMedia, name: 'Roll 014 · 07'),
    ))!;
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.photoEditor(project.id)));
    await tester.pumpAndSettle();
  }

  List<EditElement> elements() => app.container
      .read(photoEditorProvider(project.id))
      .requireValue
      .edit
      .elements;

  String caption(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('editor-caption'))).data!;

  Future<void> settle(WidgetTester tester) =>
      tester.pump(PhotoEditor.saveDelay); // Let the autosave run.

  Future<void> addText(WidgetTester tester, String text) async {
    await tapKey(tester, 'tool-type');
    await tapKey(tester, 'elements-gestures');
    expect(find.byKey(const Key('text-input')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('text-input')), text);
    await tester.pump();
    await tapKey(tester, 'typing-done');
  }

  testWidgets('tapping the photo in TYPE adds a text', (tester) async {
    await openEditor(tester);
    await addText(tester, 'Riviera');

    final text = elements().single as TextElement;
    expect(text.text, 'Riviera');
    expect(text.style.fontFamily, 'Newsreader'); // Didone by default.
    expect(caption(tester), 'One element');
    await settle(tester);
  });

  testWidgets('CANCEL and empty texts leave nothing behind', (tester) async {
    await openEditor(tester);
    await tapKey(tester, 'tool-type');
    await tapKey(tester, 'elements-gestures');
    await tester.enterText(find.byKey(const Key('text-input')), 'Draft');
    await tapKey(tester, 'typing-cancel');
    expect(elements(), isEmpty);

    await tapKey(tester, 'elements-gestures');
    await tapKey(tester, 'typing-done');
    expect(elements(), isEmpty);
    expect(find.byKey(const Key('editor-undo')), findsOneWidget);
    await settle(tester);
  });

  testWidgets('EDIT retypes the text as one undo step', (tester) async {
    await openEditor(tester);
    await addText(tester, 'Riviera');

    await tapKey(tester, 'element-edit');
    await tester.enterText(find.byKey(const Key('text-input')), 'Marrakech');
    await tapKey(tester, 'typing-done');
    expect((elements().single as TextElement).text, 'Marrakech');

    await tapKey(tester, 'editor-undo');
    expect((elements().single as TextElement).text, 'Riviera');
    await settle(tester);
  });

  testWidgets('specimen, ink and STYLE apply to the selected text', (
    tester,
  ) async {
    await openEditor(tester);
    await addText(tester, 'Riviera');

    await tapKey(tester, 'preset-text-hand');
    await tapKey(tester, 'ink-ffe0573c');
    await tapKey(tester, 'text-style-shadow');
    await tapKey(tester, 'text-style-fill');
    await tapKey(tester, 'text-style-align');
    await tapKey(tester, 'text-style-opacity');

    final text = elements().single as TextElement;
    expect(text.style.fontFamily, 'Caveat');
    expect(text.textPresetId, 'hand');
    expect(text.style.color, 0xFFE0573C);
    expect(text.style.shadow, isNotNull);
    expect(text.style.background, isNotNull);
    expect(text.style.align, TextAlignment.right);
    expect(text.opacity, 0.75);
    await settle(tester);
  });

  testWidgets('TEXT BRUSH: draw a line, then type along it', (tester) async {
    await openEditor(tester);
    await tapKey(tester, 'tool-type');
    await tapKey(tester, 'type-mode-Text brush');
    expect(find.text('DRAW A LINE ON THE PHOTO'), findsOneWidget);

    final area = find.byKey(const Key('elements-draw'));
    final start = tester.getCenter(area) - const Offset(100, 0);
    final gesture = await tester.startGesture(start);
    for (var i = 1; i <= 8; i++) {
      await gesture.moveTo(
        start + Offset(i * 25.0, (i.isEven ? -1 : 1) * 15.0),
      );
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('text-input')),
      'after the rain',
    );
    await tapKey(tester, 'typing-done');
    final line = elements().single as TextPathElement;
    expect(line.text, 'after the rain');
    expect(line.path.length, greaterThan(4));
    await settle(tester);
  });

  testWidgets('drag moves the selection; duplicate and delete', (tester) async {
    await openEditor(tester);
    await tapKey(tester, 'tool-add');
    await tapKey(tester, 'asset-sticker_star');
    final before = (elements().single as StickerElement).transform.x;

    await tester.drag(
      find.byKey(const Key('elements-gestures')),
      const Offset(80, 0),
    );
    await tester.pumpAndSettle();
    expect(
      (elements().single as StickerElement).transform.x,
      greaterThan(before),
    );

    await tapKey(tester, 'element-duplicate');
    expect(elements(), hasLength(2));
    await tapKey(tester, 'element-delete');
    expect(elements(), hasLength(1));
    await tapKey(tester, 'editor-undo');
    expect(elements(), hasLength(2));
    await settle(tester);
  });

  testWidgets('BRUSH: each stroke is one undo step', (tester) async {
    await openEditor(tester);
    await tapKey(tester, 'tool-brush');
    final area = find.byKey(const Key('elements-draw'));

    await tester.drag(area, const Offset(120, 40));
    await tester.pumpAndSettle();
    await tester.drag(area, const Offset(-60, 80));
    await tester.pumpAndSettle();
    expect((elements().single as BrushElement).strokes, hasLength(2));

    await tapKey(tester, 'editor-undo');
    expect((elements().single as BrushElement).strokes, hasLength(1));

    await tapKey(tester, 'brush-chalk');
    await tester.drag(area, const Offset(50, 50));
    await tester.pumpAndSettle();
    expect(elements(), hasLength(2));
    expect((elements().last as BrushElement).brushType, BrushType.chalk);
    await settle(tester);
  });

  testWidgets('overlays toggle with opacity and blend; one frame at a time', (
    tester,
  ) async {
    await openEditor(tester);
    await tapKey(tester, 'tool-add');
    await tapKey(tester, 'add-tab-Overlays');
    await tapKey(tester, 'asset-overlay_leak_warm');

    var overlay = elements().single as OverlayElement;
    expect(overlay.blend, OverlayBlend.screen);
    expect(overlay.opacity, 0.8);

    await tapKey(tester, 'overlay-blend');
    overlay = elements().single as OverlayElement;
    expect(overlay.blend, OverlayBlend.softLight);

    await tapKey(tester, 'asset-overlay_leak_warm');
    expect(elements(), isEmpty);

    await tapKey(tester, 'add-tab-Frames');
    await tapKey(tester, 'asset-frame_paper');
    await tapKey(tester, 'asset-frame_print');
    expect((elements().single as FrameElement).assetId, 'frame_print');
    await tapKey(tester, 'asset-frame_print');
    expect(elements(), isEmpty);
    await settle(tester);
  });

  testWidgets('elements hide while cropping', (tester) async {
    await openEditor(tester);
    await tapKey(tester, 'tool-add');
    await tapKey(tester, 'asset-sticker_heart');
    expect(find.byKey(const Key('elements-paint')), findsOneWidget);

    await tapKey(tester, 'tool-adjust');
    await tapKey(tester, 'family-crop');
    expect(find.byKey(const Key('elements-paint')), findsNothing);
    await settle(tester);
  });

  testWidgets('export sends one layer per element', (tester) async {
    await openEditor(tester);
    await tapKey(tester, 'tool-add');
    await tapKey(tester, 'asset-sticker_sparkle');
    await tapKey(tester, 'add-tab-Frames');
    await tapKey(tester, 'asset-frame_film35');

    await tapKey(tester, 'editor-export');
    await tapKey(tester, 'export-save');

    expect(app.rasterizer.rasterized.single, hasLength(2));
    expect(app.engine.exports.single.layers, hasLength(2));
    expect(app.rasterizer.cleaned, hasLength(1));
  });
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}
