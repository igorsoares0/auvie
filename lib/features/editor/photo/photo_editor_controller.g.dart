// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_editor_controller.dart';

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

/// State and actions of the photo editor for one project. Edits autosave
/// [saveDelay] after the last change (spec: errors never discard an edit).

@ProviderFor(PhotoEditor)
final photoEditorProvider = PhotoEditorFamily._();

/// State and actions of the photo editor for one project. Edits autosave
/// [saveDelay] after the last change (spec: errors never discard an edit).
final class PhotoEditorProvider
    extends $AsyncNotifierProvider<PhotoEditor, EditorSession> {
  /// State and actions of the photo editor for one project. Edits autosave
  /// [saveDelay] after the last change (spec: errors never discard an edit).
  PhotoEditorProvider._({
    required PhotoEditorFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'photoEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$photoEditorHash();

  @override
  String toString() {
    return r'photoEditorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PhotoEditor create() => PhotoEditor();

  @override
  bool operator ==(Object other) {
    return other is PhotoEditorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$photoEditorHash() => r'bee2581303ced7dd92ada57d94e851a54ea2c97a';

/// State and actions of the photo editor for one project. Edits autosave
/// [saveDelay] after the last change (spec: errors never discard an edit).

final class PhotoEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          PhotoEditor,
          AsyncValue<EditorSession>,
          EditorSession,
          FutureOr<EditorSession>,
          String
        > {
  PhotoEditorFamily._()
    : super(
        retry: _noRetry,
        name: r'photoEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// State and actions of the photo editor for one project. Edits autosave
  /// [saveDelay] after the last change (spec: errors never discard an edit).

  PhotoEditorProvider call(String projectId) =>
      PhotoEditorProvider._(argument: projectId, from: this);

  @override
  String toString() => r'photoEditorProvider';
}

/// State and actions of the photo editor for one project. Edits autosave
/// [saveDelay] after the last change (spec: errors never discard an edit).

abstract class _$PhotoEditor extends $AsyncNotifier<EditorSession> {
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
