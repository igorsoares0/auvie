import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// App storage layout (spec §36). Everything lives in the app's private
/// support directory; exports are copied to the gallery via MediaStore.
class AppPaths {
  const new(this.root);

  final Directory root;

  static Future<AppPaths> resolve() async =>
      AppPaths(await getApplicationSupportDirectory());

  Directory get projects => _dir('projects');
  Directory get previews => _dir('previews');
  Directory get cache => _dir('cache');
  Directory get downloadedContent => _dir('downloaded_content');
  Directory get exports => _dir('exports');

  List<Directory> get all => [
    projects,
    previews,
    cache,
    downloadedContent,
    exports,
  ];

  Future<void> ensureCreated() async {
    for (final dir in all) {
      await dir.create(recursive: true);
    }
  }

  /// Thumbnail shown in the Home "recent" grid.
  File previewFor(String projectId) =>
      File(p.join(previews.path, '$projectId.jpg'));

  Directory _dir(String name) => Directory(p.join(root.path, name));
}
