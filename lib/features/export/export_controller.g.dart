// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Export screen for one project (spec §34–35, handoff 07 / S3–S5).

@ProviderFor(ExportController)
final exportControllerProvider = ExportControllerFamily._();

/// The Export screen for one project (spec §34–35, handoff 07 / S3–S5).
final class ExportControllerProvider
    extends $AsyncNotifierProvider<ExportController, ExportSession> {
  /// The Export screen for one project (spec §34–35, handoff 07 / S3–S5).
  ExportControllerProvider._({
    required ExportControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'exportControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exportControllerHash();

  @override
  String toString() {
    return r'exportControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ExportController create() => ExportController();

  @override
  bool operator ==(Object other) {
    return other is ExportControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exportControllerHash() => r'0633f031d3aba2982d7891f051baaf468d0c212e';

/// The Export screen for one project (spec §34–35, handoff 07 / S3–S5).

final class ExportControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ExportController,
          AsyncValue<ExportSession>,
          ExportSession,
          FutureOr<ExportSession>,
          String
        > {
  ExportControllerFamily._()
    : super(
        retry: _noRetry,
        name: r'exportControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The Export screen for one project (spec §34–35, handoff 07 / S3–S5).

  ExportControllerProvider call(String projectId) =>
      ExportControllerProvider._(argument: projectId, from: this);

  @override
  String toString() => r'exportControllerProvider';
}

/// The Export screen for one project (spec §34–35, handoff 07 / S3–S5).

abstract class _$ExportController extends $AsyncNotifier<ExportSession> {
  late final _$args = ref.$arg as String;
  String get projectId => _$args;

  FutureOr<ExportSession> build(String projectId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ExportSession>, ExportSession>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExportSession>, ExportSession>,
              AsyncValue<ExportSession>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
