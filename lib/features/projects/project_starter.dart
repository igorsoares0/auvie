import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/storage/project_repository.dart';
import 'package:auvie/features/projects/project_thumbnails.dart';
import 'package:flutter/foundation.dart';

/// Starts a project from the system picker (Home → Photo / Video).
class ProjectStarter {
  const new({
    required this._engine,
    required this._repository,
    required this._thumbnails,
    required this._settings,
  });

  final MediaEngine _engine;
  final ProjectRepository _repository;
  final ProjectThumbnails _thumbnails;
  final AppSettings _settings;

  /// Null when the user cancels the picker. With [preset] (Archive), the
  /// project starts with that film applied.
  Future<Project?> start(MediaType type, {Preset? preset}) async {
    final media = await _engine.pickMedia(type);
    if (media == null) return null;
    var project = await _repository.create(
      media,
      name: await _settings.nextFrameName(),
    );
    if (preset != null) {
      project = await _repository.save(
        project.copyWith(edit: project.edit.withPreset(preset.id)),
      );
    }
    try {
      await _thumbnails.refresh(project, preset);
    } on Object catch (e) {
      // The project is usable without a thumbnail; it is retried on close.
      debugPrint('Thumbnail for ${project.id} failed: $e');
    }
    return project;
  }
}
