import 'package:auvie/app/router/routes.dart';
import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/app/widgets/editor_theme.dart';
import 'package:auvie/features/archive/archive_screen.dart';
import 'package:auvie/features/dev/engine_lab_screen.dart';
import 'package:auvie/features/editor/photo/photo_editor_screen.dart';
import 'package:auvie/features/editor/video/video_editor_screen.dart';
import 'package:auvie/features/export/export_screen.dart';
import 'package:auvie/features/home/home_screen.dart';
import 'package:auvie/features/onboarding/onboarding_screen.dart';
import 'package:auvie/features/settings/settings_screen.dart';
import 'package:auvie/features/subscription/pro_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final settings = ref.watch(appSettingsProvider);
  final router = GoRouter(
    // First launch goes through onboarding (O1–O4).
    redirect: (context, state) =>
        !settings.onboardingSeen &&
            state.matchedLocation != AppRoutes.onboarding &&
            state.matchedLocation != AppRoutes.pro
        ? AppRoutes.onboarding
        : null,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.photoEditorPattern,
        builder: (context, state) => EditorTheme(
          child: PhotoEditorScreen(
            projectId: state.pathParameters['projectId']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.videoEditorPattern,
        builder: (context, state) => EditorTheme(
          child: VideoEditorScreen(
            projectId: state.pathParameters['projectId']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.exportPattern,
        builder: (context, state) => EditorTheme(
          child: ExportScreen(projectId: state.pathParameters['projectId']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.archive,
        builder: (context, state) => const ArchiveScreen(),
      ),
      GoRoute(
        path: AppRoutes.pro,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          fullscreenDialog: true,
          child: const ProScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      // Debug and profile builds (profile to judge performance); never release.
      if (!kReleaseMode)
        GoRoute(
          path: AppRoutes.engineLab,
          builder: (context, state) =>
              const EditorTheme(child: EngineLabScreen()),
        ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}
