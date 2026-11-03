// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's photo, or the video's frame at [timeMs], developed with
/// [presetId] at full intensity (null: the original). Kept while a card
/// shows it.

@ProviderFor(presetThumbnail)
final presetThumbnailProvider = PresetThumbnailFamily._();

/// The user's photo, or the video's frame at [timeMs], developed with
/// [presetId] at full intensity (null: the original). Kept while a card
/// shows it.

final class PresetThumbnailProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List>,
          Uint8List,
          FutureOr<Uint8List>
        >
    with $FutureModifier<Uint8List>, $FutureProvider<Uint8List> {
  /// The user's photo, or the video's frame at [timeMs], developed with
  /// [presetId] at full intensity (null: the original). Kept while a card
  /// shows it.
  PresetThumbnailProvider._({
    required PresetThumbnailFamily super.from,
    required (String, String?, {int? timeMs}) super.argument,
  }) : super(
         retry: null,
         name: r'presetThumbnailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$presetThumbnailHash();

  @override
  String toString() {
    return r'presetThumbnailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List> create(Ref ref) {
    final argument = this.argument as (String, String?, {int? timeMs});
    return presetThumbnail(
      ref,
      argument.$1,
      argument.$2,
      timeMs: argument.timeMs,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PresetThumbnailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$presetThumbnailHash() => r'15bf148a1659049236e25f316e655cb0812f7f74';

/// The user's photo, or the video's frame at [timeMs], developed with
/// [presetId] at full intensity (null: the original). Kept while a card
/// shows it.

final class PresetThumbnailFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Uint8List>,
          (String, String?, {int? timeMs})
        > {
  PresetThumbnailFamily._()
    : super(
        retry: null,
        name: r'presetThumbnailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The user's photo, or the video's frame at [timeMs], developed with
  /// [presetId] at full intensity (null: the original). Kept while a card
  /// shows it.

  PresetThumbnailProvider call(String uri, String? presetId, {int? timeMs}) =>
      PresetThumbnailProvider._(
        argument: (uri, presetId, timeMs: timeMs),
        from: this,
      );

  @override
  String toString() => r'presetThumbnailProvider';
}

/// Preset ids saved as favorites (FILM → SAVED), newest first.

@ProviderFor(favoritePresets)
final favoritePresetsProvider = FavoritePresetsProvider._();

/// Preset ids saved as favorites (FILM → SAVED), newest first.

final class FavoritePresetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// Preset ids saved as favorites (FILM → SAVED), newest first.
  FavoritePresetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritePresetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritePresetsHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return favoritePresets(ref);
  }
}

String _$favoritePresetsHash() => r'6f85164be9d6b477983c54bf7a9a36a6da44f167';

/// Favorite collections (Archive SAVE), newest first.

@ProviderFor(favoriteCollections)
final favoriteCollectionsProvider = FavoriteCollectionsProvider._();

/// Favorite collections (Archive SAVE), newest first.

final class FavoriteCollectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// Favorite collections (Archive SAVE), newest first.
  FavoriteCollectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteCollectionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteCollectionsHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return favoriteCollections(ref);
  }
}

String _$favoriteCollectionsHash() =>
    r'604ae76dc0524543799c38a5b1a1c58013ec7ba7';

/// Favorite stickers (hold one in ADD), newest first.

@ProviderFor(favoriteStickers)
final favoriteStickersProvider = FavoriteStickersProvider._();

/// Favorite stickers (hold one in ADD), newest first.

final class FavoriteStickersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  /// Favorite stickers (hold one in ADD), newest first.
  FavoriteStickersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteStickersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteStickersHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return favoriteStickers(ref);
  }
}

String _$favoriteStickersHash() => r'52e92926b88eade60003596afcea63f8f76389dc';
