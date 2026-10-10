import 'dart:async';

import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/models/crop_geometry.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/models/video_timeline.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:auvie/core/native/render_params.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:auvie/features/export/element_layers.dart';
import 'package:auvie/features/export/export_options.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'export_controller.g.dart';

sealed class ExportPhase {
  const new();
}

/// Choosing options.
class ExportIdle extends ExportPhase {
  const new();
}

/// S3: [fraction] 0…1; [etaSeconds] once there is enough progress to tell.
class ExportRunning extends ExportPhase {
  const new({
    required this.jobId,
    required this.fraction,
    this.etaSeconds,
    this.thenShare = false,
  });

  final String jobId;
  final double fraction;
  final int? etaSeconds;

  /// SHARE… exports first, then opens the share sheet.
  final bool thenShare;
}

/// S4.
class ExportDone extends ExportPhase {
  const new(this.result, {this.thenShare = false});

  final ExportResult result;
  final bool thenShare;
}

/// S5. [missingBytes] when storage is short.
class ExportFailed extends ExportPhase {
  const new(this.error, {this.missingBytes});

  final MediaEngineError error;
  final int? missingBytes;
}

@immutable
class ExportSession {
  const new({
    required this.project,
    required this.preset,
    required this.options,
    this.videoSize = VideoExportSize.p1080,
    this.phase = const ExportIdle(),
  });

  final Project project;
  final Preset? preset;
  final ExportOptions options;

  /// Videos only.
  final VideoExportSize videoSize;
  final ExportPhase phase;

  bool get isVideo => project.media.type == MediaType.video;

  ExportSession copyWith({
    ExportOptions? options,
    VideoExportSize? videoSize,
    ExportPhase? phase,
  }) => ExportSession(
    project: project,
    preset: preset,
    options: options ?? this.options,
    videoSize: videoSize ?? this.videoSize,
    phase: phase ?? this.phase,
  );

  ({int width, int height}) pixels([ExportSize? size]) =>
      exportPixels(project, size ?? options.size);

  ({int width, int height}) videoPixels([VideoExportSize? size]) =>
      videoExportPixels(project, size ?? videoSize);

  /// Length of the exported video (the trim).
  int get videoDurationMs {
    final timeline = project.edit.video ?? const VideoTimeline();
    return timeline.trimmedDurationMs(project.media.durationMs ?? 0);
  }

  /// Sound goes out unless muted in the editor (decision M6) or absent.
  bool get includesAudio => !(project.edit.video?.muted ?? false);

  int get videoBitrateBps => videoBitrate(videoPixels());

  /// Expected size of the video file.
  int get videoBytes =>
      requiredVideoBytes(
        videoBitrate: videoBitrateBps,
        durationMs: videoDurationMs,
        includeAudio: includesAudio,
      ) ~/
      2.2;
}

/// Progress below this is too early to estimate time from.
const _etaFrom = 0.08;

/// The Export screen for one project (spec §34–35, handoff 07 / S3–S5).
@Riverpod(retry: _noRetry)
class ExportController extends _$ExportController {
  StreamSubscription<ExportProgress>? _progress;
  DateTime? _startedAt;

  @override
  Future<ExportSession> build(String projectId) async {
    ref.onDispose(() => _progress?.cancel());
    final project = await ref.watch(projectRepositoryProvider).find(projectId);
    if (project == null) throw ProjectNotFoundException(projectId);
    final catalog = await ref.watch(catalogProvider.future);
    final presetId = project.edit.preset?.presetId;
    final settings = ref.read(appSettingsProvider);
    final savedVideoSize = VideoExportSize.values.firstWhereOrNull(
      (s) => s.name == settings.videoExportSize,
    );
    return ExportSession(
      project: project,
      preset: presetId == null ? null : catalog.presetById(presetId),
      options: exportOptionsFrom(settings.exportChoices),
      videoSize: _fitting(project, savedVideoSize ?? VideoExportSize.p1080),
    );
  }

  /// [size], or the largest smaller one the video allows.
  static VideoExportSize _fitting(Project project, VideoExportSize size) {
    VideoExportSize? s = size;
    while (s != null && !videoSizeAvailable(project, s)) {
      s = s.smaller;
    }
    return s ?? VideoExportSize.original;
  }

  ExportSession get _session => state.requireValue;

  void _set(ExportSession next) => state = AsyncData(next);

  MediaEngine get _engine => ref.read(mediaEngineProvider);

  void setOptions(ExportOptions options) {
    _set(_session.copyWith(options: options));
    unawaited(
      ref
          .read(appSettingsProvider)
          .saveExportChoices(
            format: options.format.name,
            size: options.size.name,
            keepMetadata: options.keepMetadata,
          ),
    );
  }

  void setVideoSize(VideoExportSize size) {
    if (!videoSizeAvailable(_session.project, size)) return;
    _set(_session.copyWith(videoSize: size));
    unawaited(ref.read(appSettingsProvider).saveVideoExportSize(size.name));
  }

