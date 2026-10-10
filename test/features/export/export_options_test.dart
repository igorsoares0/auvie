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

  group('video sizes', () {
    Project video({CropTransform crop = const CropTransform()}) => Project(
      id: 'v',
      media: videoMedia, // 1080 × 1920
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
      edit: EditState(crop: crop),
    );

    test('720p and 1080p set the shorter side; original keeps it', () {
      expect(videoExportPixels(video(), VideoExportSize.p720), (
        width: 720,
        height: 1280,
      ));
      expect(videoExportPixels(video(), VideoExportSize.p1080), (
        width: 1080,
        height: 1920,
      ));
      expect(videoExportPixels(video(), VideoExportSize.original), (
        width: 1080,
        height: 1920,
      ));
    });

    test('a square crop at 720p is 720 × 720', () {
      final square = video(
        crop: const CropTransform().withAspect(
          CropAspect.square,
          mediaRatio: videoMedia.aspectRatio,
        ),
      );
      expect(videoExportPixels(square, VideoExportSize.p720), (
        width: 720,
        height: 720,
      ));
    });

    test('sizes are even and never upscaled', () {
      const odd = MediaRef(
        uri: 'content://v',
        type: MediaType.video,
        width: 641,
        height: 361,
        durationMs: 3000,
      );
      final small = video().copyWith(media: odd);
      expect(videoExportPixels(small, VideoExportSize.p1080), (
        width: 640,
        height: 360,
      ));
      expect(videoSizeAvailable(small, VideoExportSize.p720), isFalse);
      expect(videoSizeAvailable(small, VideoExportSize.original), isTrue);
      expect(videoSizeAvailable(video(), VideoExportSize.p1080), isTrue);
    });

    test('original stops at 4K', () {
      const huge = MediaRef(
        uri: 'content://v',
        type: MediaType.video,
        width: 7680,
        height: 4320,
        durationMs: 3000,
      );
      final pixels = videoExportPixels(
        video().copyWith(media: huge),
        VideoExportSize.original,
      );
      expect(pixels, (width: maxVideoSide, height: 2160));
    });

    test('bitrate grows with the picture', () {
      expect(videoBitrate((width: 720, height: 1280)), 5529600);
      expect(videoBitrate((width: 1080, height: 1920)), 12441600);
      expect(videoBitrate((width: 3840, height: 2160)), 49766400);
      expect(videoBitrate((width: 2, height: 2)), 1000000);
    });

    test('needed room covers both copies of the file', () {
      // 8 Mbps + 128 kbps for 10 s = 10.16 MB, twice, plus 10%.
      expect(
        requiredVideoBytes(
          videoBitrate: 8000000,
          durationMs: 10000,
          includeAudio: true,
        ),
        22352000,
      );
      expect(
        requiredVideoBytes(
          videoBitrate: 8000000,
          durationMs: 10000,
          includeAudio: false,
        ),
        22000000,
      );
    });
  });
}
