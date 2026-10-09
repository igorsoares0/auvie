@Tags(['golden'])
library;

import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/photo/photo_editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/home/home_screen_test.dart' show summary;
import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';

void main() {
  Future<void> expectScreen(String name) => expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('screens/$name.png'),
  );

  testWidgets('home, first use', (tester) async {
    final app = (await tester.runAsync(TestApp.create))!;
    await tester.pumpTestApp(app);
    await expectScreen('home_empty');
  });

  testWidgets('home with recent work', (tester) async {
    final app = (await tester.runAsync(
      () => TestApp.create(
        recents: [
          summary('a', name: 'Roll 001 · 03', presetId: 'ektar_02'),
          summary(
            'b',
            type: MediaType.video,
            name: 'Roll 001 · 02',
            durationMs: 14000,
          ),
          summary('c', name: 'Roll 001 · 01', presetId: 'cendre_11'),
        ],
      ),
    ))!;
    await tester.pumpTestApp(app);
    await expectScreen('home_recents');
  });

  testWidgets('onboarding cover and access', (tester) async {
    final app = (await tester.runAsync(
      () => TestApp.create(onboardingSeen: false),
    ))!;
    await tester.pumpTestApp(app);
    await expectScreen('onboarding_cover');

    for (final label in ['BEGIN', 'NEXT', 'NEXT']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    await expectScreen('onboarding_access');
  });

  for (final brightness in Brightness.values) {
    testWidgets('editor, ${brightness.name}', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final app = (await tester.runAsync(TestApp.create))!;
      final project = (await tester.runAsync(
        () => app.container
            .read(projectRepositoryProvider)
            .create(photoMedia, name: 'Roll 014 · 07'),
      ))!;
      await tester.pumpTestApp(app);
      unawaited(app.router.push(AppRoutes.photoEditor(project.id)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('preset-ektar_02')));
      await tester.pumpAndSettle();
      await expectScreen('editor_film_${brightness.name}');

      await tester.tap(find.byKey(const Key('tool-adjust')));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('lens-ruler')),
        const Offset(-40, 0),
      );
      await tester.pumpAndSettle();
      await expectScreen('editor_adjust_${brightness.name}');
      await tester.pump(PhotoEditor.saveDelay);
    });
  }
}
