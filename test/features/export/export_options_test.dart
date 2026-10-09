import 'package:auvie/core/models/crop.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/features/export/export_options.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  final project = Project(
    id: 'p',
    media: photoMedia, // 4000 × 3000
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('sizes never upscale and respect their cap', () {
    expect(exportPixels(project, ExportSize.original), (
      width: 4000,
      height: 3000,
    ));
    expect(exportPixels(project, ExportSize.large), (
      width: 4000,
      height: 3000,
    ));
    final web = exportPixels(project, ExportSize.web);
    expect(web.width * web.height, lessThanOrEqualTo(2000000));
  });

  test('the crop sets the export size', () {
    final cropped = project.copyWith(
      edit: EditState(
        crop: const CropTransform().withAspect(
          CropAspect.square,
          mediaRatio: 4 / 3,
        ),
      ),
    );
    expect(exportPixels(cropped, ExportSize.original), (
      width: 3000,
      height: 3000,
    ));
  });

  test('smaller sizes step down to web', () {
    expect(ExportSize.original.smaller, ExportSize.large);
    expect(ExportSize.large.smaller, ExportSize.web);
    expect(ExportSize.web.smaller, isNull);
  });

  test('labels', () {
    expect(megapixels((width: 4000, height: 3000)), '12 MP');
    expect(megapixels((width: 1632, height: 1224)), '2.0 MP');
    expect(megapixels((width: 1000, height: 1500)), '1.5 MP');
    expect(megabytes(4800000), '4.6 MB');
    expect(megabytes(50 * 1024 * 1024), '50 MB');
    expect(aspectLabel(4000, 3000), '4:3');
    expect(aspectLabel(3000, 3000), '1:1');
    expect(aspectLabel(4001, 3000), '1.33');
    expect(ExportFormat.png.note, 'Lossless');
  });

  test('PNG needs more room than JPEG', () {
    const pixels = (width: 4000, height: 3000);
    expect(
      requiredBytes(pixels, ExportFormat.png),
      greaterThan(requiredBytes(pixels, ExportFormat.jpeg)),
    );
  });

  test('saved choices are read back, unknown ones fall back', () {
    expect(
      exportOptionsFrom((format: 'png', size: 'web', keepMetadata: true)),
      (format: ExportFormat.png, size: ExportSize.web, keepMetadata: true),
    );
    expect(
      exportOptionsFrom((format: null, size: 'huge', keepMetadata: false)),
      defaultExportOptions,
    );
  });
}
