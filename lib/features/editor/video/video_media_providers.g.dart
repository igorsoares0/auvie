// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_media_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Frames of the FILM strip, spread evenly over the whole clip.

@ProviderFor(filmFrames)
final filmFramesProvider = FilmFramesFamily._();

/// Frames of the FILM strip, spread evenly over the whole clip.

final class FilmFramesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Uint8List>>,
          List<Uint8List>,
          FutureOr<List<Uint8List>>
        >
    with $FutureModifier<List<Uint8List>>, $FutureProvider<List<Uint8List>> {
  /// Frames of the FILM strip, spread evenly over the whole clip.
  FilmFramesProvider._({
    required FilmFramesFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: _noRetry,
         name: r'filmFramesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filmFramesHash();

  @override
  String toString() {
    return r'filmFramesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Uint8List>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Uint8List>> create(Ref ref) {
    final argument = this.argument as (String, int);
    return filmFrames(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is FilmFramesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filmFramesHash() => r'fc92c8059c69e14a46bbb7e9c37d82eeb4f4184f';

/// Frames of the FILM strip, spread evenly over the whole clip.

final class FilmFramesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Uint8List>>, (String, int)> {
  FilmFramesFamily._()
    : super(
        retry: _noRetry,
        name: r'filmFramesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Frames of the FILM strip, spread evenly over the whole clip.

  FilmFramesProvider call(String uri, int count) =>
      FilmFramesProvider._(argument: (uri, count), from: this);

  @override
  String toString() => r'filmFramesProvider';
}

/// The SOUND lane's waveform; null when the video has no sound.

@ProviderFor(soundWave)
final soundWaveProvider = SoundWaveFamily._();

/// The SOUND lane's waveform; null when the video has no sound.

final class SoundWaveProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<double>?>,
          List<double>?,
          FutureOr<List<double>?>
        >
    with $FutureModifier<List<double>?>, $FutureProvider<List<double>?> {
  /// The SOUND lane's waveform; null when the video has no sound.
  SoundWaveProvider._({
    required SoundWaveFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'soundWaveProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$soundWaveHash();

  @override
  String toString() {
    return r'soundWaveProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<double>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<double>?> create(Ref ref) {
    final argument = this.argument as String;
    return soundWave(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SoundWaveProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$soundWaveHash() => r'6f561ce0368a29b43a57e243e7740cb8b314d220';

/// The SOUND lane's waveform; null when the video has no sound.

final class SoundWaveFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<double>?>, String> {
  SoundWaveFamily._()
    : super(
        retry: _noRetry,
        name: r'soundWaveProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The SOUND lane's waveform; null when the video has no sound.

  SoundWaveProvider call(String uri) =>
      SoundWaveProvider._(argument: uri, from: this);

  @override
  String toString() => r'soundWaveProvider';
}
