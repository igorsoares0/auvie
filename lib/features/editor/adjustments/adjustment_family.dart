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

  /// Crop, rotate, flip and straighten (crop controls, not a ruler).
  crop(AuvieIcons.crop, []);

  new(this.icon, this.adjustments);

  final AuvieIcons icon;
  final List<Adjustment> adjustments;

  /// Families edited with a ruler, one adjustment at a time.
  bool get usesRuler => adjustments.isNotEmpty;

  String get label => name.toUpperCase();
}

extension AdjustmentLabel on Adjustment {
  /// Display name, e.g. "Exposure".
  String get label => name[0].toUpperCase() + name.substring(1);

  bool get isBipolar => min < 0;

  /// Ruler labels: "−1.0 · 0 · +1.0", or "0 · 0.5 · 1.0".
  List<String> get rulerLabels =>
      isBipolar ? const ['−1.0', '0', '+1.0'] : const ['0', '0.5', '1.0'];

  /// "−0.34", "+0.20", "0.00"; unipolar values have no sign.
  String format(double value) {
    final text = value.abs().toStringAsFixed(2);
    if (!isBipolar || value.abs() < 0.005) return text;
    return value < 0 ? '−$text' : '+$text';
  }
}
