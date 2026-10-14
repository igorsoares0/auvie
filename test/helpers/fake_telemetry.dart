import 'package:auvie/core/telemetry/telemetry.dart';

/// Records events and errors, checking events carry only allowed keys.
class FakeTelemetry implements Telemetry {
  final events = <(TelemetryEvent, Map<String, Object>)>[];
  final errors = <Object>[];

  @override
  void event(
    TelemetryEvent event, [
    Map<String, Object> properties = const {},
  ]) {
    if (!properties.keys.every(event.properties.contains)) {
      throw ArgumentError('${event.name} got $properties');
    }
    events.add((event, properties));
  }

  @override
  void error(Object error, StackTrace? stack, {bool fatal = false}) =>
      errors.add(error);

  List<Map<String, Object>> of(TelemetryEvent event) => [
    for (final (e, props) in events)
      if (e == event) props,
  ];
}
