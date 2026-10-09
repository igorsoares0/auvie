import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/features/projects/project_thumbnails.dart';

/// Records thumbnail requests instead of rendering and writing files.
class FakeProjectThumbnails implements ProjectThumbnails {
  final refreshed = <(Project, Preset?)>[];

  @override
  Future<void> refresh(Project project, Preset? preset) async {
    refreshed.add((project, preset));
  }
}
