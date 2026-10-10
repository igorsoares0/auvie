import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/video_timeline.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/video/video_editor_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_media_engine.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  late TestApp app;

  /// A trimmed, muted video with a timed text, from its editor to Export.
  Future<void> openExport(
    WidgetTester tester, {
    FakeMediaEngine? engine,
    bool muted = true,
  }) async {
    app = (await tester.runAsync(() => TestApp.create(engine: engine)))!;
    final repository = app.container.read(projectRepositoryProvider);
    final created = (await tester.runAsync(
      () => repository.create(videoMedia, name: 'Film 012'),
    ))!;
    final project = created.copyWith(
      edit: created.edit.copyWith(
        video: VideoTimeline(trimStartMs: 1000, trimEndMs: 9000, muted: muted),
        elements: const [
          EditElement.text(
            id: 't',
            text: 'After rain',
            time: TimeRange(startMs: 2000, endMs: 5000),
          ),
        ],
      ),
    );
    await tester.runAsync(() => repository.save(project));
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.videoEditor(project.id)));
    await tester.pumpAndSettle();
    await tapKey(tester, 'editor-export');
  }

  testWidgets('shows the video summary and its sizes', (tester) async {
    await openExport(tester);

    expect(find.text('Export'), findsOneWidget);
    // 1080p by default; 8 s kept by the trim.
    expect(find.textContaining('1080 × 1920 · 00:08 · ≈'), findsOneWidget);
    expect(find.text('720P'), findsOneWidget);
    expect(find.text('720 × 1280'), findsOneWidget);
    expect(find.byKey(const Key('video-size-original')), findsOneWidget);
    expect(find.text('Muted'), findsOneWidget);
    expect(find.byKey(const Key('format-jpeg')), findsNothing);
    expect(find.byKey(const Key('export-metadata')), findsNothing);
    // The poster is the first kept frame.
    expect(
      app.engine.calls,
      contains('renderVideoFrame(${videoMedia.uri}, 900, 1000)'),
    );
  });

  testWidgets('saving exports the trim, without sound, with timed layers', (
    tester,
  ) async {
    await openExport(tester);
    await tapKey(tester, 'video-size-p720');
    await tapKey(tester, 'export-save');

    final job = app.engine.videoExports.single;
    expect((job.outputWidth, job.outputHeight), (720, 1280));
    expect((job.trimStartMs, job.trimEndMs), (1000, 9000));
    expect(job.includeAudio, isFalse);
    expect(job.videoBitrate, 5529600);
    expect(job.fileName, 'Film 012');
    expect((job.layers.single.startMs, job.layers.single.endMs), (2000, 5000));
    expect(app.engine.notificationRequests, 1);

    expect(find.text('SAVED TO PHOTOS'), findsOneWidget);
    expect(find.byKey(const Key('export-done-copy')), findsNothing);
    expect(find.text('NEW VIDEO'), findsOneWidget);
    await tapKey(tester, 'export-done-share');
    expect(app.share.shared, ['/files/exports/Film 012.mp4']);

    // The notification question is asked once.
    await tapKey(tester, 'export-back-to-edit');
    expect(find.byType(VideoEditorScreen), findsOneWidget);
    await tapKey(tester, 'editor-export');
    await tapKey(tester, 'export-save');
    expect(app.engine.videoExports, hasLength(2));
    expect(app.engine.notificationRequests, 1);
  });

  testWidgets('sound goes out when not muted', (tester) async {
    await openExport(tester, muted: false);
    expect(find.text('Sound on'), findsOneWidget);
    await tapKey(tester, 'export-save');
    expect(app.engine.videoExports.single.includeAudio, isTrue);
  });

  testWidgets('short storage offers a smaller video', (tester) async {
    final engine = FakeMediaEngine()..freeBytes = 1000;
    await openExport(tester, engine: engine);

    await tapKey(tester, 'export-save');

    expect(find.byKey(const Key('export-error')), findsOneWidget);
    expect(find.text('EXPORT 720P · 720 × 1280'), findsOneWidget);
    engine.freeBytes = 1 << 40;
    await tapKey(tester, 'export-smaller');
    expect(app.engine.videoExports.single.outputWidth, 720);
  });

  testWidgets('a failed video export says so and keeps the edit', (
    tester,
  ) async {
    final engine = FakeMediaEngine()
      ..exportError = const MediaEngineException(MediaEngineError.exportFailed);
    await openExport(tester, engine: engine);

    await tapKey(tester, 'export-save');

    expect(
      find.textContaining("The video couldn't be", findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('cancelling stops the video export', (tester) async {
    final engine = FakeMediaEngine()..exportGate = Completer<void>();
    await openExport(tester, engine: engine);

    await tester.tap(find.byKey(const Key('export-save')));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('MP4 · 1080P'), findsOneWidget);

    await tapKey(tester, 'export-cancel');
    expect(engine.cancelled, hasLength(1));
    expect(find.byKey(const Key('export-save')), findsOneWidget);
    engine.exportGate!.complete();
    await tester.pumpAndSettle();
  });
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}
