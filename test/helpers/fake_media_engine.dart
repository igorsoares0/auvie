import 'dart:async';
import 'dart:typed_data';

import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/native/render_params.dart';
import 'package:collection/collection.dart';

/// A valid 1×1 PNG, so widgets decoding the engine's images don't fail.
final onePixelPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, //
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0, //
  0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00, //
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

/// In-memory [MediaEngine] that records what the UI asked for.
class FakeMediaEngine implements MediaEngine {
  new({
    this.picked,
    this.previewSize = (width: 400, height: 300),
    this.videoDurationMs = 10000,
    this.videoHasAudio = true,
  });

  /// What [pickMedia] returns (null = the user cancelled).
  MediaRef? picked;
  ({int width, int height}) previewSize;

  final calls = <String>[];
  final updates = <(int, RenderParams)>[];
  final showOriginal = <bool>[];
  final disposed = <int>[];
  final renders = <RenderParams>[];
  final resized = <(int, int, int)>[];
  final exports = <ExportJob>[];
  final videoExports = <VideoExportJob>[];

  /// Player calls: play, pause, seek(ms, exact), range(start, end), muted(b).
  final player = <String>[];
  int videoDurationMs;
  bool videoHasAudio;

  /// What [requestNotificationPermission] answers; counts the requests.
  bool notificationsAllowed = true;
  int notificationRequests = 0;
  final cancelled = <String>[];
  final copied = <String>[];

  /// What [availableBytes] reports.
  int freeBytes = 1 << 40;

  /// When set, [exportPhoto] waits for it (to observe the running state).
  Completer<void>? exportGate;

  /// When set, [exportPhoto] fails with it.
  MediaEngineException? exportError;

  final _progress = StreamController<ExportProgress>.broadcast();
  final _playback = StreamController<PlaybackState>.broadcast();

  /// Sends a playback event (as the player does while playing).
  void emitPlayback(int textureId, int positionMs, {bool playing = false}) =>
      _playback.add((
        textureId: textureId,
        positionMs: positionMs,
        playing: playing,
      ));
  final _running = <String, Completer<void>>{};

  /// Sends a progress event for [jobId].
  void emitProgress(String jobId, double fraction, [String stage = 'render']) =>
      _progress.add((jobId: jobId, fraction: fraction, stage: stage));

  String? get runningJob => _running.keys.lastOrNull;
  var _nextTexture = 1;

  @override
  Future<MediaRef?> pickMedia(MediaType type) async {
    calls.add('pickMedia(${type.name})');
    return picked;
  }

  @override
  Future<MediaRef> probe(String uri) async {
    calls.add('probe($uri)');
    return picked!;
  }

  @override
  Future<Uint8List> thumbnail(String uri, {required int maxPx}) async {
    calls.add('thumbnail($uri, $maxPx)');
    return onePixelPng;
  }

  @override
  Future<PhotoPreview> createPhotoPreview(
    String uri, {
    required int maxPx,
  }) async {
    calls.add('createPhotoPreview($uri, $maxPx)');
    return (
      textureId: _nextTexture++,
      width: previewSize.width,
      height: previewSize.height,
    );
  }

  @override
  Future<void> updateEdit(int textureId, RenderParams params) async {
    updates.add((textureId, params));
  }

  @override
  Future<void> setShowOriginal(int textureId, {required bool original}) async {
    showOriginal.add(original);
  }

  @override
  Future<void> disposePreview(int textureId) async {
    disposed.add(textureId);
  }

  @override
  Future<Uint8List> renderPhoto(
    String uri,
    RenderParams params, {
    required int maxPx,
  }) async {
    calls.add('renderPhoto($uri, $maxPx)');
    renders.add(params);
    return onePixelPng;
  }

  @override
  Future<Uint8List> renderVideoFrame(
    String uri,
    RenderParams params, {
    required int maxPx,
    required int timeMs,
  }) async {
    calls.add('renderVideoFrame($uri, $maxPx, $timeMs)');
    renders.add(params);
    return onePixelPng;
  }

