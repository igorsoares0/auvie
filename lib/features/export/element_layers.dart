import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/storage/app_paths.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/elements/element_assets.dart';
import 'package:auvie/features/editor/elements/element_assets_provider.dart';
import 'package:auvie/features/editor/elements/element_geometry.dart';
import 'package:auvie/features/editor/elements/elements_painter.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'element_layers.g.dart';

/// Where an element's layer goes in the output and how big its PNG is.
typedef LayerPlan = ({Rect bounds, double scale, int width, int height});

/// Turns elements into PNG layers for the engine to composite.
abstract interface class ElementLayerRasterizer {
  Future<List<ExportLayerSpec>> rasterize({
    required String jobId,
    required List<EditElement> elements,
    required ({int width, int height}) output,
  });

  /// Deletes a job's layer files.
  Future<void> clean(String jobId);
}

LayerBlend layerBlendOf(EditElement element) => switch (element) {
  OverlayElement(:final blend) => switch (blend) {
    OverlayBlend.screen => LayerBlend.screen,
    OverlayBlend.multiply => LayerBlend.multiply,
    OverlayBlend.overlay => LayerBlend.overlay,
    OverlayBlend.softLight => LayerBlend.softLight,
    OverlayBlend.normal => LayerBlend.normal,
  },
  _ => LayerBlend.normal,
};

class FlutterElementRasterizer implements ElementLayerRasterizer {
  const new({required this._paths, required this._assets});

  /// Longest side of a layer's PNG; larger layers are scaled up by the
  /// engine (overlays and frames are soft at the edges anyway).
  static const maxSide = 4096;

  final Future<AppPaths> _paths;
  final Future<ElementAssets> _assets;

  /// The layer of [element] in an output of [size], or null when it's
  /// entirely off the output.
  static LayerPlan? plan(EditElement element, Size size, ElementAssets assets) {
    final frame = ElementGeometry.of(element, size, assets);
    final all = Offset.zero & size;
    // A little margin keeps anti-aliased edges and shadows.
    final bounds = (frame?.bounds.inflate(size.shortestSide * 0.02) ?? all)
        .intersect(all);
    if (bounds.isEmpty || bounds.width < 1 || bounds.height < 1) return null;
    final scale = math
        .min(1, maxSide / math.max(bounds.width, bounds.height))
        .toDouble();
    return (
      bounds: bounds,
      scale: scale,
      width: math.max(1, (bounds.width * scale).ceil()),
      height: math.max(1, (bounds.height * scale).ceil()),
    );
  }

  Directory _dir(AppPaths paths, String jobId) =>
      Directory(p.join(paths.cache.path, 'layers', jobId));

  @override
  Future<List<ExportLayerSpec>> rasterize({
    required String jobId,
    required List<EditElement> elements,
    required ({int width, int height}) output,
  }) async {
    if (elements.isEmpty) return const [];
    final assets = await _assets;
    final dir = await _dir(await _paths, jobId).create(recursive: true);
    final size = Size(output.width.toDouble(), output.height.toDouble());
    final layers = <ExportLayerSpec>[];
    for (final (i, element) in elements.indexed) {
      final plan = FlutterElementRasterizer.plan(element, size, assets);
      if (plan == null) continue;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)
        ..scale(plan.scale)
        ..translate(-plan.bounds.left, -plan.bounds.top);
      ElementDrawing.paintContent(canvas, element, size, assets);
      final picture = recorder.endRecording();
      final image = await picture.toImage(plan.width, plan.height);
      picture.dispose();
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final file = File(p.join(dir.path, '$i.png'));
      await file.writeAsBytes(png!.buffer.asUint8List(), flush: true);
      layers.add((
        path: file.path,
        left: plan.bounds.left,
        top: plan.bounds.top,
        width: plan.bounds.width,
        height: plan.bounds.height,
        blend: layerBlendOf(element),
        opacity: opacityOf(element),
      ));
    }
    return layers;
  }

  @override
  Future<void> clean(String jobId) async {
    final dir = _dir(await _paths, jobId);
    if (dir.existsSync()) await dir.delete(recursive: true);
  }
}

@Riverpod(keepAlive: true)
ElementLayerRasterizer elementLayerRasterizer(Ref ref) =>
    FlutterElementRasterizer(
      paths: ref.watch(appPathsProvider.future),
      assets: ref.watch(elementAssetsProvider.future),
    );
