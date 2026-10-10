import 'dart:async';

import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'video_playback.g.dart';

/// Where the video editor's player is. Kept out of the edit history: it
/// changes 30 times a second while playing.
@immutable
class PlaybackView {
  const new({
    this.textureId,
    this.positionMs = 0,
    this.playing = false,
    this.durationMs = 0,
    this.hasAudio = true,
  });

  /// Null until the preview is open.
  final int? textureId;
  final int positionMs;
  final bool playing;
  final int durationMs;
  final bool hasAudio;

  PlaybackView copyWith({
    int? textureId,
    int? positionMs,
    bool? playing,
    int? durationMs,
    bool? hasAudio,
  }) => PlaybackView(
    textureId: textureId ?? this.textureId,
    positionMs: positionMs ?? this.positionMs,
    playing: playing ?? this.playing,
    durationMs: durationMs ?? this.durationMs,
    hasAudio: hasAudio ?? this.hasAudio,
  );

  @override
  bool operator ==(Object other) =>
      other is PlaybackView &&
      other.textureId == textureId &&
      other.positionMs == positionMs &&
      other.playing == playing &&
      other.durationMs == durationMs &&
      other.hasAudio == hasAudio;

  @override
  int get hashCode =>
      Object.hash(textureId, positionMs, playing, durationMs, hasAudio);
}

/// Play, pause and seek for the video editor of one project. The preview
/// attaches its texture when it opens.
@riverpod
class VideoPlayback extends _$VideoPlayback {
  StreamSubscription<PlaybackState>? _events;

  @override
  PlaybackView build(String projectId) {
    ref.onDispose(() => unawaited(_events?.cancel()));
    return const PlaybackView();
  }

  MediaEngine get _engine => ref.read(mediaEngineProvider);

  /// Called by the preview once the engine opened the video.
  void attach(VideoPreview preview) {
    unawaited(_events?.cancel());
    final id = preview.textureId;
    state = PlaybackView(
      textureId: id,
      durationMs: preview.durationMs,
      hasAudio: preview.hasAudio,
    );
    _events = _engine.playbackStates
        .where((e) => e.textureId == id)
        .listen(
          (e) => state = state.copyWith(
            positionMs: e.positionMs,
            playing: e.playing,
          ),
        );
  }

  /// Called by the preview when it goes away (from dispose, so it must
  /// not change the state).
  void detach(int textureId) {
    if (!ref.mounted || state.textureId != textureId) return;
    unawaited(_events?.cancel());
    _events = null;
  }

  void play() {
    final id = state.textureId;
    if (id == null) return;
    state = state.copyWith(playing: true);
    unawaited(_engine.playVideo(id));
  }

  void pause() {
    final id = state.textureId;
    if (id == null || !state.playing) return;
    state = state.copyWith(playing: false);
    unawaited(_engine.pauseVideo(id));
  }

  void toggle() => state.playing ? pause() : play();

  /// Moves the playhead. While scrubbing pass `exact: false` (key frames,
  /// fast) and finish with an exact seek.
  void seek(int positionMs, {bool exact = true}) {
    final id = state.textureId;
    final ms = positionMs.clamp(0, state.durationMs);
    state = state.copyWith(positionMs: ms);
    if (id != null) unawaited(_engine.seekVideo(id, ms, exact: exact));
  }
}
