import 'package:auvie/app/router/routes.dart';
import 'package:auvie/app/theme/palette.dart';
import 'package:auvie/features/archive/archive_screen.dart';
import 'package:auvie/features/dev/engine_lab_screen.dart';
import 'package:auvie/features/editor/photo/photo_editor_screen.dart';
import 'package:auvie/features/editor/video/video_editor_screen.dart';
import 'package:auvie/features/export/export_screen.dart';
import 'package:auvie/features/home/home_screen.dart';
import 'package:auvie/features/onboarding/onboarding_screen.dart';
import 'package:auvie/features/settings/settings_screen.dart';
import 'package:auvie/features/subscription/pro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final routes = <String, Type>{
    AppRoutes.home: HomeScreen,
    AppRoutes.onboarding: OnboardingScreen,
    AppRoutes.photoEditor('p1'): PhotoEditorScreen,
    AppRoutes.videoEditor('v1'): VideoEditorScreen,
    AppRoutes.export('p1'): ExportScreen,
    AppRoutes.archive: ArchiveScreen,
    AppRoutes.pro: ProScreen,
    AppRoutes.settings: SettingsScreen,
    // Registered only in debug builds; tests run in debug.
    AppRoutes.engineLab: EngineLabScreen,
  };

  for (final MapEntry(key: path, value: screen) in routes.entries) {
    testWidgets('$path opens $screen', (tester) async {
      final router = await tester.pumpAuvieApp();

      router.go(path);
      await tester.pumpAndSettle();

      expect(find.byType(screen), findsOneWidget);
    });
  }

  testWidgets('passes the project id to the editor', (tester) async {
    final router = await tester.pumpAuvieApp();

    router.go(AppRoutes.photoEditor('abc-123'));
    await tester.pumpAndSettle();

    final editor = tester.widget<PhotoEditorScreen>(
      find.byType(PhotoEditorScreen),
    );
    expect(editor.projectId, 'abc-123');
  });

  group('theme follows the task', () {
    AuviePalette paletteOf(WidgetTester tester, Finder finder) =>
        Theme.of(tester.element(finder)).extension<AuviePalette>()!;

    testWidgets('browsing screens stay paper in dark mode', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final router = await tester.pumpAuvieApp();

      for (final path in [AppRoutes.home, AppRoutes.archive, AppRoutes.pro]) {
        router.go(path);
        await tester.pumpAndSettle();
        expect(
          paletteOf(tester, find.byType(routes[path]!)),
          AuviePalette.paper,
          reason: path,
        );
      }
    });

    for (final (brightness, expected) in [
      (Brightness.dark, AuviePalette.darkroom),
      (Brightness.light, AuviePalette.paper),
    ]) {
      testWidgets('editor and export follow system $brightness', (
        tester,
      ) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final router = await tester.pumpAuvieApp();

        for (final (path, screen) in [
          (AppRoutes.photoEditor('p1'), PhotoEditorScreen),
          (AppRoutes.videoEditor('v1'), VideoEditorScreen),
          (AppRoutes.export('p1'), ExportScreen),
        ]) {
          router.go(path);
          await tester.pumpAndSettle();
          expect(
            paletteOf(tester, find.byType(screen)),
            expected,
            reason: path,
          );
        }
      });
    }
  });
}
