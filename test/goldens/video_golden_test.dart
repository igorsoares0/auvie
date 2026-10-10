@Tags(['golden'])
library;

import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/video_timeline.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';

void main() {
  /// The handoff 05 frame: trimmed, a text, a stroke and a sticker on the
  /// lanes, the playhead at 00:04.12.
  Future<(TestApp, String)> openVideo(
    WidgetTester tester,
    Brightness brightness,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final app = (await tester.runAsync(TestApp.create))!;
    final repository = app.container.read(projectRepositoryProvider);
    final created = (await tester.runAsync(
      () => repository.create(videoMedia, name: 'Film 012'),
    ))!;
    final project = created.copyWith(
      edit: created.edit.copyWith(
        video: const VideoTimeline(trimStartMs: 900, trimEndMs: 9100),
        elements: const [
          EditElement.text(
            id: 'text',
            text: 'After the rain',
            transform: ElementTransform(y: 0.8),
            time: TimeRange(startMs: 1400, endMs: 5600),
          ),
          EditElement.brush(
            id: 'stroke',
            strokes: [
              BrushStroke(
                points: [
                  StrokePoint(x: 0.2, y: 0.3),
                  StrokePoint(x: 0.5, y: 0.25),
                  StrokePoint(x: 0.8, y: 0.35),
                ],
              ),
            ],
            time: TimeRange(startMs: 4800, endMs: 8600),
          ),
          EditElement.sticker(
            id: 'star',
            assetId: 'star',
            time: TimeRange(startMs: 1000, endMs: 3000),
          ),
        ],
      ),
    );
    await tester.runAsync(() => repository.save(project));
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.videoEditor(project.id)));
    await tester.pumpAndSettle();
    app.engine.emitPlayback(1, 5020);
    await tester.pumpAndSettle();
    return (app, project.id);
  }

  Future<void> expectScreen(String name) => expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('screens/$name.png'),
  );

  for (final brightness in Brightness.values) {
    testWidgets('video trim, ${brightness.name}', (tester) async {
      final (app, id) = await openVideo(tester, brightness);
      app.container
          .read(editorControllerProvider(id).notifier)
          .selectElement('text');
      await tester.pumpAndSettle();
      await expectScreen('editor_video_${brightness.name}');
      await tester.pump(EditorController.saveDelay);
    });
  }

  testWidgets('video export, dark', (tester) async {
    await openVideo(tester, Brightness.dark);
    await tester.tap(find.byKey(const Key('editor-export')));
    await tester.pumpAndSettle();
    await expectScreen('export_video_dark');
  });
}
