// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'element_layers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(elementLayerRasterizer)
final elementLayerRasterizerProvider = ElementLayerRasterizerProvider._();

final class ElementLayerRasterizerProvider
    extends
        $FunctionalProvider<
          ElementLayerRasterizer,
          ElementLayerRasterizer,
          ElementLayerRasterizer
        >
    with $Provider<ElementLayerRasterizer> {
  ElementLayerRasterizerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'elementLayerRasterizerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$elementLayerRasterizerHash();

  @$internal
  @override
  $ProviderElement<ElementLayerRasterizer> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ElementLayerRasterizer create(Ref ref) {
    return elementLayerRasterizer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ElementLayerRasterizer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ElementLayerRasterizer>(value),
    );
  }
}

String _$elementLayerRasterizerHash() =>
    r'cb624957380f2c7cf49fd872136cc5afce79a0ab';
