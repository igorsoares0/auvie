import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/features/export/element_layers.dart';

/// Records what would be rasterized, without images or files (widget tests
/// can't do real I/O under their fake clock).
class FakeElementRasterizer implements ElementLayerRasterizer {
  final rasterized = <List<EditElement>>[];
  final cleaned = <String>[];

  @override
  Future<List<ExportLayerSpec>> rasterize({
    required String jobId,
    required List<EditElement> elements,
    required ({int width, int height}) output,
  }) async {
    rasterized.add(elements);
    return [
      for (final (i, e) in elements.indexed)
        (
          path: '/cache/layers/$jobId/$i.png',
          left: 0,
          top: 0,
          width: output.width.toDouble(),
          height: output.height.toDouble(),
          blend: layerBlendOf(e),
          opacity: 1,
        ),
    ];
  }

  @override
  Future<void> clean(String jobId) async => cleaned.add(jobId);
}
