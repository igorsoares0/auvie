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
}

class ExportResult {
  ExportResult({
    required this.mediaUri,
    required this.filePath,
    required this.width,
    required this.height,
    required this.bytes,
  });

  /// content:// URI of the copy saved in Pictures/Auvie.
  String mediaUri;

  /// App-private copy, used for sharing.
  String filePath;
  int width;
  int height;
  int bytes;
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

  /// Coalesced: only the latest params are rendered on the next frame.
  void updateEdit(int textureId, DevelopParams params);

  void setShowOriginal(int textureId, bool original);

  void disposePreview(int textureId);

  /// Sets the preview's pixel size (when the crop's aspect or layout change).
  void resizePreview(int textureId, int width, int height);

  /// Renders offscreen and returns a JPEG whose longer side is ≤ [maxPx].
  @async
  Uint8List renderPhoto(String uri, DevelopParams params, int maxPx);

  /// Free bytes where exports are written.
  int availableBytes();

  /// Develops at full size, saves to Pictures/Auvie and keeps an app copy.
  /// Progress arrives on [ExportEvents.exportProgress] under [jobId].
  @async
  ExportResult exportPhoto(String jobId, ExportRequest request);

  void cancelExport(String jobId);

  /// Puts the saved image on the clipboard.
  @async
  void copyToClipboard(String mediaUri);
}

@EventChannelApi()
abstract class ExportEvents {
  ExportProgress exportProgress();
}
