import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/content/catalog_source.dart';
import 'package:auvie/core/storage/database.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

class _FakeSource implements CatalogSource {
  @override
  Future<Catalog> load() async => const Catalog(catalogVersion: 7);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalog loads from the bundled source by default', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(catalogSourceProvider), isA<BundledCatalogSource>());
    final catalog = await container.read(catalogProvider.future);
    expect(catalog.presets, isNotEmpty);
  });

  test('catalog source can be replaced (remote source in M8)', () async {
    final container = ProviderContainer(
      overrides: [catalogSourceProvider.overrideWithValue(_FakeSource())],
    );
    addTearDown(container.dispose);

    final catalog = await container.read(catalogProvider.future);
    expect(catalog.catalogVersion, 7);
  });

  test('repositories share the app database', () async {
    final db = AuvieDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    final project = await container
        .read(projectRepositoryProvider)
        .create(photoMedia);
    expect(
      await container.read(projectRepositoryProvider).find(project.id),
      project,
    );
    expect(container.read(favoritesRepositoryProvider), isNotNull);
  });
}
