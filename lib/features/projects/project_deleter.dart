import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/storage/app_paths.dart';
import 'package:auvie/core/storage/project_repository.dart';
import 'package:flutter/foundation.dart';

/// Deletes a project and what it kept on the device: its row, its Home
/// thumbnail and, when no other project edits the same original, the
/// permission (or private copy) held on it. The original in the gallery is
/// never touched.
class ProjectDeleter {
  const new({
    required this._repository,
    required this._engine,
    required this._paths,
  });

  final ProjectRepository _repository;
  final MediaEngine _engine;
  final Future<AppPaths> _paths;

  Future<void> delete({required String id, required String mediaUri}) async {
    await _repository.delete(id);
    final thumbnail = (await _paths).previewFor(id);
    if (thumbnail.existsSync()) await thumbnail.delete();
    if (await _repository.isMediaUsed(mediaUri)) return;
    try {
      await _engine.releaseMedia(mediaUri);
    } on MediaEngineException catch (e) {
      // The project is gone either way; a held permission is harmless.
      debugPrint('Releasing $mediaUri: $e');
    }
  }
}
