import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/storage/database.dart';
import 'package:auvie/features/editor/photo/photo_editor_screen.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_entitlement_service.dart';
import '../../helpers/fake_media_engine.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  late TestApp app;

  Future<void> openArchive(
    WidgetTester tester, {
    bool pro = false,
    List<String> favorites = const [],
    List<String> savedCollections = const [],
  }) async {
    app = (await tester.runAsync(
      () => TestApp.create(
        engine: FakeMediaEngine(picked: photoMedia),
        store: FakeEntitlementService(pro: pro),
        favorites: favorites,
        savedCollections: savedCollections,
      ),
    ))!;
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.archive));
    await tester.pumpAndSettle();
  }

  String access(WidgetTester tester, String presetId) =>
      tester.widget<Text>(find.byKey(Key('preset-access-$presetId'))).data!;

  Future<List<(FavoriteKind, String)>> favorites(WidgetTester tester) async => [
    for (final row in (await tester.runAsync(
      () => app.db.select(app.db.favorites).get(),
    ))!)
      (row.kind, row.itemId),
  ];

  testWidgets('shows the edition, its featured collection and every film', (
    tester,
  ) async {
    await openArchive(tester);

    expect(find.text('The Archive'), findsOneWidget);
    expect(find.text('5 COLLECTIONS'), findsOneWidget);
    expect(
      find.text('EDITION Nº 12 · AUTUMN · AVAILABLE OFFLINE'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('archive-featured')),
        matching: find.text('Night'),
      ),
      findsOneWidget,
    );
    expect(find.text('COLOUR NEG. · WARM, HIGH CHROMA'), findsOneWidget);
    await tester.tap(find.byKey(const Key('archive-featured')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('preset-row-nocturne_19')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('Pro films are TRY for free users and OWNED with Pro', (
    tester,
  ) async {
    await openArchive(tester);
    expect(access(tester, 'ektar_02'), 'OWNED');
    expect(access(tester, 'nocturne_19'), 'TRY');

    app.store.setPro(pro: true);
    await tester.pumpAndSettle();
    expect(access(tester, 'nocturne_19'), 'OWNED');
  });

  testWidgets('holding a film or saving a collection keeps it', (tester) async {
    await openArchive(
      tester,
      favorites: ['cendre_11'],
      savedCollections: ['night'],
    );
    expect(find.byKey(const Key('preset-saved-cendre_11')), findsOneWidget);
    expect(find.text('SAVED'), findsOneWidget); // Night's header.

    await tester.longPress(find.byKey(const Key('preset-row-ektar_02')));
    await tester.ensureVisible(find.byKey(const Key('collection-save-film')));
    await tester.tap(find.byKey(const Key('collection-save-film')));
    await tester.pumpAndSettle();

    expect(await favorites(tester), [
      (FavoriteKind.preset, 'ektar_02'),
      (FavoriteKind.collection, 'film'),
    ]);
  });

  testWidgets('tapping a film starts a photo with it', (tester) async {
    await openArchive(tester);

    await tester.ensureVisible(find.byKey(const Key('preset-row-nocturne_19')));
    await tester.tap(find.byKey(const Key('preset-row-nocturne_19')));
    await tester.pumpAndSettle();

    expect(find.byType(PhotoEditorScreen), findsOneWidget);
    final projectId = tester
        .widget<PhotoEditorScreen>(find.byType(PhotoEditorScreen))
        .projectId;
    final session = app.container
        .read(editorControllerProvider(projectId))
        .requireValue;
    expect(session.edit.preset?.presetId, 'nocturne_19');
    expect(app.thumbnails.refreshed.single.$2?.id, 'nocturne_19');
    await tester.pump(EditorController.saveDelay);
  });
}
