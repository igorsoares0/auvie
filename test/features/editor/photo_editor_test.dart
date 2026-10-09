import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/photo/photo_editor_controller.dart';
import 'package:auvie/features/home/home_screen.dart';
import 'package:flutter/gestures.dart';
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
    unawaitedPush(app, AppRoutes.photoEditor(project.id));
    await tester.pumpAndSettle();
  }

  String caption(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('editor-caption'))).data!;

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('opens with the photo, the title and FILM', (tester) async {
    await openEditor(tester);

    expect(find.byKey(const Key('editor-preview')), findsOneWidget);
    expect(find.textContaining('Roll 014', findRichText: true), findsOneWidget);
    expect(caption(tester), 'Original');
    expect(find.text('HOLD TO COMPARE'), findsOneWidget);
    // The preview is rendered at its on-screen size, not the original's.
    final create = app.engine.calls.firstWhere(
      (c) => c.startsWith('createPhotoPreview'),
    );
    expect(create, isNot(contains('4000')));
  });

  testWidgets('choosing a film develops the photo with it', (tester) async {
    await openEditor(tester);

    await tapKey(tester, 'preset-ektar_02');

    expect(caption(tester), 'Ektar, at 100%');
    final params = app.engine.updates.last.$2;
    expect(params.adjustments[Adjustment.saturation], closeTo(0.18, 1e-9));
    expect(find.byKey(const Key('intensity-slider')), findsOneWidget);
    await tester.pump(PhotoEditor.saveDelay); // Let the autosave run.
  });

  testWidgets('intensity is one undo step per drag', (tester) async {
    await openEditor(tester);
    await tapKey(tester, 'preset-ektar_02');

    await tester.drag(
      find.byKey(const Key('intensity-slider')),
      const Offset(-120, 0),
    );
    await tester.pumpAndSettle();
    expect(caption(tester), isNot('Ektar, at 100%'));

    await tapKey(tester, 'editor-undo');
    expect(caption(tester), 'Ektar, at 100%');
    await tapKey(tester, 'editor-undo');
    expect(caption(tester), 'Original');
    await tapKey(tester, 'editor-redo');
    expect(caption(tester), 'Ektar, at 100%');
    await tester.pump(PhotoEditor.saveDelay); // Let the autosave run.
  });

  testWidgets('ADJUST: ruler, reset, swipe and families', (tester) async {
    await openEditor(tester);
    await tapKey(tester, 'tool-adjust');

    expect(find.text('Exposure'), findsOneWidget);
    expect(find.text('0.00'), findsOneWidget);

    await tester.drag(find.byKey(const Key('lens-ruler')), const Offset(60, 0));
    await tester.pumpAndSettle();
    expect(caption(tester), 'One adjustment');
    expect(
      app.engine.updates.last.$2.adjustments[Adjustment.exposure],
      greaterThan(0),
    );

    final ruler = find.byKey(const Key('lens-ruler'));
    await tester.tap(ruler);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(ruler);
    await tester.pumpAndSettle();
    expect(caption(tester), 'Original');

    await tester.fling(
      find.byKey(const Key('parameter-header')),
      const Offset(-200, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('Brightness'), findsOneWidget);

    await tapKey(tester, 'family-color');
    expect(find.text('Saturation'), findsOneWidget);

    await tapKey(tester, 'family-curve');
    expect(find.byKey(const Key('curve-area')), findsOneWidget);
  });

  testWidgets('switching tools keeps the edit', (tester) async {
    await openEditor(tester);
    await tapKey(tester, 'preset-ektar_02');
    await tapKey(tester, 'tool-adjust');
    await tester.drag(find.byKey(const Key('lens-ruler')), const Offset(60, 0));
    await tester.pumpAndSettle();

    await tapKey(tester, 'tool-film');
    expect(caption(tester), 'Ektar 100%, one adjustment');
    await tester.pump(PhotoEditor.saveDelay); // Let the autosave run.
  });

  testWidgets('tools for later milestones are disabled', (tester) async {
    await openEditor(tester);
    await tapKey(tester, 'tool-type');
    expect(find.text('HOLD TO COMPARE'), findsOneWidget); // Still on FILM.
  });

  testWidgets('holding the photo shows the original', (tester) async {
    await openEditor(tester);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('editor-preview'))),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(app.engine.showOriginal, [true, false]);
  });

  testWidgets('edits autosave shortly after the last change', (tester) async {
    await openEditor(tester);
    await tapKey(tester, 'preset-ektar_02');
    await tester.pump(PhotoEditor.saveDelay + const Duration(milliseconds: 50));

    final saved = await tester.runAsync(
      () => app.container.read(projectRepositoryProvider).find(project.id),
    );
    expect(saved!.edit.preset?.presetId, 'ektar_02');
  });

  testWidgets('closing saves, refreshes the thumbnail and returns', (
    tester,
  ) async {
    await openEditor(tester);
    await tapKey(tester, 'preset-ektar_02');

    await tapKey(tester, 'editor-close');

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      app.thumbnails.refreshed.single.$1.edit.preset?.presetId,
      'ektar_02',
    );
    expect(app.thumbnails.refreshed.single.$2?.id, 'ektar_02');
    final saved = await tester.runAsync(
      () => app.container.read(projectRepositoryProvider).find(project.id),
    );
    expect(saved!.edit.preset?.presetId, 'ektar_02');
    expect(app.engine.disposed, isNotEmpty);
  });

  testWidgets('a pending save still happens when the editor goes away', (
    tester,
  ) async {
    await openEditor(tester);
    await tapKey(tester, 'preset-ektar_02');

    // Leave without CLOSE, before the autosave fires.
    app.router.go(AppRoutes.home);
    await tester.pumpAndSettle();

    final saved = await tester.runAsync(
      () => app.container.read(projectRepositoryProvider).find(project.id),
    );
    expect(saved!.edit.preset?.presetId, 'ektar_02');
  });

  testWidgets('a missing project shows an error instead of crashing', (
    tester,
  ) async {
    app = (await tester.runAsync(TestApp.create))!;
    await tester.pumpTestApp(app);
    unawaitedPush(app, AppRoutes.photoEditor('missing'));
    await tester.pumpAndSettle();
    expect(find.text("This edit can't be opened."), findsOneWidget);
  });
}

void unawaitedPush(TestApp app, String location) {
  // GoRouter.push returns a Future that completes when the route pops.
  // ignore: discarded_futures
  app.router.push(location);
}
