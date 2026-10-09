import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/storage/project_repository.dart';
import 'package:auvie/features/archive/archive_screen.dart';
import 'package:auvie/features/editor/photo/photo_editor_screen.dart';
import 'package:auvie/features/editor/video/video_editor_screen.dart';
import 'package:auvie/features/home/home_screen.dart';
import 'package:auvie/features/subscription/pro_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_media_engine.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

ProjectSummary summary(
  String id, {
  MediaType type = MediaType.photo,
  String? name,
  String? presetId,
  int? durationMs,
}) => (
  id: id,
  mediaType: type,
  mediaUri: 'content://$id',
  thumbnailPath: null,
  updatedAt: DateTime.utc(2026),
  name: name,
  presetId: presetId,
  durationMs: durationMs,
);

void main() {
  Future<TestApp> pumpHome(
    WidgetTester tester, {
    List<ProjectSummary> recents = const [],
    FakeMediaEngine? engine,
  }) async {
    final app = (await tester.runAsync(
      () => TestApp.create(recents: recents, engine: engine),
    ))!;
    await tester.pumpTestApp(app);
    return app;
  }

  testWidgets('first use shows empty frames and the first-print line', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.textContaining('print', findRichText: true), findsOneWidget);
    expect(find.text('NONE YET'), findsOneWidget);
    expect(find.textContaining('exactly where you left them'), findsOneWidget);
    expect(find.text('START WITH A COLLECTION'), findsOneWidget);
  });

  testWidgets('recent work shows as a contact sheet', (tester) async {
    await pumpHome(
      tester,
      recents: [
        summary('a', name: 'Roll 001 · 02', presetId: 'ektar_02'),
        summary(
          'b',
          type: MediaType.video,
          name: 'Roll 001 · 01',
          durationMs: 14000,
        ),
      ],
    );
    expect(
      find.textContaining('developing', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('ON THIS DEVICE · 2'), findsOneWidget);
    expect(find.text('Roll 001 · 02'), findsOneWidget);
    expect(find.text('PHOTO · EKTAR 02'), findsOneWidget);
    expect(find.text('VIDEO · ORIGINAL'), findsOneWidget);
    expect(find.text('0:14'), findsOneWidget);
    expect(find.text('NEW COLLECTION'), findsOneWidget);
  });

  testWidgets('Photo picks a photo and opens the editor', (tester) async {
    final app = await pumpHome(
      tester,
      engine: FakeMediaEngine(picked: photoMedia),
    );

    await tester.tap(find.byKey(const Key('home-photo')));
    await tester.pumpAndSettle();

    expect(find.byType(PhotoEditorScreen), findsOneWidget);
    expect(app.engine.calls, contains('pickMedia(photo)'));
    expect(app.thumbnails.refreshed, hasLength(1));
    expect(find.text('Roll 001'), findsNothing); // Title is split in spans.
    expect(find.textContaining('01', findRichText: true), findsWidgets);
  });

  testWidgets('Video opens the video editor', (tester) async {
    await pumpHome(tester, engine: FakeMediaEngine(picked: videoMedia));
    await tester.tap(find.byKey(const Key('home-video')));
    await tester.pumpAndSettle();
    expect(find.byType(VideoEditorScreen), findsOneWidget);
  });

  testWidgets('cancelling the picker stays on Home', (tester) async {
    await pumpHome(tester, engine: FakeMediaEngine());
    await tester.tap(find.byKey(const Key('home-photo')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('a recent opens its editor', (tester) async {
    await pumpHome(tester, recents: [summary('x', name: 'Roll 001 · 01')]);
    await tester.tap(find.text('Roll 001 · 01'));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoEditorScreen), findsOneWidget);
  });

  testWidgets('PRO and DISCOVER lead to their screens', (tester) async {
    final app = await pumpHome(tester);
    await tester.tap(find.byKey(const Key('home-pro')));
    await tester.pumpAndSettle();
    expect(find.byType(ProScreen), findsOneWidget);

    app.router.pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-discover')));
    await tester.pumpAndSettle();
    expect(find.byType(ArchiveScreen), findsOneWidget);
  });
}
