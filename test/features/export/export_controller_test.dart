import 'dart:async';

import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/export/export_controller.dart';
import 'package:auvie/features/export/export_options.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_media_engine.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestApp app;
  late FakeMediaEngine engine;
  late Project project;

  ExportController controller() =>
      app.container.read(exportControllerProvider(project.id).notifier);
  ExportSession session() =>
      app.container.read(exportControllerProvider(project.id)).requireValue;

  setUp(() async {
    engine = FakeMediaEngine();
    app = await TestApp.create(engine: engine);
    project = await app.container
        .read(projectRepositoryProvider)
        .create(photoMedia, name: 'Roll 014 · 07');
    // Keep the provider alive across awaits.
    app.container.listen(exportControllerProvider(project.id), (_, _) {});
    await app.container.read(exportControllerProvider(project.id).future);
  });

  tearDown(() => app.dispose());

  test('starts with the remembered choices', () async {
    expect(session().options, defaultExportOptions);
    controller().setOptions((
      format: ExportFormat.png,
      size: ExportSize.web,
      keepMetadata: true,
    ));
    await pumpEventQueue();
    expect(app.container.read(appSettingsProvider).exportChoices, (
      format: 'png',
      size: 'web',
      keepMetadata: true,
    ));
  });

  test('exports the crop at the chosen size and finishes', () async {
    await controller().start();

    final job = engine.exports.single;
    expect((job.outputWidth, job.outputHeight), (4000, 3000));
    expect(job.decodeMaxPx, 4000);
    expect(job.fileName, 'Roll 014 · 07');
    expect(job.keepMetadata, isFalse);
    expect(session().phase, isA<ExportDone>());
  });

  test('reports progress and an estimate while running', () async {
    engine.exportGate = Completer<void>();
    final running = controller().start();
    await pumpEventQueue();
    final jobId = (session().phase as ExportRunning).jobId;

    engine.emitProgress(jobId, 0.5);
    await pumpEventQueue();
    final phase = session().phase as ExportRunning;
    expect(phase.fraction, 0.5);
    expect(phase.etaSeconds, isNotNull);

    engine.emitProgress('another-job', 0.9);
    await pumpEventQueue();
    expect((session().phase as ExportRunning).fraction, 0.5);

    engine.exportGate!.complete();
    await running;
    expect(session().phase, isA<ExportDone>());
  });

  test('cancelling returns to the options', () async {
    engine.exportGate = Completer<void>();
    final running = controller().start();
    await pumpEventQueue();

    await controller().cancel();
    await running;

    expect(engine.cancelled, hasLength(1));
    expect(session().phase, isA<ExportIdle>());
  });

  test(
    'short storage fails before starting, with the missing amount',
    () async {
      engine.freeBytes = 1000;
      await controller().start();

      final phase = session().phase as ExportFailed;
      expect(phase.error, MediaEngineError.storageFull);
      expect(phase.missingBytes, greaterThan(0));
      expect(engine.exports, isEmpty);
    },
  );

  test('engine errors are shown, and a smaller size can be retried', () async {
    engine.exportError = const MediaEngineException(
      MediaEngineError.storageFull,
      'disk',
      48000000,
    );
    await controller().start();
    expect((session().phase as ExportFailed).missingBytes, 48000000);

    engine.exportError = null;
    await controller().retrySmaller();
    expect(session().options.size, ExportSize.large);
    expect(session().phase, isA<ExportDone>());
  });

  test('reset goes back to the options', () async {
    await controller().start();
    controller().reset();
    expect(session().phase, isA<ExportIdle>());
  });
}
