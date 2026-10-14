import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/home/home_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_media_engine.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';
import '../home/home_screen_test.dart' show summary;

void main() {
  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('holding a recent edit asks, then deletes it', (tester) async {
    final app = (await tester.runAsync(
      () => TestApp.create(recents: [summary('p1', name: 'Roll 001 · 01')]),
    ))!;
    await tester.pumpTestApp(app);

    await tester.longPress(find.byKey(const Key('recent-p1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('delete-sheet')), findsOneWidget);
    expect(
      find.text('Delete Roll 001 · 01?', findRichText: true),
      findsOneWidget,
    );
    await tapKey(tester, 'delete-cancel');
    expect(app.engine.released, isEmpty);

    await tester.longPress(find.byKey(const Key('recent-p1')));
    await tester.pumpAndSettle();
    await tapKey(tester, 'delete-confirm');
    expect(app.engine.released, ['content://p1']);
  });

  testWidgets('an edit whose original is gone offers to delete it', (
    tester,
  ) async {
    final app = (await tester.runAsync(
      () => TestApp.create(
        engine: FakeMediaEngine()
          ..previewError = const MediaEngineException(
            MediaEngineError.mediaUnavailable,
          ),
      ),
    ))!;
    final repository = app.container.read(projectRepositoryProvider);
    final project = (await tester.runAsync(
      () => repository.create(photoMedia, name: 'Roll 014 · 07'),
    ))!;
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.photoEditor(project.id)));
    await tester.pumpAndSettle();

    expect(
      find.text('The original was moved or deleted. Your edit is safe.'),
      findsOneWidget,
    );
    await tapKey(tester, 'preview-delete');
    await tapKey(tester, 'delete-confirm');

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(await tester.runAsync(() => repository.find(project.id)), isNull);
    expect(app.engine.released, [photoMedia.uri]);
  });
}
