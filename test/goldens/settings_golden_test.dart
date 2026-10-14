@Tags(['golden'])
library;

import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/home/home_screen_test.dart' show summary;
import '../helpers/fake_entitlement_service.dart';
import '../helpers/fake_media_engine.dart';
import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';

void main() {
  Future<void> expectScreen(String name) => expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('screens/$name.png'),
  );

  for (final pro in [false, true]) {
    testWidgets('settings, ${pro ? 'pro' : 'free'}', (tester) async {
      final app = (await tester.runAsync(
        () => TestApp.create(store: FakeEntitlementService(pro: pro)),
      ))!;
      await tester.pumpTestApp(app);
      unawaited(app.router.push(AppRoutes.settings));
      await tester.pumpAndSettle();
      await expectScreen('settings_${pro ? 'pro' : 'free'}');
    });
  }

  testWidgets('delete sheet', (tester) async {
    final app = (await tester.runAsync(
      () => TestApp.create(recents: [summary('p1', name: 'Roll 001 · 01')]),
    ))!;
    await tester.pumpTestApp(app);
    await tester.longPress(find.byKey(const Key('recent-p1')));
    await tester.pumpAndSettle();
    await expectScreen('delete_sheet');
  });

  testWidgets('editor, original gone', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final app = (await tester.runAsync(
      () => TestApp.create(
        engine: FakeMediaEngine()
          ..previewError = const MediaEngineException(
            MediaEngineError.mediaUnavailable,
          ),
      ),
    ))!;
    final project = (await tester.runAsync(
      () => app.container
          .read(projectRepositoryProvider)
          .create(photoMedia, name: 'Roll 014 · 07'),
    ))!;
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.photoEditor(project.id)));
    await tester.pumpAndSettle();
    await expectScreen('editor_original_gone');
  });
}
