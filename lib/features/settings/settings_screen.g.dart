// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "1.0.0 (1)".

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// "1.0.0 (1)".

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// "1.0.0 (1)".
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'appVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'e14de43bf165d0726caeffc09404ab7988dd8e42';

/// Bytes Settings → STORAGE can free.

@ProviderFor(cacheSize)
final cacheSizeProvider = CacheSizeProvider._();

/// Bytes Settings → STORAGE can free.

final class CacheSizeProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Bytes Settings → STORAGE can free.
  CacheSizeProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'cacheSizeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheSizeHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return cacheSize(ref);
  }
}

String _$cacheSizeHash() => r'e3992a9e1edfa8502c4f00eb28523a79bc2473d0';
