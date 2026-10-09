import 'dart:typed_data';

import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:auvie/core/native/render_params.dart';
import 'package:auvie/features/export/export_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_providers.g.dart';

/// The edited, cropped photo shown on the Export screens.
@riverpod
Future<Uint8List> exportPreview(Ref ref, String projectId) async {
  // Only the edit matters: progress updates must not re-render the image.
  final (project, preset) = await ref.watch(
    exportControllerProvider(projectId)
        .selectAsync((s) => (s.project, s.preset)),
  );
  return await ref
      .read(mediaEngineProvider)
      .renderPhoto(
        project.media.uri,
        RenderParams.fromEdit(
          project.edit,
          preset,
          mediaRatio: project.media.aspectRatio,
        ),
        maxPx: 900,
      );
}
