import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/crop_geometry.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/photo/photo_editor_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  late TestApp app;
  late Project project;

  Future<void> openCrop(WidgetTester tester) async {
    app = (await tester.runAsync(TestApp.create))!;
    project = (await tester.runAsync(
      () => app.container
          .read(projectRepositoryProvider)
          .create(photoMedia, name: 'Roll 014 · 07'),
    ))!;
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.photoEditor(project.id)));
    await tester.pumpAndSettle();
    await tapKey(tester, 'tool-adjust');
    await tapKey(tester, 'family-crop');
  }

  double shownRatio(WidgetTester tester) => tester
      .widget<AspectRatio>(
        find
            .ancestor(
              of: find.byKey(const Key('editor-preview')),
              matching: find.byType(AspectRatio),
            )
            .first,
      )
      .aspectRatio;

  String caption(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('editor-caption'))).data!;

  Future<void> settle(WidgetTester tester) =>
      tester.pump(PhotoEditor.saveDelay); // Let the autosave run.

  testWidgets('crop mode shows the whole photo with the frame over it', (
    tester,
  ) async {
    await openCrop(tester);
    expect(find.byKey(const Key('crop-overlay')), findsOneWidget);
    expect(shownRatio(tester), closeTo(4 / 3, 1e-9));
    expect(app.engine.updates.last.$2.geometry, Affine2.identity);
  });

  testWidgets('choosing an aspect crops the output once crop closes', (
    tester,
  ) async {
    await openCrop(tester);
    await tapKey(tester, 'aspect-square');
    expect(caption(tester), 'One adjustment');
    // Still cropping: the whole frame stays visible.
    expect(shownRatio(tester), closeTo(4 / 3, 1e-9));

    await tapKey(tester, 'family-light');
    expect(shownRatio(tester), closeTo(1, 1e-9));
    expect(app.engine.updates.last.$2.geometry, isNot(Affine2.identity));
    final (_, w, h) = app.engine.resized.last;
    expect(w, closeTo(h, 1));
    await settle(tester);
  });

  testWidgets('rotate turns the frame, flip mirrors it', (tester) async {
    await openCrop(tester);
    await tapKey(tester, 'crop-rotate');
    expect(shownRatio(tester), closeTo(3 / 4, 1e-9));

    final before = app.engine.updates.last.$2.geometry;
    await tapKey(tester, 'family-light');
    await tapKey(tester, 'family-crop');
    await tapKey(tester, 'crop-flip');
    await tapKey(tester, 'family-light');
    expect(app.engine.updates.last.$2.geometry, isNot(before));
    await settle(tester);
  });

  testWidgets('straighten follows the ruler and resets', (tester) async {
    await openCrop(tester);
    expect(find.text('0.0°'), findsOneWidget);

    await tester.drag(find.byKey(const Key('lens-ruler')), const Offset(40, 0));
    await tester.pumpAndSettle();
    final text = tester
        .widget<Text>(find.byKey(const Key('straighten-value')))
        .data!;
    expect(text, startsWith('+'));

    await tapKey(tester, 'crop-reset');
    expect(find.text('0.0°'), findsOneWidget);
    expect(caption(tester), 'Original');
    await settle(tester);
  });

  testWidgets('dragging inside the frame moves the crop', (tester) async {
    await openCrop(tester);
    await tapKey(tester, 'aspect-square');
    double left() => app.container
        .read(photoEditorProvider(project.id))
        .requireValue
        .edit
        .crop
        .rect
        .left;
    final before = left();

    await tester.drag(
      find.byKey(const Key('crop-overlay')),
      const Offset(-60, 0),
    );
    await tester.pumpAndSettle();
    expect(left(), lessThan(before));

    await tapKey(tester, 'editor-undo');
    expect(left(), closeTo(before, 1e-9));
    await settle(tester);
  });
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}
