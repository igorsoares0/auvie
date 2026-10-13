// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The store: RevenueCat when a key is set; otherwise the simulated store in
/// debug and profile builds, and "not available" in release.

@ProviderFor(entitlementService)
final entitlementServiceProvider = EntitlementServiceProvider._();

/// The store: RevenueCat when a key is set; otherwise the simulated store in
/// debug and profile builds, and "not available" in release.

final class EntitlementServiceProvider
    extends
        $FunctionalProvider<
          EntitlementService,
          EntitlementService,
          EntitlementService
        >
    with $Provider<EntitlementService> {
  /// The store: RevenueCat when a key is set; otherwise the simulated store in
  /// debug and profile builds, and "not available" in release.
  EntitlementServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entitlementServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entitlementServiceHash();

  @$internal
  @override
  $ProviderElement<EntitlementService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EntitlementService create(Ref ref) {
    return entitlementService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntitlementService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntitlementService>(value),
    );
  }
}

String _$entitlementServiceHash() =>
    r'9eefe96e41b4ea275e7a47c41eb19d37da253484';

/// Whether the user has Pro, updated on every purchase or expiration.

@ProviderFor(ProAccess)
final proAccessProvider = ProAccessProvider._();

/// Whether the user has Pro, updated on every purchase or expiration.
final class ProAccessProvider
    extends $NotifierProvider<ProAccess, Entitlement> {
  /// Whether the user has Pro, updated on every purchase or expiration.
  ProAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proAccessProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proAccessHash();

  @$internal
  @override
  ProAccess create() => ProAccess();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Entitlement value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Entitlement>(value),
    );
  }
}

String _$proAccessHash() => r'0f965e4b50287fe116f8bf9cb7b241f4a45669d2';

/// Whether the user has Pro, updated on every purchase or expiration.

abstract class _$ProAccess extends $Notifier<Entitlement> {
  Entitlement build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Entitlement, Entitlement>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Entitlement, Entitlement>,
              Entitlement,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
