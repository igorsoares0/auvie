import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/photo/photo_editor_screen.dart';
import 'package:auvie/features/export/export_options.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_media_engine.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  late TestApp app;

  /// Editor → Export, so BACK TO EDIT has somewhere to go.
  Future<void> openExport(
    WidgetTester tester, {
    FakeMediaEngine? engine,
  }) async {
    app = (await tester.runAsync(() => TestApp.create(engine: engine)))!;
    final project = (await tester.runAsync(
      () => app.container
          .read(projectRepositoryProvider)
          .create(photoMedia, name: 'Roll 014 · 07'),
    ))!;
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.photoEditor(project.id)));
    await tester.pumpAndSettle();
    await tapKey(tester, 'editor-export');
  }

  testWidgets('shows the summary and the options', (tester) async {
    await openExport(tester);
    expect(find.text('Export'), findsOneWidget);
    expect(find.text('4000 × 3000 · 4:3'), findsOneWidget);
    expect(find.text('Smallest'), findsOneWidget);
    expect(find.text('12 MP'), findsNWidgets(2)); // Original and Large.
    expect(find.text('SAVE TO PHOTOS'), findsOneWidget);
  });

  testWidgets('options apply to the export', (tester) async {
    await openExport(tester);
    await tapKey(tester, 'format-png');
    await tapKey(tester, 'size-web');
    await tapKey(tester, 'export-metadata');
    await tapKey(tester, 'export-save');

    final job = app.engine.exports.single;
    expect(job.format, ExportFormat.png);
    expect(
      job.outputWidth * job.outputHeight,
      lessThanOrEqualTo(ExportSize.web.maxPixels),
    );
    expect(job.keepMetadata, isTrue);
  });

  testWidgets('saving develops the frame, then shows the print', (
    tester,
  ) async {
    final engine = FakeMediaEngine()..exportGate = Completer<void>();
    await openExport(tester, engine: engine);

    await tester.tap(find.byKey(const Key('export-save')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Developing frame 07…'), findsOneWidget);

    engine.emitProgress(engine.runningJob!, 0.62);
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('62', findRichText: true), findsWidgets);

    engine.exportGate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('SAVED TO PHOTOS'), findsOneWidget);
    expect(
      find.textContaining('Beautifully', findRichText: true),
      findsOneWidget,
    );

    await tapKey(tester, 'export-done-share');
    expect(app.share.shared, ['/files/exports/Roll 014 · 07.jpg']);
    await tapKey(tester, 'export-done-copy');
    expect(engine.copied, ['content://media/external/images/media/1']);

    await tapKey(tester, 'export-back-to-edit');
    expect(find.byType(PhotoEditorScreen), findsOneWidget);
  });

  testWidgets('cancel goes back to the options with them kept', (tester) async {
    final engine = FakeMediaEngine()..exportGate = Completer<void>();
    await openExport(tester, engine: engine);
    await tapKey(tester, 'format-png');

    await tester.tap(find.byKey(const Key('export-save')));
    await tester.pump();
    await tester.pump();
    await tapKey(tester, 'export-cancel');

    expect(find.text('SAVE TO PHOTOS'), findsOneWidget);
    expect(engine.cancelled, hasLength(1));
    await tapKey(tester, 'export-save');
    expect(engine.exports.last.format, ExportFormat.png);
  });

  testWidgets('share… exports and opens the share sheet', (tester) async {
    await openExport(tester);
    await tapKey(tester, 'export-share');
    expect(app.share.shared, hasLength(1));
    expect(find.text('SAVED TO PHOTOS'), findsOneWidget);
  });

  testWidgets('short storage offers a smaller export', (tester) async {
    final engine = FakeMediaEngine()..freeBytes = 1000;
    await openExport(tester, engine: engine);
    await tapKey(tester, 'export-save');

    expect(find.text('NOT SAVED · STORAGE FULL'), findsOneWidget);
    expect(find.text('EXPORT LARGE · 12 MP'), findsOneWidget);

    engine.freeBytes = 1 << 40;
    await tapKey(tester, 'export-smaller');
    expect(find.text('SAVED TO PHOTOS'), findsOneWidget);
    final job = engine.exports.single;
    expect(
      job.outputWidth * job.outputHeight,
      lessThanOrEqualTo(ExportSize.large.maxPixels),
    );
  });

  testWidgets('other errors keep the edit and allow a retry', (tester) async {
    final engine = FakeMediaEngine()
      ..exportError = const MediaEngineException(MediaEngineError.exportFailed);
    await openExport(tester, engine: engine);
    await tapKey(tester, 'export-save');

    expect(find.text('NOT SAVED'), findsOneWidget);
    expect(find.byKey(const Key('export-smaller')), findsNothing);

    engine.exportError = null;
    await tapKey(tester, 'export-retry');
    expect(find.text('SAVED TO PHOTOS'), findsOneWidget);
  });
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}
