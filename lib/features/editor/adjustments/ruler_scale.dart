import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/features/editor/adjustments/adjustment_family.dart';
import 'package:flutter/foundation.dart';

/// Geometry and detents of a lens-style ruler from [min] to [max].
@immutable
class RulerScale {
  const new({required this.min, required this.max, required this.majors});

  factory forAdjustment(Adjustment adjustment) => RulerScale(
    min: adjustment.min,
    max: adjustment.max,
    majors: adjustment.isBipolar
        ? const [-1, -0.5, 0, 0.5, 1]
        : const [0, 0.5, 1],
  );

  /// Straighten, in degrees.
  static const straighten = RulerScale(
    min: -45,
    max: 45,
    majors: [-45, -15, 0, 15, 45],
  );

  /// Minor ticks across the full range.
  static const minorTicks = 40;

  final double min;
  final double max;

  /// Major ticks; crossing one gives a haptic.
  final List<double> majors;

  double get range => max - min;

  double clamp(double value) => value.clamp(min, max);

  /// Horizontal position (0…1) of [value].
  double fraction(double value) => ((value - min) / range).clamp(0, 1);

  /// [value] moved by a horizontal drag of [dx] on a ruler [width] wide.
  double drag(double value, double dx, double width) =>
      clamp(value + dx / width * range);

  /// The major tick passed when going from [from] to [to], if any. Moves
  /// that start on a tick don't report it again; landing exactly on one does.
  double? crossedMajor(double from, double to) {
    if (from == to) return null;
    for (final tick in majors) {
      final passed = from < to
          ? from < tick && tick <= to
          : from > tick && tick >= to;
      if (passed) return tick;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is RulerScale &&
      other.min == min &&
      other.max == max &&
      _sameList(other.majors, majors);

  @override
  int get hashCode => Object.hash(min, max, Object.hashAll(majors));

  static bool _sameList(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
