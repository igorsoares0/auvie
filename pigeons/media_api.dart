// Bridge between Flutter and the Android media engine.
// Regenerate with: dart run pigeon --input pigeons/media_api.dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/native/pigeon/media_api.g.dart',
    kotlinOut:
        'android/app/src/main/kotlin/app/auvie/engine/pigeon/MediaApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'app.auvie.engine.pigeon'),
    dartPackageName: 'auvie',
  ),
)
enum MediaKind { photo, video }

class PickedMedia {
  PickedMedia({
    required this.uri,
    required this.kind,
    required this.width,
    required this.height,
    this.durationMs,
  });

  /// Persisted content:// URI, or a file:// copy when persisting failed.
  String uri;
  MediaKind kind;

  /// Size after EXIF / container rotation.
  int width;
  int height;
  int? durationMs;
}

/// Resolved develop parameters: the 12 scalar adjustments (same order as
/// `Adjustment.values`) plus the curve lookup table.
class DevelopParams {
  DevelopParams({
    required this.exposure,
    required this.brightness,
    required this.contrast,
    required this.highlights,
    required this.shadows,
    required this.saturation,
    required this.temperature,
    required this.tint,
    required this.sharpen,
    required this.grain,
    required this.fade,
    required this.vignette,
    required this.curveLut,
    required this.geometry,
  });

  double exposure;
  double brightness;
  double contrast;
  double highlights;
  double shadows;
  double saturation;
  double temperature;
  double tint;
  double sharpen;
  double grain;
  double fade;
  double vignette;

  /// 256×1 RGBA (1024 bytes).
  Uint8List curveLut;

  /// Output uv → source uv as `[a, b, c, d, tx, ty]`
  /// (`x' = a·x + b·y + tx`, `y' = c·x + d·y + ty`): crop, turns, flips and
  /// straighten (lib/core/models/crop_geometry.dart).
  Float64List geometry;
}

enum ExportFormat { jpeg, png }

enum LayerBlend { normal, screen, multiply, overlay, softLight }

/// One element rasterized by Flutter (text, brush, sticker, overlay,
/// frame), composited over the developed photo before encoding.
class ExportLayer {
  ExportLayer({
    required this.path,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.blend,
    required this.opacity,
    this.startMs,
    this.endMs,
  });

  /// PNG file.
  String path;

  /// Where it goes, in output pixels (the PNG is scaled to fit).
  double left;
  double top;
  double width;
  double height;
  LayerBlend blend;

  /// 0…1.
  double opacity;

  /// Videos: when the layer shows, in ms of the original clip (null =
  /// always). Photos ignore them.
  int? startMs;
  int? endMs;
}

class ExportRequest {
  ExportRequest({
    required this.uri,
    required this.params,
    required this.format,
    required this.outputWidth,
    required this.outputHeight,
    required this.decodeMaxPx,
    required this.keepMetadata,
    required this.fileName,
    required this.layers,
  });

  String uri;
  DevelopParams params;
  ExportFormat format;
  int outputWidth;
  int outputHeight;

  /// Longer side to decode the original at (enough detail for the crop).
  int decodeMaxPx;

  /// Copy date, camera and location from the original (JPEG only).
  bool keepMetadata;

  /// Without extension.
  String fileName;

  /// Elements in z-order, bottom first.
  List<ExportLayer> layers;
}

/// A video export: develop, crop and scale to [outputWidth]×[outputHeight]
/// (even), keep [trimStartMs]…[trimEndMs] of the original, composite the
/// layers in their time ranges and encode H.264 / AAC MP4.
class VideoExportRequest {
  VideoExportRequest({
    required this.uri,
    required this.params,
    required this.outputWidth,
    required this.outputHeight,
    required this.trimStartMs,
    required this.trimEndMs,
    required this.includeAudio,
    required this.videoBitrate,
    required this.fileName,
    required this.layers,
  });

  String uri;
  DevelopParams params;
  int outputWidth;
  int outputHeight;
  int trimStartMs;
  int trimEndMs;
  bool includeAudio;

  /// Bits per second.
  int videoBitrate;

  /// Without extension.
  String fileName;

  /// Elements in z-order, bottom first, with their time ranges.
  List<ExportLayer> layers;
}

class ExportResult {
  ExportResult({
    required this.mediaUri,
    required this.filePath,
    required this.width,
    required this.height,
    required this.bytes,
    this.durationMs,
  });

