import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/native/render_params.dart';
import 'package:auvie/core/storage/app_paths.dart';
import 'package:auvie/core/storage/project_repository.dart';
import 'package:auvie/features/editor/elements/element_assets.dart';
import 'package:auvie/features/editor/elements/elements_painter.dart';
import 'package:flutter/painting.dart';

/// Keeps the Home "recent" thumbnail of each project up to date.
class ProjectThumbnails {
  const new({
    required this._engine,
    required this._repository,
    required this._paths,
    required this._assets,
  });

  /// Longer side of a thumbnail: a third of a phone screen at 3x.
  static const maxPx = 360;

  final MediaEngine _engine;
  final ProjectRepository _repository;
  final Future<AppPaths> _paths;
  final Future<ElementAssets> _assets;

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
    final elements = project.edit.elements;
    final out = elements.isEmpty ? bytes : await _withElements(bytes, elements);
    final file = (await _paths).previewFor(project.id);
    await file.writeAsBytes(out, flush: true);
    // Same path, new pixels: drop the decoded copy Home may hold.
    await FileImage(file).evict();
    await _repository.setThumbnail(project.id, file.path);
  }

  /// The developed photo with its elements drawn on top (PNG).
  Future<Uint8List> _withElements(
    Uint8List photo,
    List<EditElement> elements,
  ) async {
    final codec = await ui.instantiateImageCodec(photo);
    final frame = await codec.getNextFrame();
    codec.dispose();
    final image = frame.image;
    final size = Size(image.width.toDouble(), image.height.toDouble());
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..drawImage(image, Offset.zero, Paint());
    ElementDrawing.paintAll(canvas, elements, size, await _assets);
    final picture = recorder.endRecording();
    final composed = await picture.toImage(image.width, image.height);
    picture.dispose();
    image.dispose();
    final png = await composed.toByteData(format: ui.ImageByteFormat.png);
    composed.dispose();
    return png!.buffer.asUint8List();
  }
}
