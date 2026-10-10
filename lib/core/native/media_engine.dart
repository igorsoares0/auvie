import 'dart:typed_data';

import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/render_params.dart';

/// Why a media engine call failed. Codes come from
/// `android/app/src/main/kotlin/app/auvie/engine/EngineErrors.kt`.
enum MediaEngineError {
  decodeFailed('decode_failed'),
  mediaUnavailable('media_unavailable'),
  noActivity('no_activity'),
  pickerBusy('picker_busy'),
  invalidParams('invalid_params'),
  unknownTexture('unknown_texture'),
  storageFull('storage_full'),
  exportFailed('export_failed'),
  cancelled('cancelled'),
  unknown('unknown');

  new(this.code);

  final String code;

  static MediaEngineError fromCode(String code) =>
      values.firstWhere((e) => e.code == code, orElse: () => unknown);
}

class MediaEngineException implements Exception {
  const new(this.error, [this.message, this.missingBytes]);

  final MediaEngineError error;
  final String? message;

  /// For [MediaEngineError.storageFull]: how many more bytes are needed.
  final int? missingBytes;

  @override
  String toString() {
    final detail = message == null ? '' : ': $message';
    return 'MediaEngineException(${error.code}$detail)';
  }
}

/// A developed photo shown in a Flutter `Texture`.
typedef PhotoPreview = ({int textureId, int width, int height});

enum ExportFormat { jpeg, png }

enum LayerBlend { normal, screen, multiply, overlay, softLight }

/// A developed video shown in a Flutter `Texture`; `width` × `height` is
/// the upright video size.
typedef VideoPreview = ({
  int textureId,
  int width,
  int height,
  int durationMs,
  bool hasAudio,
});

/// Where a video preview is (sent while playing and on play, pause, seek).
typedef PlaybackState = ({int textureId, int positionMs, bool playing});

/// An element rasterized to `path` (PNG), placed at `left`, `top`,
/// `width` × `height` output pixels. Videos show it from `startMs` to
/// `endMs` of the original clip (null = always).
typedef ExportLayerSpec = ({
  String path,
  double left,
  double top,
  double width,
  double height,
  LayerBlend blend,
  double opacity,
  int? startMs,
  int? endMs,
});

/// A full-size photo export (spec §34). `decodeMaxPx` is the longer side to
/// decode the original at; `fileName` has no extension; `layers` are the
/// elements, bottom first.
typedef ExportJob = ({
  String uri,
  RenderParams params,
  ExportFormat format,
  int outputWidth,
  int outputHeight,
  int decodeMaxPx,
  bool keepMetadata,
  String fileName,
  List<ExportLayerSpec> layers,
});

/// A video export (spec §34): `outputWidth` × `outputHeight` are even;
/// `trimStartMs`…`trimEndMs` is the part of the original kept; `videoBitrate`
/// in bits per second; `layers` are the elements with their time ranges.
typedef VideoExportJob = ({
  String uri,
  RenderParams params,
  int outputWidth,
  int outputHeight,
  int trimStartMs,
  int trimEndMs,
  bool includeAudio,
  int videoBitrate,
  String fileName,
  List<ExportLayerSpec> layers,
});

/// `mediaUri` is the copy in Pictures/Auvie (Movies/Auvie for videos);
/// `filePath` the app's copy, for sharing. `durationMs` for videos.
typedef ExportResult = ({
  String mediaUri,
  String filePath,
  int width,
  int height,
  int bytes,
  int? durationMs,
});

/// Progress of an export: `fraction` 0…1, `stage` one of decode, render,
/// encode, save.
typedef ExportProgress = ({String jobId, double fraction, String stage});

/// The native media engine (spec §31–32). The UI depends only on this
/// interface; Android implements it in `AndroidMediaEngine`, tests use a fake.
abstract interface class MediaEngine {
  /// Opens the system picker. Null when the user cancels.
  Future<MediaRef?> pickMedia(MediaType type);

  Future<MediaRef> probe(String uri);

  /// JPEG thumbnail whose longer side is at most [maxPx].
  Future<Uint8List> thumbnail(String uri, {required int maxPx});

  /// Decodes the photo (longer side ≤ [maxPx]) into a texture.
  Future<PhotoPreview> createPhotoPreview(String uri, {required int maxPx});

  /// Cheap to call on every frame: the engine renders only the latest params.
  Future<void> updateEdit(int textureId, RenderParams params);

  Future<void> setShowOriginal(int textureId, {required bool original});

  Future<void> disposePreview(int textureId);

  /// Develops the photo offscreen into a JPEG (longer side ≤ [maxPx]).
  Future<Uint8List> renderPhoto(
    String uri,
    RenderParams params, {
    required int maxPx,
  });

  /// Develops the video's frame at [timeMs] into a JPEG.
  Future<Uint8List> renderVideoFrame(
    String uri,
    RenderParams params, {
    required int maxPx,
    required int timeMs,
  });

  /// Opens the video paused on its first frame, in a texture rendered at
  /// most [maxPx] on the longer side. [updateEdit], [setShowOriginal],
  /// [resizePreview] and [disposePreview] work on it like on photos.
  Future<VideoPreview> createVideoPreview(String uri, {required int maxPx});

  Future<void> playVideo(int textureId);

  Future<void> pauseVideo(int textureId);

  /// Without [exact], seeks to the nearest key frame (fast, for scrubbing).
  Future<void> seekVideo(int textureId, int positionMs, {bool exact = true});

  /// Playback loops inside [startMs]…[endMs] (the trim).
  Future<void> setPlaybackRange(
    int textureId, {
    required int startMs,
    required int endMs,
  });

  Future<void> setVideoMuted(int textureId, {required bool muted});

  /// Events of every video preview; filter by `textureId`.
  Stream<PlaybackState> get playbackStates;

  /// [count] JPEG frames spread evenly over the video (the FILM strip).
  Future<List<Uint8List>> videoFrames(
    String uri, {
    required int count,
    required int maxPx,
  });

  /// Peak level 0…1 of each of [buckets] slices; null without sound.
  Future<List<double>?> waveform(String uri, {required int buckets});

  /// Sets the preview's pixel size (when the crop's aspect changes).
  Future<void> resizePreview(
    int textureId, {
    required int width,
    required int height,
  });

  /// Free bytes where exports are written.
  Future<int> availableBytes();

  /// Exports at full size and saves to the gallery. Progress arrives on
  /// [exportProgress]; [cancelExport] stops it with
  /// [MediaEngineError.cancelled].
  Future<ExportResult> exportPhoto(String jobId, ExportJob job);

  /// Exports a video in the background (with a notification) and saves it
  /// to the gallery. Progress and cancelling work like [exportPhoto].
  Future<ExportResult> exportVideo(String jobId, VideoExportJob job);

  /// Asks to show notifications (Android 13+). True when allowed.
  Future<bool> requestNotificationPermission();

  Future<void> cancelExport(String jobId);

  Stream<ExportProgress> get exportProgress;

  /// Puts a saved image on the clipboard.
  Future<void> copyToClipboard(String mediaUri);
}
