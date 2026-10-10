// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_playback.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Play, pause and seek for the video editor of one project. The preview
/// attaches its texture when it opens.

@ProviderFor(VideoPlayback)
final videoPlaybackProvider = VideoPlaybackFamily._();

/// Play, pause and seek for the video editor of one project. The preview
/// attaches its texture when it opens.
final class VideoPlaybackProvider
    extends $NotifierProvider<VideoPlayback, PlaybackView> {
  /// Play, pause and seek for the video editor of one project. The preview
  /// attaches its texture when it opens.
  VideoPlaybackProvider._({
    required VideoPlaybackFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'videoPlaybackProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$videoPlaybackHash();

  @override
  String toString() {
    return r'videoPlaybackProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VideoPlayback create() => VideoPlayback();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackView value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackView>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VideoPlaybackProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$videoPlaybackHash() => r'05c6506bd843a4f78c2062cf71e4ac492d7e7ed4';

/// Play, pause and seek for the video editor of one project. The preview
/// attaches its texture when it opens.

final class VideoPlaybackFamily extends $Family
    with
        $ClassFamilyOverride<
          VideoPlayback,
          PlaybackView,
          PlaybackView,
          PlaybackView,
          String
        > {
  VideoPlaybackFamily._()
    : super(
        retry: null,
        name: r'videoPlaybackProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Play, pause and seek for the video editor of one project. The preview
  /// attaches its texture when it opens.

  VideoPlaybackProvider call(String projectId) =>
      VideoPlaybackProvider._(argument: projectId, from: this);

  @override
  String toString() => r'videoPlaybackProvider';
}

/// Play, pause and seek for the video editor of one project. The preview
/// attaches its texture when it opens.

abstract class _$VideoPlayback extends $Notifier<PlaybackView> {
  late final _$args = ref.$arg as String;
  String get projectId => _$args;

  PlaybackView build(String projectId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PlaybackView, PlaybackView>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PlaybackView, PlaybackView>,
              PlaybackView,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