  /// Exports with the current options. With [thenShare] the done screen
  /// opens the share sheet right away.
  Future<void> start({bool thenShare = false}) async {
    final session = _session;
    if (session.phase is ExportRunning) return;
    final project = session.project;
    final pixels = session.isVideo ? session.videoPixels() : session.pixels();

    final needed = session.isVideo
        ? requiredVideoBytes(
            videoBitrate: session.videoBitrateBps,
            durationMs: session.videoDurationMs,
            includeAudio: session.includesAudio,
          )
        : requiredBytes(pixels, session.options.format);
    final free = await _engine.availableBytes();
    if (free < needed) {
      _set(
        session.copyWith(
          phase: ExportFailed(
            MediaEngineError.storageFull,
            missingBytes: needed - free,
          ),
        ),
      );
      return;
    }

    if (session.isVideo) await _askForNotifications();
    final jobId = const Uuid().v4();
    _startedAt = DateTime.now();
    _set(
      session.copyWith(
        phase: ExportRunning(jobId: jobId, fraction: 0, thenShare: thenShare),
      ),
    );
    final rasterizer = ref.read(elementLayerRasterizerProvider);
    unawaited(_progress?.cancel());
    _progress = _engine.exportProgress
        .where((p) => p.jobId == jobId)
        .listen((p) => _onProgress(jobId, p.fraction, thenShare));

    try {
      final layers = await rasterizer.rasterize(
        jobId: jobId,
        elements: project.edit.elements,
        output: pixels,
      );
      final result = session.isVideo
          ? await _exportVideo(jobId, session, pixels, layers)
          : await _engine.exportPhoto(jobId, (
              uri: project.media.uri,
              params: RenderParams.fromEdit(
                project.edit,
                session.preset,
                mediaRatio: project.media.aspectRatio,
              ),
              format: session.options.format,
              outputWidth: pixels.width,
              outputHeight: pixels.height,
              decodeMaxPx: CropGeometry.decodeLongSide(
                project.edit.crop,
                project.media,
                outputWidth: pixels.width,
              ),
              keepMetadata: session.options.keepMetadata,
              fileName: project.name ?? 'Auvie',
              layers: layers,
            ));
      _set(_session.copyWith(phase: ExportDone(result, thenShare: thenShare)));
    } on MediaEngineException catch (e) {
      _set(
        _session.copyWith(
          phase: e.error == MediaEngineError.cancelled
              ? const ExportIdle()
              : ExportFailed(e.error, missingBytes: e.missingBytes),
        ),
      );
    } finally {
      // Not awaited: a cancelled subscription needs nothing more from us.
      unawaited(_progress?.cancel());
      _progress = null;
      unawaited(rasterizer.clean(jobId));
    }
  }

  Future<ExportResult> _exportVideo(
    String jobId,
    ExportSession session,
    ({int width, int height}) pixels,
    List<ExportLayerSpec> layers,
  ) {
    final project = session.project;
    final timeline = project.edit.video ?? const VideoTimeline();
    return _engine.exportVideo(jobId, (
      uri: project.media.uri,
      params: RenderParams.fromEdit(
        project.edit,
        session.preset,
        mediaRatio: project.media.aspectRatio,
      ),
      outputWidth: pixels.width,
      outputHeight: pixels.height,
      trimStartMs: timeline.trimStartMs,
      trimEndMs: timeline.endMs(project.media.durationMs ?? 0),
      includeAudio: session.includesAudio,
      videoBitrate: session.videoBitrateBps,
      fileName: project.name ?? 'Auvie',
      layers: layers,
    ));
  }

  /// The first video export asks once to show its progress notification
  /// (decision M6); a refusal doesn't stop the export.
  Future<void> _askForNotifications() async {
    final settings = ref.read(appSettingsProvider);
    if (settings.notificationsAsked) return;
    await settings.markNotificationsAsked();
    try {
      await _engine.requestNotificationPermission();
    } on MediaEngineException catch (e) {
      debugPrint('Notification permission: $e');
    }
  }

  void _onProgress(String jobId, double fraction, bool thenShare) {
    final phase = state.value?.phase;
    if (phase is! ExportRunning || phase.jobId != jobId) return;
    int? eta;
    final started = _startedAt;
    if (started != null && fraction >= _etaFrom && fraction < 1) {
      final elapsed = DateTime.now().difference(started).inMilliseconds;
      eta = (elapsed / fraction * (1 - fraction) / 1000).ceil();
    }
    _set(
      _session.copyWith(
        phase: ExportRunning(
          jobId: jobId,
          fraction: fraction.clamp(0, 1),
          etaSeconds: eta,
          thenShare: thenShare,
        ),
      ),
    );
  }

  Future<void> cancel() async {
    final phase = _session.phase;
    if (phase is ExportRunning) await _engine.cancelExport(phase.jobId);
  }

  /// Back to the options (after done, or dismissing an error).
  void reset() => _set(_session.copyWith(phase: const ExportIdle()));

  /// S5's primary action: the next smaller size, then export again.
  Future<void> retrySmaller() async {
    if (_session.isVideo) {
      final smaller = _session.videoSize.smaller;
      if (smaller != null) setVideoSize(smaller);
      return await start();
    }
    final smaller = _session.options.size.smaller;
    if (smaller == null) return await start();
    setOptions((
      format: _session.options.format,
      size: smaller,
      keepMetadata: _session.options.keepMetadata,
    ));
    await start();
  }
}

Duration? _noRetry(int retryCount, Object error) => null;
