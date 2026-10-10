// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Makes ids for new elements (overridable so tests are deterministic:
/// brush and overlay textures are seeded by the id).

@ProviderFor(elementIds)
final elementIdsProvider = ElementIdsProvider._();

/// Makes ids for new elements (overridable so tests are deterministic:
/// brush and overlay textures are seeded by the id).

final class ElementIdsProvider
    extends
        $FunctionalProvider<
          String Function(),
          String Function(),
          String Function()
        >
    with $Provider<String Function()> {
  /// Makes ids for new elements (overridable so tests are deterministic:
  /// brush and overlay textures are seeded by the id).
  ElementIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'elementIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$elementIdsHash();

  @$internal
  @override
  $ProviderElement<String Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  String Function() create(Ref ref) {
    return elementIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String Function()>(value),
    );
  }
}

String _$elementIdsHash() => r'990f63c670504e986dde2e5f113d01fab7b3bc31';

/// State and actions of the photo and video editors for one project.
/// Edits autosave [saveDelay] after the last change (spec: errors never
/// discard an edit).

@ProviderFor(EditorController)
final editorControllerProvider = EditorControllerFamily._();

/// State and actions of the photo and video editors for one project.
/// Edits autosave [saveDelay] after the last change (spec: errors never
/// discard an edit).
final class EditorControllerProvider
    extends $AsyncNotifierProvider<EditorController, EditorSession> {
  /// State and actions of the photo and video editors for one project.
  /// Edits autosave [saveDelay] after the last change (spec: errors never
  /// discard an edit).
  EditorControllerProvider._({
    required EditorControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'editorControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editorControllerHash();

  @override
  String toString() {
    return r'editorControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditorController create() => EditorController();

  @override
  bool operator ==(Object other) {
    return other is EditorControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editorControllerHash() => r'cc26dc0edb6252aa481ef975f62f9619805c5d82';

/// State and actions of the photo and video editors for one project.
/// Edits autosave [saveDelay] after the last change (spec: errors never
/// discard an edit).

final class EditorControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          EditorController,
          AsyncValue<EditorSession>,
          EditorSession,
          FutureOr<EditorSession>,
          String
        > {
  EditorControllerFamily._()
    : super(
        retry: _noRetry,
        name: r'editorControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// State and actions of the photo and video editors for one project.
  /// Edits autosave [saveDelay] after the last change (spec: errors never
  /// discard an edit).

  EditorControllerProvider call(String projectId) =>
      EditorControllerProvider._(argument: projectId, from: this);

  @override
  String toString() => r'editorControllerProvider';
}

/// State and actions of the photo and video editors for one project.
/// Edits autosave [saveDelay] after the last change (spec: errors never
/// discard an edit).

abstract class _$EditorController extends $AsyncNotifier<EditorSession> {
  late final _$args = ref.$arg as String;
  String get projectId => _$args;

  FutureOr<EditorSession> build(String projectId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EditorSession>, EditorSession>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EditorSession>, EditorSession>,
              AsyncValue<EditorSession>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
