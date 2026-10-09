import 'package:auvie/core/models/adjustments.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/tone_curve.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// What the develop shader needs: final adjustment values (preset already
/// applied) and the curve lookup table.
@immutable
class RenderParams {
  const new({required this.adjustments, required this.curveLut});

  factory fromEdit(EditState edit, Preset? preset) => RenderParams(
    adjustments: edit.resolveAdjustments(preset),
    curveLut: edit.resolveCurveLut(preset),
  );

  static final neutral = RenderParams(
    adjustments: const Adjustments(),
    curveLut: buildCurveLut(user: const ToneCurves()),
  );

  final Adjustments adjustments;

  /// 256×1 RGBA.
  final Uint8List curveLut;

  @override
  bool operator ==(Object other) =>
      other is RenderParams &&
      other.adjustments == adjustments &&
      const ListEquality<int>().equals(other.curveLut, curveLut);

  @override
  int get hashCode =>
      Object.hash(adjustments, const ListEquality<int>().hash(curveLut));
}
