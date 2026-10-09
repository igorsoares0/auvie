import 'package:auvie/core/models/adjustment.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// A set of adjustment values, sparse: missing parameters are neutral (0).
///
/// Values are always clamped to their range and neutral values are dropped,
/// so two sets that render the same compare equal.
///
/// JSON is a flat map (`{"exposure": 0.05, "grain": 0.25}`), the format of
/// preset `settings` in spec §12. Unknown keys are ignored so older app
/// versions can read newer catalogs.
@immutable
class Adjustments {
  const new() : _values = const {};

  const new _(this._values);

  factory of(Map<Adjustment, double> values) {
    final canonical = <Adjustment, double>{};
    for (final adjustment in Adjustment.values) {
      final value = values[adjustment];
      if (value == null) continue;
      final clamped = adjustment.clamp(value);
      if (clamped.abs() >= _epsilon) canonical[adjustment] = clamped;
    }
    return Adjustments._(Map.unmodifiable(canonical));
  }

  factory fromJson(Map<String, dynamic> json) {
    return Adjustments.of({
      for (final adjustment in Adjustment.values)
        if (json[adjustment.name] case final num value)
          adjustment: value.toDouble(),
    });
  }

  static const _epsilon = 1e-6;

  final Map<Adjustment, double> _values;

  double operator [](Adjustment adjustment) => _values[adjustment] ?? 0;

  /// Non-neutral values, in [Adjustment] order.
  Map<Adjustment, double> get values => _values;

  bool get isNeutral => _values.isEmpty;

  Adjustments withValue(Adjustment adjustment, double value) =>
      Adjustments.of({..._values, adjustment: value});

  /// `this + delta × weight`, clamped per parameter. With a preset's settings
  /// as [delta] and its intensity as [weight] this is spec §13:
  /// `finalValue = originalValue + presetDelta × intensity`.
  Adjustments combine(Adjustments delta, {double weight = 1}) {
    return Adjustments.of({
      for (final adjustment in Adjustment.values)
        adjustment: this[adjustment] + delta[adjustment] * weight,
    });
  }

  Map<String, dynamic> toJson() => {
    for (final MapEntry(:key, :value) in _values.entries) key.name: value,
  };

  @override
  bool operator ==(Object other) =>
      other is Adjustments &&
      const MapEquality<Adjustment, double>().equals(_values, other._values);

  @override
  int get hashCode => const MapEquality<Adjustment, double>().hash(_values);

  @override
  String toString() => 'Adjustments(${toJson()})';
}
