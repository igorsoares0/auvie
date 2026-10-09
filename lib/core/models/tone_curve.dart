import 'dart:math' as math;
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tone_curve.freezed.dart';
part 'tone_curve.g.dart';

@freezed
abstract class CurvePoint with _$CurvePoint {
  const factory({required double x, required double y}) = _CurvePoint;

  factory fromJson(Map<String, dynamic> json) => _$CurvePointFromJson(json);
}

/// A tone curve through control points in 0…1, interpolated with a monotone
/// cubic spline (Fritsch–Carlson): it never overshoots between points, so a
/// curve drawn as increasing stays increasing.
@freezed
abstract class ToneCurve with _$ToneCurve {
  const factory({
    @Default(<CurvePoint>[CurvePoint(x: 0, y: 0), CurvePoint(x: 1, y: 1)])
    List<CurvePoint> points,
  }) = _ToneCurve;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$ToneCurveFromJson(json);

  bool get isIdentity => points.every((p) => (p.x - p.y).abs() < 1e-6);

  double evaluate(double x) => sampler()(x);

  /// Precomputes the spline; use it when evaluating many values.
  double Function(double x) sampler() => _MonotoneSpline(points).evaluate;
}

/// Master curve plus per-channel curves. Each channel's output is
/// `channel(master(x))`.
@freezed
abstract class ToneCurves with _$ToneCurves {
  const factory({
    @Default(ToneCurve()) ToneCurve master,
    @Default(ToneCurve()) ToneCurve red,
    @Default(ToneCurve()) ToneCurve green,
    @Default(ToneCurve()) ToneCurve blue,
  }) = _ToneCurves;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$ToneCurvesFromJson(json);

  bool get isIdentity =>
      master.isIdentity &&
      red.isIdentity &&
      green.isIdentity &&
      blue.isIdentity;

  /// One sampler per output channel (R, G, B), each including the master.
  List<double Function(double)> _channelSamplers() {
    final m = master.sampler();
    double Function(double) withMaster(ToneCurve curve) {
      final c = curve.sampler();
      return (x) => c(m(x));
    }

    return [withMaster(red), withMaster(green), withMaster(blue)];
  }
}

/// Size of the curve lookup table read by the develop shader.
const curveLutSize = 256;

/// Builds the 256×1 RGBA lookup table the develop shader samples for curves.
///
/// The preset's curves are blended toward identity by [intensity] (like the
/// preset's scalar settings), then the user's [user] curves are applied on
/// top. Alpha is always 255.
Uint8List buildCurveLut({
  required ToneCurves user,
  ToneCurves? preset,
  double intensity = 1,
}) {
  final userChannels = user._channelSamplers();
  final presetChannels = preset?._channelSamplers();
  final weight = intensity.clamp(0, 1);
  final lut = Uint8List(curveLutSize * 4);

  for (var i = 0; i < curveLutSize; i++) {
    final x = i / (curveLutSize - 1);
    for (var c = 0; c < 3; c++) {
      var value = x;
      if (presetChannels != null) {
        value = x + (presetChannels[c](x) - x) * weight;
      }
      value = userChannels[c](value);
      lut[i * 4 + c] = (value * 255).round().clamp(0, 255);
    }
    lut[i * 4 + 3] = 255;
  }
  return lut;
}

class _MonotoneSpline {
  factory(List<CurvePoint> points) {
    final sorted = [...points]..sort((a, b) => a.x.compareTo(b.x));
    final xs = [for (final p in sorted) p.x.clamp(0.0, 1.0)];
    final ys = [for (final p in sorted) p.y.clamp(0.0, 1.0)];
    return _MonotoneSpline._(xs, ys, _tangents(xs, ys));
  }

  new _(this._xs, this._ys, this._ms);

  final List<double> _xs;
  final List<double> _ys;
  final List<double> _ms;

  static List<double> _tangents(List<double> xs, List<double> ys) {
    final n = xs.length;
    if (n < 2) return List.filled(n, 0);

    final secants = [
      for (var k = 0; k < n - 1; k++)
        if (xs[k + 1] == xs[k])
          0.0
        else
          (ys[k + 1] - ys[k]) / (xs[k + 1] - xs[k]),
    ];
    final ms = List<double>.filled(n, 0);
    ms[0] = secants.first;
    ms[n - 1] = secants.last;
    for (var k = 1; k < n - 1; k++) {
      final (a, b) = (secants[k - 1], secants[k]);
      ms[k] = a * b <= 0 ? 0 : (a + b) / 2;
    }
    // Fritsch–Carlson: limit tangents so each segment stays monotone.
    for (var k = 0; k < n - 1; k++) {
      final d = secants[k];
      if (d == 0) {
        ms[k] = 0;
        ms[k + 1] = 0;
        continue;
      }
      final a = ms[k] / d;
      final b = ms[k + 1] / d;
      final s = a * a + b * b;
      if (s > 9) {
        final t = 3 / math.sqrt(s);
        ms[k] = t * a * d;
        ms[k + 1] = t * b * d;
      }
    }
    return ms;
  }

  double evaluate(double x) {
    final n = _xs.length;
    if (n == 0) return x.clamp(0, 1);
    if (n == 1 || x <= _xs.first) return _ys.first;
    if (x >= _xs.last) return _ys.last;

    var k = 0;
    while (x > _xs[k + 1]) {
      k++;
    }
    final h = _xs[k + 1] - _xs[k];
    if (h == 0) return _ys[k + 1];
    final t = (x - _xs[k]) / h;
    final t2 = t * t;
    final t3 = t2 * t;
    final y =
        (2 * t3 - 3 * t2 + 1) * _ys[k] +
        (t3 - 2 * t2 + t) * h * _ms[k] +
        (-2 * t3 + 3 * t2) * _ys[k + 1] +
        (t3 - t2) * h * _ms[k + 1];
    return y.clamp(0, 1);
  }
}
