import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:auvie/core/storage/project_repository.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/elements/element_assets_provider.dart';
import 'package:auvie/features/projects/project_starter.dart';
import 'package:auvie/features/projects/project_thumbnails.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'project_providers.g.dart';

@Riverpod(keepAlive: true)
ProjectThumbnails projectThumbnails(Ref ref) => ProjectThumbnails(
  engine: ref.watch(mediaEngineProvider),
  repository: ref.watch(projectRepositoryProvider),
  paths: ref.watch(appPathsProvider.future),
  assets: ref.watch(elementAssetsProvider.future),
);

@Riverpod(keepAlive: true)
ProjectStarter projectStarter(Ref ref) => ProjectStarter(
  engine: ref.watch(mediaEngineProvider),
  repository: ref.watch(projectRepositoryProvider),
  thumbnails: ref.watch(projectThumbnailsProvider),
  settings: ref.watch(appSettingsProvider),
);

@riverpod
Stream<List<ProjectSummary>> recentProjects(Ref ref) =>
    ref.watch(projectRepositoryProvider).watchRecent();