  /// content:// URI of the copy saved in Pictures/Auvie or Movies/Auvie.
  String mediaUri;

  /// App-private copy, used for sharing.
  String filePath;
  int width;
  int height;
  int bytes;

  /// Videos only.
  int? durationMs;
}

class ExportProgress {
  ExportProgress({
    required this.jobId,
    required this.fraction,
    required this.stage,
  });

  String jobId;

  /// 0…1 over the whole export.
  double fraction;

  /// decode, render, encode or save.
  String stage;
}

class PreviewInfo {
  PreviewInfo({
    required this.textureId,
    required this.width,
    required this.height,
  });

  int textureId;

  /// Size of the decoded preview image.
  int width;
  int height;
}

class VideoPreviewInfo {
  VideoPreviewInfo({
    required this.textureId,
    required this.width,
    required this.height,
    required this.durationMs,
    required this.hasAudio,
  });

  int textureId;

  /// Upright size of the video.
  int width;
  int height;
  int durationMs;
  bool hasAudio;
}

/// Where a video preview is: sent about 30 times a second while playing,
/// and on every play, pause and seek.
class PlaybackState {
  PlaybackState({
    required this.textureId,
    required this.positionMs,
    required this.playing,
  });

  int textureId;
  int positionMs;
  bool playing;
}

@HostApi()
abstract class MediaHostApi {
  /// Opens the system Photo Picker. Null when the user cancels.
  @async
  PickedMedia? pickMedia(MediaKind kind);

  @async
  PickedMedia probe(String uri);

  /// JPEG thumbnail whose longer side is at most [maxPx].
  @async
  Uint8List thumbnail(String uri, int maxPx);

  /// Decodes the photo (longer side ≤ [maxPx]) and shows it in a texture.
  @async
  PreviewInfo createPhotoPreview(String uri, int maxPx);

  /// Opens the video paused at its first frame, shown in a texture rendered
  /// at most [maxPx] on the longer side. The texture works with
  /// [updateEdit], [setShowOriginal], [resizePreview] and [disposePreview].
  @async
  VideoPreviewInfo createVideoPreview(String uri, int maxPx);

  void playVideo(int textureId);

  void pauseVideo(int textureId);

  /// [exact] false seeks to the nearest key frame (fast, for scrubbing).
  void seekVideo(int textureId, int positionMs, bool exact);

  /// Playback loops inside [startMs]…[endMs] (the trim).
  void setPlaybackRange(int textureId, int startMs, int endMs);

  void setVideoMuted(int textureId, bool muted);

  /// [count] JPEG frames evenly spread over the video, longer side ≤ [maxPx].
  @async
  List<Uint8List> videoFrames(String uri, int count, int maxPx);

  /// Peak level (0…1) of the sound in each of [buckets] equal slices. Null
  /// when the video has no sound.
  @async
  Float64List? waveform(String uri, int buckets);

  /// Coalesced: only the latest params are rendered on the next frame.
  void updateEdit(int textureId, DevelopParams params);

  void setShowOriginal(int textureId, bool original);

  void disposePreview(int textureId);

  /// Sets the preview's pixel size (when the crop's aspect or layout change).
  void resizePreview(int textureId, int width, int height);

  /// Renders offscreen and returns a JPEG whose longer side is ≤ [maxPx]:
  /// the photo, or the video's frame at [timeMs].
  @async
  Uint8List renderFrame(
    String uri,
    DevelopParams params,
    int maxPx,
    int? timeMs,
  );

  /// Free bytes where exports are written.
  int availableBytes();

  /// Develops at full size, saves to Pictures/Auvie and keeps an app copy.
  /// Progress arrives on [ExportEvents.exportProgress] under [jobId].
  @async
  ExportResult exportPhoto(String jobId, ExportRequest request);

  /// Exports in a background job with a progress notification, saves to
  /// Movies/Auvie and keeps an app copy. Progress arrives like photos'.
  @async
  ExportResult exportVideo(String jobId, VideoExportRequest request);

  /// Photos and videos.
  void cancelExport(String jobId);

  /// Asks to show notifications (Android 13+). True when allowed.
  @async
  bool requestNotificationPermission();

  /// Puts the saved image on the clipboard.
  @async
  void copyToClipboard(String mediaUri);
}

@EventChannelApi()
abstract class ExportEvents {
  ExportProgress exportProgress();

  PlaybackState playbackState();
}
