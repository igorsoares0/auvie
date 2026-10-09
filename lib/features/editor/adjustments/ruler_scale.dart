import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/features/editor/adjustments/adjustment_family.dart';

/// Geometry and detents of the lens-style ruler for one [adjustment].
class RulerScale {
  const new(this.adjustment);

  final Adjustment adjustment;

  /// Minor ticks across the full range (every 0.05 for −1…+1).
  static const minorTicks = 40;

  /// Major ticks (−1, −0.5, 0, 0.5, 1 for bipolar; 0, 0.5, 1 otherwise).
  List<double> get majors =>
      adjustment.isBipolar ? const [-1, -0.5, 0, 0.5, 1] : const [0, 0.5, 1];

  double get range => adjustment.max - adjustment.min;

  /// Horizontal position (0…1) of [value].
  double fraction(double value) =>
      ((value - adjustment.min) / range).clamp(0, 1);

  /// [value] moved by a horizontal drag of [dx] on a ruler [width] wide.
  double drag(double value, double dx, double width) =>
      adjustment.clamp(value + dx / width * range);

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
}
