// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catalogSource)
final catalogSourceProvider = CatalogSourceProvider._();

final class CatalogSourceProvider
    extends $FunctionalProvider<CatalogSource, CatalogSource, CatalogSource>
    with $Provider<CatalogSource> {
  CatalogSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogSourceHash();

  @$internal
  @override
  $ProviderElement<CatalogSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CatalogSource create(Ref ref) {
    return catalogSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogSource>(value),
    );
  }
}

String _$catalogSourceHash() => r'7366ece4faf0edc93e1db9c55de4c447a3207162';

@ProviderFor(catalog)
final catalogProvider = CatalogProvider._();

final class CatalogProvider
    extends $FunctionalProvider<AsyncValue<Catalog>, Catalog, FutureOr<Catalog>>
    with $FutureModifier<Catalog>, $FutureProvider<Catalog> {
  CatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogHash();

  @$internal
  @override
  $FutureProviderElement<Catalog> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Catalog> create(Ref ref) {
    return catalog(ref);
  }
}

String _$catalogHash() => r'70f6a306a97683e224b56d5eeab17f932401fefc';
