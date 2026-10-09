// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(projectThumbnails)
final projectThumbnailsProvider = ProjectThumbnailsProvider._();

final class ProjectThumbnailsProvider
    extends
        $FunctionalProvider<
          ProjectThumbnails,
          ProjectThumbnails,
          ProjectThumbnails
        >
    with $Provider<ProjectThumbnails> {
  ProjectThumbnailsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectThumbnailsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectThumbnailsHash();

  @$internal
  @override
  $ProviderElement<ProjectThumbnails> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProjectThumbnails create(Ref ref) {
    return projectThumbnails(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectThumbnails value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectThumbnails>(value),
    );
  }
}

String _$projectThumbnailsHash() => r'61d1182f74012f2a17769f44797b29a2daf621be';

@ProviderFor(projectStarter)
final projectStarterProvider = ProjectStarterProvider._();

final class ProjectStarterProvider
    extends $FunctionalProvider<ProjectStarter, ProjectStarter, ProjectStarter>
    with $Provider<ProjectStarter> {
  ProjectStarterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectStarterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectStarterHash();

  @$internal
  @override
  $ProviderElement<ProjectStarter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProjectStarter create(Ref ref) {
    return projectStarter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectStarter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectStarter>(value),
    );
  }
}

String _$projectStarterHash() => r'2e2820f021cdcbfde8da30eb7b35a483e251f117';

@ProviderFor(recentProjects)
final recentProjectsProvider = RecentProjectsProvider._();

final class RecentProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProjectSummary>>,
          List<ProjectSummary>,
          Stream<List<ProjectSummary>>
        >
    with
        $FutureModifier<List<ProjectSummary>>,
        $StreamProvider<List<ProjectSummary>> {
  RecentProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentProjectsHash();

  @$internal
  @override
  $StreamProviderElement<List<ProjectSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ProjectSummary>> create(Ref ref) {
    return recentProjects(ref);
  }
}

String _$recentProjectsHash() => r'6cf34f181f905bb0be93aeadd6638b91b399dbca';
