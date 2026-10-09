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

/// A full-size photo export (spec §34). `decodeMaxPx` is the longer side to
/// decode the original at; `fileName` has no extension.
typedef ExportJob = ({
  String uri,
  RenderParams params,
  ExportFormat format,
  int outputWidth,
  int outputHeight,
  int decodeMaxPx,
  bool keepMetadata,
  String fileName,
});

/// `mediaUri` is the copy in Pictures/Auvie; `filePath` the app's copy, for
/// sharing.
typedef ExportResult = ({
  String mediaUri,
  String filePath,
  int width,
  int height,
  int bytes,
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

  Future<void> cancelExport(String jobId);

  Stream<ExportProgress> get exportProgress;

  /// Puts a saved image on the clipboard.
  Future<void> copyToClipboard(String mediaUri);
}
