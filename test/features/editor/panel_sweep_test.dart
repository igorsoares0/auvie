import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/video_timeline.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/adjustments/adjustment_family.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';
import '../home/home_screen_test.dart' show summary;

/// Walks every editor panel, tab and mode, on the handoff's phone and on a
/// small one, and checks that nothing overflows and that no control has
/// collapsed to nothing (the CURVE area once laid out 0 px wide: invisible
/// and untouchable, with every other test still green).
void main() {
  const screens = {
    'phone': Size(1170, 2532), // 390 × 844 pt at 3x, the handoff's.
    'small phone': Size(1080, 2160), // 360 × 720 pt.
  };

  late TestApp app;

  void useScreen(WidgetTester tester, Size size) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 3;
  }

  /// Every gesture area and slider on screen has a size.
  void expectNoCollapsedControls(WidgetTester tester, String state) {
    final collapsed = <String>[];
    final controls = find.byWidgetPredicate(
      (w) => w is GestureDetector || w is Slider,
    );
    for (final element in controls.evaluate()) {
      final box = element.renderObject;
      if (box is! RenderBox || !box.hasSize) continue;
      if (box.size.width < 1 || box.size.height < 1) {
        final widget = element.widget;
        collapsed.add('${widget.key ?? widget.runtimeType}: ${box.size}');
      }
    }
    expect(collapsed, isEmpty, reason: 'collapsed controls in $state');
    expect(tester.takeException(), isNull, reason: state);
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> visit(WidgetTester tester, String key) async {
    await tapKey(tester, key);
    expectNoCollapsedControls(tester, key);
  }

  for (final MapEntry(key: screenName, value: size) in screens.entries) {
    testWidgets('photo editor, every panel, $screenName', (tester) async {
      app = (await tester.runAsync(TestApp.create))!;
      final project = (await tester.runAsync(
        () => app.container
            .read(projectRepositoryProvider)
            .create(photoMedia, name: 'Roll 014 · 07'),
      ))!;
      await tester.pumpTestApp(app);
      useScreen(tester, size);
      unawaited(app.router.push(AppRoutes.photoEditor(project.id)));
      await tester.pumpAndSettle();
      expectNoCollapsedControls(tester, 'film');

      // FILM: a film with its intensity row, then the empty SAVED list.
      await visit(tester, 'preset-ektar_02');
      await visit(tester, 'category-saved');

      // ADJUST: every family.
      await visit(tester, 'tool-adjust');
      for (final family in AdjustmentFamily.values) {
        await visit(tester, 'family-${family.name}');
      }

      // TYPE: empty, typing, a selected text, then TEXT BRUSH.
      await visit(tester, 'tool-type');
      await visit(tester, 'elements-gestures');
      await tester.enterText(find.byKey(const Key('text-input')), 'Riviera');
      await tester.pump();
      expectNoCollapsedControls(tester, 'typing');
      await visit(tester, 'typing-done');
      await visit(tester, 'type-mode-Text brush');

      // ADD: a selected sticker, an overlay with its controls, a frame.
      await visit(tester, 'tool-add');
      await visit(tester, 'asset-sticker_star');
      await visit(tester, 'add-tab-Overlays');
      await visit(tester, 'asset-overlay_leak_warm');
      await visit(tester, 'add-tab-Frames');
      await visit(tester, 'asset-frame_paper');

      // The edit actions sheet, then EXPORT.
      await visit(tester, 'editor-title');
      await tester.tapAt(const Offset(10, 10)); // Outside the sheet.
      await tester.pumpAndSettle();
      await visit(tester, 'editor-export');
      await tester.pump(EditorController.saveDelay);
    });

    testWidgets('every other screen, $screenName', (tester) async {
      app = (await tester.runAsync(
        () => TestApp.create(recents: [summary('p1', name: 'Roll 001 · 01')]),
      ))!;
      await tester.pumpTestApp(app);
      useScreen(tester, size);
      await tester.pumpAndSettle();
      expectNoCollapsedControls(tester, 'home');

      await tester.longPress(find.byKey(const Key('recent-p1')));
      await tester.pumpAndSettle();
      expectNoCollapsedControls(tester, 'edit actions');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      for (final route in [
        AppRoutes.archive,
        AppRoutes.settings,
        AppRoutes.pro,
        AppRoutes.onboarding,
      ]) {
        app.router.go(route);
        await tester.pumpAndSettle();
        expectNoCollapsedControls(tester, route);
      }
    });

    testWidgets('video editor, every panel, $screenName', (tester) async {
      app = (await tester.runAsync(TestApp.create))!;
      final repository = app.container.read(projectRepositoryProvider);
      final project = (await tester.runAsync(() async {
        final created = await repository.create(videoMedia, name: 'Film 012');
        return await repository.save(
          created.copyWith(
            edit: created.edit.copyWith(
              video: const VideoTimeline(trimStartMs: 900, trimEndMs: 9100),
              elements: const [
                EditElement.text(
                  id: 'text',
                  text: 'After the rain',
                  time: TimeRange(startMs: 1400, endMs: 5600),
                ),
                EditElement.sticker(
                  id: 'star',
                  assetId: 'star',
                  time: TimeRange(startMs: 1000, endMs: 3000),
                ),
              ],
            ),
          ),
        );
      }))!;
      await tester.pumpTestApp(app);
      useScreen(tester, size);
      unawaited(app.router.push(AppRoutes.videoEditor(project.id)));
      await tester.pumpAndSettle();
      expectNoCollapsedControls(tester, 'trim');

      await visit(tester, 'tool-film');
      await visit(tester, 'preset-ektar_02');
      await visit(tester, 'tool-adjust');
      for (final family in AdjustmentFamily.values) {
        await visit(tester, 'family-${family.name}');
      }
      await visit(tester, 'tool-type');
      await visit(tester, 'type-mode-Text brush');
      await visit(tester, 'tool-add');
      await visit(tester, 'add-tab-Overlays');
      await visit(tester, 'add-tab-Frames');
      await visit(tester, 'tool-trim');
      await visit(tester, 'editor-export');
      await tester.pump(EditorController.saveDelay);
    });
  }
}
