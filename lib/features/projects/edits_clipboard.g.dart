// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edits_clipboard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Copy edits" / "Paste edits" (spec §29): the film, its intensity, the
/// adjustments, curves and color mix of one edit, ready for others. Kept
/// in the preferences, so a look copied yesterday can still be pasted.

@ProviderFor(EditsClipboard)
final editsClipboardProvider = EditsClipboardProvider._();

/// "Copy edits" / "Paste edits" (spec §29): the film, its intensity, the
/// adjustments, curves and color mix of one edit, ready for others. Kept
/// in the preferences, so a look copied yesterday can still be pasted.
final class EditsClipboardProvider
    extends $NotifierProvider<EditsClipboard, CopiedEdits?> {
  /// "Copy edits" / "Paste edits" (spec §29): the film, its intensity, the
  /// adjustments, curves and color mix of one edit, ready for others. Kept
  /// in the preferences, so a look copied yesterday can still be pasted.
  EditsClipboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editsClipboardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editsClipboardHash();

  @$internal
  @override
  EditsClipboard create() => EditsClipboard();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CopiedEdits? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CopiedEdits?>(value),
    );
  }
}

String _$editsClipboardHash() => r'4e326e23e5c34bcfe86c233f973bf7773cd4864b';

/// "Copy edits" / "Paste edits" (spec §29): the film, its intensity, the
/// adjustments, curves and color mix of one edit, ready for others. Kept
/// in the preferences, so a look copied yesterday can still be pasted.

abstract class _$EditsClipboard extends $Notifier<CopiedEdits?> {
  CopiedEdits? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CopiedEdits?, CopiedEdits?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CopiedEdits?, CopiedEdits?>,
              CopiedEdits?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
