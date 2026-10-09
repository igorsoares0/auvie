import 'package:auvie/core/storage/app_paths.dart';
import 'package:auvie/core/storage/database.dart';
import 'package:auvie/core/storage/favorites_repository.dart';
import 'package:auvie/core/storage/project_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'storage_providers.g.dart';

@Riverpod(keepAlive: true)
AuvieDatabase appDatabase(Ref ref) {
  final db = AuvieDatabase.open();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
ProjectRepository projectRepository(Ref ref) =>
    ProjectRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
FavoritesRepository favoritesRepository(Ref ref) =>
    FavoritesRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
Future<AppPaths> appPaths(Ref ref) async {
  final paths = await AppPaths.resolve();
  await paths.ensureCreated();
  return paths;
}
