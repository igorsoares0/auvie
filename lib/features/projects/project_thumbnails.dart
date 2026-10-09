import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/native/render_params.dart';
import 'package:auvie/core/storage/app_paths.dart';
import 'package:auvie/core/storage/project_repository.dart';
import 'package:flutter/painting.dart';

/// Keeps the Home "recent" thumbnail of each project up to date.
class ProjectThumbnails {
  const new({
    required this._engine,
    required this._repository,
    required this._paths,
  });

  /// Longer side of a thumbnail: a third of a phone screen at 3x.
  static const maxPx = 360;

  final MediaEngine _engine;
  final ProjectRepository _repository;
  final Future<AppPaths> _paths;

  /// Renders [project] as edited (photos) or its first frame (videos).
  Future<void> refresh(Project project, Preset? preset) async {
    final bytes = switch (project.media.type) {
      MediaType.photo => await _engine.renderPhoto(
        project.media.uri,
        RenderParams.fromEdit(
          project.edit,
          preset,
          mediaRatio: project.media.aspectRatio,
        ),
        maxPx: maxPx,
      ),
      MediaType.video => await _engine.thumbnail(
        project.media.uri,
        maxPx: maxPx,
      ),
    };
    final file = (await _paths).previewFor(project.id);
    await file.writeAsBytes(bytes, flush: true);
    // Same path, new pixels: drop the decoded copy Home may hold.
    await FileImage(file).evict();
    await _repository.setThumbnail(project.id, file.path);
  }
}
