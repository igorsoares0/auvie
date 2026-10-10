import 'dart:typed_data';

import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:auvie/core/native/render_params.dart';
import 'package:auvie/features/export/export_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_providers.g.dart';

/// The edited, cropped photo (or video's first kept frame) shown on the
/// Export screens.
@riverpod
Future<Uint8List> exportPreview(Ref ref, String projectId) async {
  // Only the edit matters: progress updates must not re-render the image.
  final (project, preset) = await ref.watch(
    exportControllerProvider(projectId)
        .selectAsync((s) => (s.project, s.preset)),
  );
  final engine = ref.read(mediaEngineProvider);
  final params = RenderParams.fromEdit(
    project.edit,
    preset,
    mediaRatio: project.media.aspectRatio,
  );
  return switch (project.media.type) {
    MediaType.photo => await engine.renderPhoto(
      project.media.uri,
      params,
      maxPx: 900,
    ),
    MediaType.video => await engine.renderVideoFrame(
      project.media.uri,
      params,
      maxPx: 900,
      timeMs: posterTimeMs(project),
    ),
  };
}
