import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:auvie/core/models/adjustment.dart';

/// The five groups of the ADJUST tool (handoff "Adjust").
enum AdjustmentFamily {
  light(AuvieIcons.light, [
    Adjustment.exposure,
    Adjustment.brightness,
    Adjustment.contrast,
    Adjustment.highlights,
    Adjustment.shadows,
  ]),
  color(AuvieIcons.color, [
    Adjustment.saturation,
    Adjustment.temperature,
    Adjustment.tint,
  ]),

  /// Tone curves, edited with the curve editor instead of a ruler.
  curve(AuvieIcons.curve, []),
  grain(AuvieIcons.grain, [
    Adjustment.sharpen,
    Adjustment.grain,
    Adjustment.fade,
    Adjustment.vignette,
  ]),

  /// Built in M4.
  crop(AuvieIcons.crop, []);

  new(this.icon, this.adjustments);

  final AuvieIcons icon;
  final List<Adjustment> adjustments;

  bool get isAvailable => this != crop;

  String get label => name.toUpperCase();
}

extension AdjustmentLabel on Adjustment {
  /// Display name, e.g. "Exposure".
  String get label => name[0].toUpperCase() + name.substring(1);

  bool get isBipolar => min < 0;

  /// "−0.34", "+0.20", "0.00"; unipolar values have no sign.
  String format(double value) {
    final text = value.abs().toStringAsFixed(2);
    if (!isBipolar || value.abs() < 0.005) return text;
    return value < 0 ? '−$text' : '+$text';
  }
}
