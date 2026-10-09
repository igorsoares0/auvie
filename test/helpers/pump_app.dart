import 'package:auvie/app/app.dart';
import 'package:auvie/app/router/router.dart';
import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/content/catalog_source.dart';
import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:auvie/core/platform/share_service.dart';
import 'package:auvie/core/storage/database.dart';
import 'package:auvie/core/storage/project_repository.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/elements/element_assets.dart';
import 'package:auvie/features/editor/elements/element_assets_provider.dart';
import 'package:auvie/features/editor/photo/photo_editor_controller.dart';
import 'package:auvie/features/editor/presets/preset_providers.dart';
import 'package:auvie/features/export/element_layers.dart';
import 'package:auvie/features/projects/project_providers.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_element_rasterizer.dart';
import 'fake_media_engine.dart';
import 'fake_project_thumbnails.dart';
import 'fake_share_service.dart';

/// The whole app over in-memory storage and a fake engine.
///
/// Drift's watched queries leave a zero-length timer behind when cancelled,
/// which widget tests reject, so the two watched lists (recent projects,
/// favorite presets) come from fixed streams; one-shot queries use the
/// in-memory database.
class TestApp {
  new _(
    this.container,
    this.engine,
    this.db,
    this.thumbnails,
    this.share,
    this.rasterizer,
    this.assets,
  );

  final ProviderContainer container;
  final FakeMediaEngine engine;
  final AuvieDatabase db;
  final FakeProjectThumbnails thumbnails;
  final FakeShareService share;
  final FakeElementRasterizer rasterizer;
  final ElementAssets assets;

  SharedPreferences get prefs => container.read(sharedPreferencesProvider);

  GoRouter get router => container.read(routerProvider);

  /// Builds the providers; call [TestAppPump.pumpTestApp] to show it.
  static Future<TestApp> create({
    bool onboardingSeen = true,
    FakeMediaEngine? engine,
    List<ProjectSummary> recents = const [],
    List<String> favorites = const [],
  }) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    SharedPreferences.setMockInitialValues({
      'auvie.onboardingSeen': onboardingSeen,
    });
    final prefs = await SharedPreferences.getInstance();
    // Asset loading is real I/O, which the widget tests' fake clock never
    // advances: load the shipped catalog here (call create via runAsync).
    final catalog = await BundledCatalogSource(rootBundle).load();
    final assets = await loadElementAssets(catalog);
    final rasterizer = FakeElementRasterizer();
    final db = AuvieDatabase(NativeDatabase.memory());
    final fake = engine ?? FakeMediaEngine();
    final thumbnails = FakeProjectThumbnails();
    final share = FakeShareService();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        mediaEngineProvider.overrideWithValue(fake),
        catalogProvider.overrideWith((ref) async => catalog),
        projectThumbnailsProvider.overrideWithValue(thumbnails),
        shareServiceProvider.overrideWithValue(share),
        elementAssetsProvider.overrideWith((ref) async => assets),
        elementLayerRasterizerProvider.overrideWithValue(rasterizer),
        elementIdsProvider.overrideWithValue(_sequentialIds()),
        recentProjectsProvider.overrideWith((ref) => Stream.value(recents)),
        favoritePresetsProvider.overrideWith((ref) => Stream.value(favorites)),
      ],
    );
    return TestApp._(
      container,
      fake,
      db,
      thumbnails,
      share,
      rasterizer,
      assets,
    );
  }

  Future<void> dispose() async {
    container.dispose();
    await db.close();
  }
}

extension TestAppPump on WidgetTester {
  /// The handoff's artboard: 390 × 844 pt at 3x.
  void usePhoneScreen() {
    view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(view.reset);
  }

  Future<void> pumpTestApp(TestApp app) async {
    usePhoneScreen();
    // Closing the database needs real async, outside the test's fake clock.
    addTearDown(() => runAsync(app.dispose));
    await pumpWidget(
      UncontrolledProviderScope(
        container: app.container,
        child: const AuvieApp(),
      ),
    );
    await pumpAndSettle();
  }

  /// Pumps the app (onboarding already seen) and returns its router.
  Future<GoRouter> pumpAuvieApp() async {
    final app = await runAsync(TestApp.create);
    await pumpTestApp(app!);
    return app.router;
  }
}

/// e1, e2, … so element-seeded textures are the same on every run.
String Function() _sequentialIds() {
  var n = 0;
  return () => 'e${++n}';
}
