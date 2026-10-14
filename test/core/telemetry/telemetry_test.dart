import 'package:auvie/core/telemetry/telemetry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('events never carry personal data', () {
    const personal = {'uri', 'name', 'text', 'path', 'email'};
    for (final event in TelemetryEvent.values) {
      expect(event.properties.intersection(personal), isEmpty);
      expect(event.name, matches(RegExp(r'^[a-z_]+$')));
    }
  });

  test('NoopTelemetry rejects properties an event may not carry', () {
    const telemetry = NoopTelemetry();
    telemetry.event(TelemetryEvent.paywallViewed, {'source': 'export'});
    expect(
      () => telemetry.event(TelemetryEvent.paywallViewed, {'uri': 'x'}),
      throwsA(isA<AssertionError>()),
    );
    telemetry.error(StateError('x'), StackTrace.current, fatal: true);
  });
}
