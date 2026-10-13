import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/storage/database.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  late TestApp app;
  late String projectId;

  Future<void> openEditor(
    WidgetTester tester, {
    List<String> savedCollections = const [],
    List<String> savedStickers = const [],
  }) async {
    app = (await tester.runAsync(
      () => TestApp.create(
        savedCollections: savedCollections,
        savedStickers: savedStickers,
      ),
    ))!;
    final project = (await tester.runAsync(
      () => app.container
          .read(projectRepositoryProvider)
          .create(photoMedia, name: 'Roll 014 · 07'),
    ))!;
    projectId = project.id;
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.photoEditor(project.id)));
    await tester.pumpAndSettle();
  }

  double left(WidgetTester tester, String key) =>
      tester.getTopLeft(find.byKey(Key(key))).dx;

  testWidgets('saved collections come first in FILM', (tester) async {
    await openEditor(tester, savedCollections: ['night']);

    expect(
      left(tester, 'category-night'),
      lessThan(left(tester, 'category-film')),
    );
    await tester.pump(EditorController.saveDelay);
  });

  testWidgets('holding a sticker keeps it, and saved ones come first', (
    tester,
  ) async {
    await openEditor(tester, savedStickers: ['sticker_arrow']);
    await tester.tap(find.byKey(const Key('tool-add')));
    await tester.pumpAndSettle();

    expect(
      left(tester, 'asset-sticker_arrow'),
      lessThan(left(tester, 'asset-sticker_star')),
    );
    expect(find.byKey(const Key('asset-saved-sticker_arrow')), findsOneWidget);

    await tester.longPress(find.byKey(const Key('asset-sticker_star')));
    await tester.pumpAndSettle();
    final rows = (await tester.runAsync(
      () => app.db.select(app.db.favorites).get(),
    ))!;
    expect(rows.map((r) => (r.kind, r.itemId)), [
      (FavoriteKind.sticker, 'sticker_star'),
    ]);
    // Holding doesn't add the sticker.
    expect(
      app.container
          .read(editorControllerProvider(projectId))
          .requireValue
          .edit
          .elements,
      isEmpty,
    );
    await tester.pump(EditorController.saveDelay);
  });
}
