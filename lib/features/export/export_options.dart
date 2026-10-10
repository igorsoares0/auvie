import 'dart:math' as math;

import 'package:auvie/core/models/crop_geometry.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:collection/collection.dart';

/// Size choices of the Export screen (handoff 07).
enum ExportSize {
  /// The crop at full resolution, capped for memory.
  original('Original', 32000000),
  large('Large', 12000000),
  web('Web', 2000000);

  new(this.label, this.maxPixels);

  final String label;
  final int maxPixels;

  /// The next smaller size, offered when storage is short.
  ExportSize? get smaller => switch (this) {
    original => large,
    large => web,
    web => null,
  };
}

extension ExportFormatLabels on ExportFormat {
  String get label => name.toUpperCase();

  /// The italic line under the format name.
  String get note => switch (this) {
    ExportFormat.jpeg => 'Smallest',
    ExportFormat.png => 'Lossless',
  };

  String get extension => switch (this) {
    ExportFormat.jpeg => 'jpg',
    ExportFormat.png => 'png',
  };

  String get mimeType => switch (this) {
    ExportFormat.jpeg => 'image/jpeg',
    ExportFormat.png => 'image/png',
  };
}

typedef ExportOptions = ({
  ExportFormat format,
  ExportSize size,
  bool keepMetadata,
});

const ({ExportFormat format, bool keepMetadata, ExportSize size})
defaultExportOptions = (
  format: ExportFormat.jpeg,
  size: ExportSize.original,
  keepMetadata: false,
);

ExportOptions exportOptionsFrom(
  ({String? format, String? size, bool keepMetadata}) saved,
) => (
  format:
      ExportFormat.values.firstWhereOrNull((f) => f.name == saved.format) ??
      defaultExportOptions.format,
  size:
      ExportSize.values.firstWhereOrNull((s) => s.name == saved.size) ??
      defaultExportOptions.size,
  keepMetadata: saved.keepMetadata,
);

/// Output size of [project] at [size].
({int width, int height}) exportPixels(Project project, ExportSize size) =>
    CropGeometry.outputSize(
      project.edit.crop,
      project.media,
      maxPixels: size.maxPixels,
    );

/// "20 MP", "1.9 MP".
String megapixels(({int width, int height}) pixels) {
  final mp = pixels.width * pixels.height / 1e6;
  return mp >= 10 || mp == mp.roundToDouble()
      ? '${mp.round()} MP'
      : '${mp.toStringAsFixed(1)} MP';
}

/// Room an export needs while running (app copy + gallery copy). Mirrors
/// ExportPlanner.requiredBytes on the Kotlin side.
int requiredBytes(({int width, int height}) pixels, ExportFormat format) {
  final perPixel = switch (format) {
    ExportFormat.jpeg => 0.6,
    ExportFormat.png => 3.2,
  };
  return (pixels.width * pixels.height * perPixel * 2).round();
}

/// "4.8 MB", "48 MB".
String megabytes(int bytes) {
  final mb = bytes / (1024 * 1024);
  return mb >= 10 ? '${mb.round()} MB' : '${mb.toStringAsFixed(1)} MB';
}

/// "4:3", "4:5", or the decimal ratio when it isn't a simple one.
String aspectLabel(int width, int height) {
  int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
  final d = gcd(width, height);
  final (w, h) = (width ~/ d, height ~/ d);
  if (w <= 21 && h <= 21) return '$w:$h';
  return (width / height).toStringAsFixed(2);
}

/// Size choices of a video export: the shorter side, never upscaled.
enum VideoExportSize {
  p720('720p', 720),
  p1080('1080p', 1080),
  original('Original', null);

  new(this.label, this.shortSide);

  final String label;

  /// Null keeps the crop's own resolution.
  final int? shortSide;

  /// The next smaller size, offered when storage is short.
  VideoExportSize? get smaller => switch (this) {
    original => p1080,
    p1080 => p720,
    p720 => null,
  };
}

/// Longer side limit of a video export (most H.264 encoders stop at 4K).
/// Mirrors VideoExportPlanner.MAX_SIDE.
const maxVideoSide = 3840;

/// The crop of [project] at the video's own resolution.
({int width, int height}) _fullVideoCrop(Project project) =>
    CropGeometry.outputSize(
      project.edit.crop,
      project.media,
      maxPixels: 1 << 40,
    );

/// Output size of a video at [size]: even (H.264 needs it), never larger
/// than the original, at most [maxVideoSide] on the longer side.
({int width, int height}) videoExportPixels(
  Project project,
  VideoExportSize size,
) {
  final full = _fullVideoCrop(project);
  final short = math.min(full.width, full.height);
  final long = math.max(full.width, full.height);
  var scale = size.shortSide == null
      ? 1.0
      : math.min(1, size.shortSide! / short).toDouble();
  scale = math.min(scale, maxVideoSide / long);
  int even(double v) => math.max(2, (v / 2).floor() * 2);
  return (width: even(full.width * scale), height: even(full.height * scale));
}

/// Whether [size] makes sense for [project] (no upscaling: 1080p is
/// offered only for videos at least that big).
bool videoSizeAvailable(Project project, VideoExportSize size) {
  final side = size.shortSide;
  if (side == null) return true;
  final full = _fullVideoCrop(project);
  return side <= math.min(full.width, full.height);
}

/// "1080 × 1920": the note under a video size.
String videoSizeNote(({int width, int height}) pixels) =>
    '${pixels.width} × ${pixels.height}';

/// H.264 bitrate for [pixels] at about 30 fps (0.2 bits per pixel):
/// ~5.5 Mbps at 720p, ~12 Mbps at 1080p, ~50 Mbps at 4K.
int videoBitrate(({int width, int height}) pixels) =>
    (pixels.width * pixels.height * 30 * 0.2).round().clamp(1000000, 50000000);

/// AAC bitrate. Mirrors VideoExportPlanner.AUDIO_BITRATE.
const audioBitrate = 128000;

/// Room a video export needs while running (app copy + gallery copy, plus
/// 10%). Mirrors VideoExportPlanner.requiredBytes on the Kotlin side.
int requiredVideoBytes({
  required int videoBitrate,
  required int durationMs,
  required bool includeAudio,
}) {
  final bitrate = videoBitrate + (includeAudio ? audioBitrate : 0);
  return (bitrate * durationMs / 8000 * 2 * 1.1).floor();
}
