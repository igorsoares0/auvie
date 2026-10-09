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

  /// Renders offscreen and returns a JPEG whose longer side is ≤ [maxPx].
  @async
  Uint8List renderPhoto(String uri, DevelopParams params, int maxPx);
}
