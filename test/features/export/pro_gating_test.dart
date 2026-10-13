import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/subscription/pro_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_entitlement_service.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  late TestApp app;

  /// Editor → Export for a project whose edit is [edit].
  Future<void> openExport(
    WidgetTester tester,
    EditState Function(EditState) edit, {
    bool pro = false,
    MediaRef media = photoMedia,
  }) async {
    app = (await tester.runAsync(
      () => TestApp.create(store: FakeEntitlementService(pro: pro)),
    ))!;
    final repository = app.container.read(projectRepositoryProvider);
    final created = (await tester.runAsync(
      () => repository.create(media, name: 'Roll 014 · 07'),
    ))!;
    final project = created.copyWith(edit: edit(created.edit));
    await tester.runAsync(() => repository.save(project));
    await tester.pumpTestApp(app);
    unawaited(
      app.router.push(
        media.type == MediaType.photo
            ? AppRoutes.photoEditor(project.id)
            : AppRoutes.videoEditor(project.id),
      ),
    );
    await tester.pumpAndSettle();
    await tapKey(tester, 'editor-export');
  }

  EditState nocturne(EditState e) => e.withPreset('nocturne_19');

  testWidgets('a Pro film shows the notice to free users', (tester) async {
    await openExport(tester, nocturne);

    expect(find.byKey(const Key('export-pro-notice')), findsOneWidget);
    expect(
      find.text(
        'Nocturne is part of Pro. Unlock it, or swap it for a free one.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    await tapKey(tester, 'export-see-pro');
    expect(find.byType(ProScreen), findsOneWidget);
  });

  testWidgets('SAVE goes through the paywall, then exports', (tester) async {
    await openExport(tester, nocturne);

    await tapKey(tester, 'export-save');
    expect(find.byType(ProScreen), findsOneWidget);
    expect(app.engine.exports, isEmpty);

    await tapKey(tester, 'pro-purchase');

    expect(find.byType(ProScreen), findsNothing);
    expect(app.engine.exports, hasLength(1));
    expect(find.text('SAVED TO PHOTOS'), findsOneWidget);
  });

  testWidgets('closing the paywall exports nothing', (tester) async {
    await openExport(tester, nocturne);

    await tapKey(tester, 'export-share');
    await tapKey(tester, 'pro-close');

    expect(app.engine.exports, isEmpty);
    expect(find.byKey(const Key('export-pro-notice')), findsOneWidget);
  });

  testWidgets('Pro users export Pro content directly', (tester) async {
    await openExport(tester, nocturne, pro: true);

    expect(find.byKey(const Key('export-pro-notice')), findsNothing);
    await tapKey(tester, 'export-save');

    expect(find.byType(ProScreen), findsNothing);
    expect(app.engine.exports, hasLength(1));
  });

  testWidgets('free content exports directly for free users', (tester) async {
    await openExport(tester, (e) => e.withPreset('ektar_02'));

    expect(find.byKey(const Key('export-pro-notice')), findsNothing);
    await tapKey(tester, 'export-save');

    expect(app.engine.exports, hasLength(1));
  });

  testWidgets('a Pro sticker on a video locks its export too', (tester) async {
    await openExport(
      tester,
      (e) => e
          .addElement(
            const EditElement.sticker(id: 's', assetId: 'sticker_stamp'),
          )
          .addElement(
            const EditElement.overlay(id: 'o', assetId: 'overlay_film_burn'),
          ),
      media: videoMedia,
    );

    expect(
      find.textContaining('and 1 more are part of Pro', findRichText: true),
      findsOneWidget,
    );
    await tapKey(tester, 'export-save');
    expect(find.byType(ProScreen), findsOneWidget);
    expect(app.engine.videoExports, isEmpty);
  });
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}
