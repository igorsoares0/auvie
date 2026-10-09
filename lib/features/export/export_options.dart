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