  @override
  Future<VideoPreview> createVideoPreview(
    String uri, {
    required int maxPx,
  }) async {
    calls.add('createVideoPreview($uri, $maxPx)');
    return (
      textureId: _nextTexture++,
      width: previewSize.width,
      height: previewSize.height,
      durationMs: videoDurationMs,
      hasAudio: videoHasAudio,
    );
  }

  @override
  Future<void> playVideo(int textureId) async => player.add('play');

  @override
  Future<void> pauseVideo(int textureId) async => player.add('pause');

  @override
  Future<void> seekVideo(
    int textureId,
    int positionMs, {
    bool exact = true,
  }) async => player.add('seek($positionMs, $exact)');

  @override
  Future<void> setPlaybackRange(
    int textureId, {
    required int startMs,
    required int endMs,
  }) async => player.add('range($startMs, $endMs)');

  @override
  Future<void> setVideoMuted(int textureId, {required bool muted}) async =>
      player.add('muted($muted)');

  @override
  Stream<PlaybackState> get playbackStates => _playback.stream;

  @override
  Future<List<Uint8List>> videoFrames(
    String uri, {
    required int count,
    required int maxPx,
  }) async {
    calls.add('videoFrames($uri, $count)');
    return List.filled(count, onePixelPng);
  }

  @override
  Future<List<double>?> waveform(String uri, {required int buckets}) async {
    calls.add('waveform($uri, $buckets)');
    if (!videoHasAudio) return null;
    return [for (var i = 0; i < buckets; i++) (i % 7) / 6];
  }

  @override
  Future<void> resizePreview(
    int textureId, {
    required int width,
    required int height,
  }) async {
    resized.add((textureId, width, height));
  }

  @override
  Future<int> availableBytes() async => freeBytes;

  @override
  Future<ExportResult> exportPhoto(String jobId, ExportJob job) async {
    exports.add(job);
    return await _export(
      jobId,
      filePath: '/files/exports/${job.fileName}.jpg',
      width: job.outputWidth,
      height: job.outputHeight,
    );
  }

  @override
  Future<ExportResult> exportVideo(String jobId, VideoExportJob job) async {
    videoExports.add(job);
    return await _export(
      jobId,
      filePath: '/files/exports/${job.fileName}.mp4',
      width: job.outputWidth,
      height: job.outputHeight,
      durationMs: job.trimEndMs - job.trimStartMs,
    );
  }

  @override
  Future<bool> requestNotificationPermission() async {
    notificationRequests++;
    return notificationsAllowed;
  }

  Future<ExportResult> _export(
    String jobId, {
    required String filePath,
    required int width,
    required int height,
    int? durationMs,
  }) async {
    final done = Completer<void>();
    _running[jobId] = done;
    try {
      final gate = exportGate;
      if (gate != null) {
        await Future.any([gate.future, done.future]);
      }
      if (cancelled.contains(jobId)) {
        throw const MediaEngineException(MediaEngineError.cancelled);
      }
      final error = exportError;
      if (error != null) throw error;
      emitProgress(jobId, 1, 'save');
      return (
        mediaUri: durationMs == null
            ? 'content://media/external/images/media/1'
            : 'content://media/external/video/media/1',
        filePath: filePath,
        width: width,
        height: height,
        bytes: 4800000,
        durationMs: durationMs,
      );
    } finally {
      _running.remove(jobId);
    }
  }

  @override
  Future<void> cancelExport(String jobId) async {
    cancelled.add(jobId);
    final running = _running[jobId];
    if (running != null && !running.isCompleted) running.complete();
  }

  @override
  Stream<ExportProgress> get exportProgress => _progress.stream;

  @override
  Future<void> copyToClipboard(String mediaUri) async {
    copied.add(mediaUri);
  }
}
