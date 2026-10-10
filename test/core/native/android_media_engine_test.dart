import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/adjustments.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/android_media_engine.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/native/pigeon/media_api.g.dart' as pigeon;
import 'package:auvie/core/native/render_params.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements pigeon.MediaHostApi;

double _field(pigeon.DevelopParams p, Adjustment a) => switch (a) {
  Adjustment.exposure => p.exposure,
  Adjustment.brightness => p.brightness,
  Adjustment.contrast => p.contrast,
  Adjustment.highlights => p.highlights,
  Adjustment.shadows => p.shadows,
  Adjustment.saturation => p.saturation,
  Adjustment.temperature => p.temperature,
  Adjustment.tint => p.tint,
  Adjustment.sharpen => p.sharpen,
  Adjustment.grain => p.grain,
  Adjustment.fade => p.fade,
  Adjustment.vignette => p.vignette,
};

void main() {
  setUpAll(() {
    registerFallbackValue(pigeon.MediaKind.photo);
    final params = pigeon.DevelopParams(
      exposure: 0,
      brightness: 0,
      contrast: 0,
      highlights: 0,
      shadows: 0,
      saturation: 0,
      temperature: 0,
      tint: 0,
      sharpen: 0,
      grain: 0,
      fade: 0,
      vignette: 0,
      curveLut: Uint8List(0),
      geometry: Float64List(6),
    );
    registerFallbackValue(params);
    registerFallbackValue(
      pigeon.VideoExportRequest(
        uri: '',
        params: params,
        outputWidth: 2,
        outputHeight: 2,
        trimStartMs: 0,
        trimEndMs: 1,
        includeAudio: true,
        videoBitrate: 1,
        fileName: '',
        layers: [],
      ),
    );
  });

  group('developParamsFrom', () {
    test('sends each adjustment in its own field', () {
      for (final (i, adjustment) in Adjustment.values.indexed) {
        final value = (i + 1) / 100;
        final params = developParamsFrom(
          RenderParams(
            adjustments: Adjustments.of({adjustment: value}),
            curveLut: RenderParams.neutral.curveLut,
          ),
        );
        for (final other in Adjustment.values) {
          expect(
            _field(params, other),
            other == adjustment ? closeTo(value, 1e-12) : 0,
            reason: '${adjustment.name} → ${other.name}',
          );
        }
      }
    });

    test('sends the curve LUT and the geometry', () {
      final params = developParamsFrom(RenderParams.neutral);
      expect(params.curveLut, RenderParams.neutral.curveLut);
      expect(params.geometry, [1, 0, 0, 1, 0, 0]);
    });

    test('the shared shader vectors use the same parameter names', () {
      final fixture = jsonDecode(
        File('test_fixtures/develop_vectors.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      expect(
        fixture['parameters'],
        Adjustment.values.map((a) => a.name).toList(),
      );
      for (final vector
          in (fixture['vectors'] as List).cast<Map<String, dynamic>>()) {
        expect(
          Adjustment.values.map((a) => a.name),
          containsAll((vector['params'] as Map).keys),
          reason: vector['name'] as String,
        );
      }
    });
  });

  test('converts picked media', () {
    final media = mediaRefFromPigeon(
      pigeon.PickedMedia(
        uri: 'content://v',
        kind: pigeon.MediaKind.video,
        width: 1080,
        height: 1920,
        durationMs: 5000,
      ),
    );
    expect(
      media,
      const MediaRef(
        uri: 'content://v',
        type: MediaType.video,
        width: 1080,
        height: 1920,
        durationMs: 5000,
      ),
    );
  });

  group('AndroidMediaEngine', () {
    late _MockApi api;
    late AndroidMediaEngine engine;

    setUp(() {
      api = _MockApi();
      engine = AndroidMediaEngine(api: api);
    });

    test('a cancelled pick returns null', () async {
      when(() => api.pickMedia(any())).thenAnswer((_) async => null);
      expect(await engine.pickMedia(MediaType.photo), isNull);
      verify(() => api.pickMedia(pigeon.MediaKind.photo)).called(1);
    });

    test('creates previews', () async {
      when(() => api.createPhotoPreview('content://p', 2048)).thenAnswer(
        (_) async =>
            pigeon.PreviewInfo(textureId: 7, width: 2048, height: 1536),
      );
      expect(await engine.createPhotoPreview('content://p', maxPx: 2048), (
        textureId: 7,
        width: 2048,
        height: 1536,
      ));
    });

    test('forwards edits, compare and dispose', () async {
      when(() => api.updateEdit(any(), any())).thenAnswer((_) async {});
      when(() => api.setShowOriginal(any(), any())).thenAnswer((_) async {});
      when(() => api.disposePreview(any())).thenAnswer((_) async {});

      await engine.updateEdit(3, RenderParams.neutral);
      await engine.setShowOriginal(3, original: true);
      await engine.disposePreview(3);

      verify(() => api.updateEdit(3, any())).called(1);
      verify(() => api.setShowOriginal(3, true)).called(1);
      verify(() => api.disposePreview(3)).called(1);
    });

    test('translates platform errors', () async {
      when(() => api.probe(any())).thenThrow(
        PlatformException(code: 'media_unavailable', message: 'gone'),
      );
      await expectLater(
        engine.probe('content://x'),
        throwsA(
          isA<MediaEngineException>()
              .having(
                (e) => e.error,
                'error',
                MediaEngineError.mediaUnavailable,
              )
              .having((e) => e.message, 'message', 'gone'),
        ),
      );
    });

    test('unknown error codes become unknown', () async {
      when(() => api.thumbnail(any(), any()))
          .thenThrow(PlatformException(code: 'IllegalStateException'));
      await expectLater(
        engine.thumbnail('content://x', maxPx: 256),
        throwsA(
          isA<MediaEngineException>().having(
            (e) => e.error,
            'error',
            MediaEngineError.unknown,
          ),
        ),
      );
    });

    test('renders offscreen', () async {
      when(() => api.renderFrame(any(), any(), any(), any()))
          .thenAnswer((_) async => Uint8List.fromList([1, 2, 3]));
      expect(
        await engine.renderPhoto(
          'content://p',
          RenderParams.neutral,
          maxPx: 1080,
        ),
        [1, 2, 3],
      );
      verify(() => api.renderFrame('content://p', any(), 1080, null));
    });

    test('renders a video frame at a time', () async {
      when(() => api.renderFrame(any(), any(), any(), any()))
          .thenAnswer((_) async => Uint8List.fromList([4]));
      await engine.renderVideoFrame(
        'content://v',
        RenderParams.neutral,
        maxPx: 720,
        timeMs: 1500,
      );
      verify(() => api.renderFrame('content://v', any(), 720, 1500));
    });

    test('opens a video preview', () async {
      when(() => api.createVideoPreview(any(), any())).thenAnswer(
        (_) async => pigeon.VideoPreviewInfo(
          textureId: 7,
          width: 1080,
          height: 1920,
          durationMs: 8000,
          hasAudio: false,
        ),
      );
      expect(await engine.createVideoPreview('content://v', maxPx: 1280), (
        textureId: 7,
        width: 1080,
        height: 1920,
        durationMs: 8000,
        hasAudio: false,
      ));
    });

    test('sends video layers with their time ranges', () async {
      when(() => api.exportVideo(any(), any())).thenAnswer(
        (_) async => pigeon.ExportResult(
          mediaUri: 'content://media/video/1',
          filePath: '/f/a.mp4',
          width: 720,
          height: 1280,
          bytes: 99,
          durationMs: 2000,
        ),
      );
      final result = await engine.exportVideo('job', (
        uri: 'content://v',
        params: RenderParams.neutral,
        outputWidth: 720,
        outputHeight: 1280,
        trimStartMs: 500,
        trimEndMs: 2500,
        includeAudio: false,
        videoBitrate: 6000000,
        fileName: 'Film',
        layers: [
          (
            path: '/l/0.png',
            left: 1,
            top: 2,
            width: 3,
            height: 4,
            blend: LayerBlend.screen,
            opacity: 0.5,
            startMs: 1000,
            endMs: 2000,
          ),
        ],
      ));
      expect(result.durationMs, 2000);
      final request =
          verify(() => api.exportVideo('job', captureAny())).captured.single
              as pigeon.VideoExportRequest;
      expect(request.trimStartMs, 500);
      expect(request.includeAudio, isFalse);
      expect(request.layers.single.startMs, 1000);
      expect(request.layers.single.endMs, 2000);
      expect(request.layers.single.blend, pigeon.LayerBlend.screen);
    });
  });

  test('error codes match the Kotlin constants', () {
    final kotlin = File(
      'android/app/src/main/kotlin/app/auvie/engine/EngineErrors.kt',
    ).readAsStringSync();
    for (final error in MediaEngineError.values) {
      if (error == MediaEngineError.unknown) continue;
      expect(kotlin, contains('"${error.code}"'), reason: error.name);
    }
    expect(
      const MediaEngineException(MediaEngineError.decodeFailed, 'x').toString(),
      'MediaEngineException(decode_failed: x)',
    );
  });
}
