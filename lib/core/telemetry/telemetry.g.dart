// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(telemetry)
final telemetryProvider = TelemetryProvider._();

final class TelemetryProvider
    extends $FunctionalProvider<Telemetry, Telemetry, Telemetry>
    with $Provider<Telemetry> {
  TelemetryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'telemetryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$telemetryHash();

  @$internal
  @override
  $ProviderElement<Telemetry> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Telemetry create(Ref ref) {
    return telemetry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Telemetry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Telemetry>(value),
    );
  }
}

String _$telemetryHash() => r'3fbdad44e6dd052b6567ccf9fb948bda6c4adffe';
