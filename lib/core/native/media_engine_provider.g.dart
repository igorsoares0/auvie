// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_engine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mediaEngine)
final mediaEngineProvider = MediaEngineProvider._();

final class MediaEngineProvider
    extends $FunctionalProvider<MediaEngine, MediaEngine, MediaEngine>
    with $Provider<MediaEngine> {
  MediaEngineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaEngineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaEngineHash();

  @$internal
  @override
  $ProviderElement<MediaEngine> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaEngine create(Ref ref) {
    return mediaEngine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaEngine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaEngine>(value),
    );
  }
}

String _$mediaEngineHash() => r'bfee89ba40b5d927f19a2db8dca9623015c431df';
