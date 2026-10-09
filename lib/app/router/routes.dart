/// Route paths. Navigation is a stack from Home; there are no tabs.
abstract final class AppRoutes {
  static const home = '/';
  static const onboarding = '/onboarding';
  static const archive = '/archive';
  static const pro = '/pro';
  static const settings = '/settings';

  /// Debug and profile builds only: media engine bench.
  static const engineLab = '/dev/engine';

  static const photoEditorPattern = '/editor/photo/:projectId';
  static const videoEditorPattern = '/editor/video/:projectId';
  static const exportPattern = '/export/:projectId';

  static String photoEditor(String projectId) => '/editor/photo/$projectId';
  static String videoEditor(String projectId) => '/editor/video/$projectId';
  static String export(String projectId) => '/export/$projectId';
}
