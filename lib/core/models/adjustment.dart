/// Scalar adjustments (spec §11). Curves live in `ToneCurves`.
///
/// Values are normalized for the engine: bipolar parameters go from −1 to +1
/// with 0 as neutral; unipolar ones (sharpen, grain, fade) go from 0 to 1.
/// The UI may show other scales.
enum Adjustment {
  exposure,
  brightness,
  contrast,
  highlights,
  shadows,
  saturation,
  temperature,
  tint,
  sharpen(min: 0),
  grain(min: 0),
  fade(min: 0),
  vignette;

  new({this.min = -1});

  final double min;

  double get max => 1;

  double clamp(double value) => value.clamp(min, max);
}
