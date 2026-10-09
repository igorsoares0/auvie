// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'element_assets_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(elementAssets)
final elementAssetsProvider = ElementAssetsProvider._();

final class ElementAssetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ElementAssets>,
          ElementAssets,
          FutureOr<ElementAssets>
        >
    with $FutureModifier<ElementAssets>, $FutureProvider<ElementAssets> {
  ElementAssetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'elementAssetsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$elementAssetsHash();

  @$internal
  @override
  $FutureProviderElement<ElementAssets> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ElementAssets> create(Ref ref) {
    return elementAssets(ref);
  }
}

String _$elementAssetsHash() => r'8909e66aeb0f83d64628c962e149bc3afd4ed0ca';
