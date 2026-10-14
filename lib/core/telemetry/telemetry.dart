import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'telemetry.g.dart';

/// Moments worth counting (spec §60), each with the only properties it may
/// carry. Nothing personal ever goes in: no media, URI, project name or
/// typed text, only catalog ids, kinds and codes.
enum TelemetryEvent {
  /// `preset`: catalog id; `source`: film | archive.
  presetApplied('preset_applied', {'preset', 'source'}),

  /// `media`: photo | video; `size`: the export size option.
  exportFinished('export_finished', {'media', 'size'}),

  /// `media`, and `code`: a MediaEngineError code.
  exportFailed('export_failed', {'media', 'code'}),

  /// `source`: where the paywall was opened from.
  paywallViewed('paywall_viewed', {'source'}),

  /// `plan`: yearly | monthly; `outcome`: done | cancelled | pending |
  /// failed.
  purchaseFinished('purchase_finished', {'plan', 'outcome'});

  new(this.name, this.properties);

  /// Wire name.
  final String name;
  final Set<String> properties;
}

/// Where anonymous events and errors go. At launch nothing leaves the
/// device ([NoopTelemetry]); a service such as PostHog is one more
/// implementation (decision M9).
abstract interface class Telemetry {
  void event(TelemetryEvent event, [Map<String, Object> properties]);

  /// An error the app recovered from, or that reached the top ([fatal]).
  void error(Object error, StackTrace? stack, {bool fatal = false});
}

/// Sends nothing. In debug builds it prints, to see the events happen.
class NoopTelemetry implements Telemetry {
  const new();

  @override
  void event(
    TelemetryEvent event, [
    Map<String, Object> properties = const {},
  ]) {
    assert(
      properties.keys.every(event.properties.contains),
      '${event.name} can only carry ${event.properties}',
    );
    if (kDebugMode) debugPrint('telemetry: ${event.name} $properties');
  }

  @override
  void error(Object error, StackTrace? stack, {bool fatal = false}) {
    if (kDebugMode) {
      debugPrint('telemetry: ${fatal ? 'fatal ' : ''}error $error');
    }
  }
}

@Riverpod(keepAlive: true)
Telemetry telemetry(Ref ref) => const NoopTelemetry();
