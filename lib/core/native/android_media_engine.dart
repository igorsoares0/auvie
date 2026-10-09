import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/native/pigeon/media_api.g.dart' as pigeon;
import 'package:auvie/core/native/render_params.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// [MediaEngine] backed by the Kotlin engine through Pigeon.
class AndroidMediaEngine implements MediaEngine {
  new({pigeon.MediaHostApi? api}) : _api = api ?? pigeon.MediaHostApi();

  final pigeon.MediaHostApi _api;

  @override
  Future<MediaRef?> pickMedia(MediaType type) => _guard(() async {
    final picked = await _api.pickMedia(switch (type) {
      MediaType.photo => pigeon.MediaKind.photo,
      MediaType.video => pigeon.MediaKind.video,
    });
    return picked == null ? null : mediaRefFromPigeon(picked);
  });

  @override
  Future<MediaRef> probe(String uri) =>
      _guard(() async => mediaRefFromPigeon(await _api.probe(uri)));

  @override
  Future<Uint8List> thumbnail(String uri, {required int maxPx}) =>
      _guard(() => _api.thumbnail(uri, maxPx));

  @override
  Future<PhotoPreview> createPhotoPreview(String uri, {required int maxPx}) =>
      _guard(() async {
        final info = await _api.createPhotoPreview(uri, maxPx);
        return (
          textureId: info.textureId,
          width: info.width,
          height: info.height,
        );
      });

  @override
  Future<void> updateEdit(int textureId, RenderParams params) =>
      _guard(() => _api.updateEdit(textureId, developParamsFrom(params)));

  @override
  Future<void> setShowOriginal(int textureId, {required bool original}) =>
      _guard(() => _api.setShowOriginal(textureId, original));

  @override
  Future<void> disposePreview(int textureId) =>
      _guard(() => _api.disposePreview(textureId));

  @override
  Future<Uint8List> renderPhoto(
    String uri,
    RenderParams params, {
    required int maxPx,
  }) => _guard(() => _api.renderPhoto(uri, developParamsFrom(params), maxPx));

  @override
  Future<void> resizePreview(
    int textureId, {
    required int width,
    required int height,
  }) => _guard(() => _api.resizePreview(textureId, width, height));

  @override
  Future<int> availableBytes() => _guard(_api.availableBytes);

  @override
  Future<ExportResult> exportPhoto(String jobId, ExportJob job) =>
      _guard(() async {
        final result = await _api.exportPhoto(
          jobId,
          pigeon.ExportRequest(
            uri: job.uri,
            params: developParamsFrom(job.params),
            format: switch (job.format) {
              ExportFormat.jpeg => pigeon.ExportFormat.jpeg,
              ExportFormat.png => pigeon.ExportFormat.png,
            },
            outputWidth: job.outputWidth,
            outputHeight: job.outputHeight,
            decodeMaxPx: job.decodeMaxPx,
            keepMetadata: job.keepMetadata,
            fileName: job.fileName,
            layers: [
              for (final l in job.layers)
                pigeon.ExportLayer(
                  path: l.path,
                  left: l.left,
                  top: l.top,
                  width: l.width,
                  height: l.height,
                  blend: pigeon.LayerBlend.values.byName(l.blend.name),
                  opacity: l.opacity,
                ),
            ],
          ),
        );
        return (
          mediaUri: result.mediaUri,
          filePath: result.filePath,
          width: result.width,
          height: result.height,
          bytes: result.bytes,
        );
      });

  @override
  Future<void> cancelExport(String jobId) =>
      _guard(() => _api.cancelExport(jobId));

  @override
  Stream<ExportProgress> get exportProgress => pigeon.exportProgress().map(
    (e) => (jobId: e.jobId, fraction: e.fraction, stage: e.stage),
  );

  @override
  Future<void> copyToClipboard(String mediaUri) =>
      _guard(() => _api.copyToClipboard(mediaUri));

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PlatformException catch (e) {
      throw MediaEngineException(
        MediaEngineError.fromCode(e.code),
        e.message,
        e.details is int ? e.details as int : null,
      );
    }
  }
}

@visibleForTesting
MediaRef mediaRefFromPigeon(pigeon.PickedMedia media) => MediaRef(
  uri: media.uri,
  type: switch (media.kind) {
    pigeon.MediaKind.photo => MediaType.photo,
    pigeon.MediaKind.video => MediaType.video,
  },
  width: media.width,
  height: media.height,
  durationMs: media.durationMs,
);

@visibleForTesting
pigeon.DevelopParams developParamsFrom(RenderParams params) {
  double v(Adjustment a) => params.adjustments[a];
  return pigeon.DevelopParams(
    exposure: v(Adjustment.exposure),
    brightness: v(Adjustment.brightness),
    contrast: v(Adjustment.contrast),
    highlights: v(Adjustment.highlights),
    shadows: v(Adjustment.shadows),
    saturation: v(Adjustment.saturation),
    temperature: v(Adjustment.temperature),
    tint: v(Adjustment.tint),
    sharpen: v(Adjustment.sharpen),
    grain: v(Adjustment.grain),
    fade: v(Adjustment.fade),
    vignette: v(Adjustment.vignette),
    curveLut: params.curveLut,
    geometry: params.geometry.toList(),
  );
}
