// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The edited, cropped photo (or video's first kept frame) shown on the
/// Export screens.

@ProviderFor(exportPreview)
final exportPreviewProvider = ExportPreviewFamily._();

/// The edited, cropped photo (or video's first kept frame) shown on the
/// Export screens.

final class ExportPreviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List>,
          Uint8List,
          FutureOr<Uint8List>
        >
    with $FutureModifier<Uint8List>, $FutureProvider<Uint8List> {
  /// The edited, cropped photo (or video's first kept frame) shown on the
  /// Export screens.
  ExportPreviewProvider._({
    required ExportPreviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'exportPreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exportPreviewHash();

  @override
  String toString() {
    return r'exportPreviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List> create(Ref ref) {
    final argument = this.argument as String;
    return exportPreview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExportPreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exportPreviewHash() => r'71b7f9c64b32d7e5c7c96a114108e3201a30cd75';

/// The edited, cropped photo (or video's first kept frame) shown on the
/// Export screens.

final class ExportPreviewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List>, String> {
  ExportPreviewFamily._()
    : super(
        retry: null,
        name: r'exportPreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The edited, cropped photo (or video's first kept frame) shown on the
  /// Export screens.

  ExportPreviewProvider call(String projectId) =>
      ExportPreviewProvider._(argument: projectId, from: this);

  @override
  String toString() => r'exportPreviewProvider';
}
