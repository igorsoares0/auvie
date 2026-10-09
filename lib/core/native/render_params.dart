import 'package:auvie/core/models/adjustments.dart';
import 'package:auvie/core/models/crop_geometry.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/tone_curve.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// What the develop shader needs: final adjustment values (preset already
/// applied), the curve lookup table and the crop geometry.
@immutable
class RenderParams {
  const new({
    required this.adjustments,
    required this.curveLut,
    this.geometry = Affine2.identity,
  });

  /// [mediaRatio] is the original's width / height. With [cropping] the
  /// geometry shows the whole straightened frame (to draw the crop over it)
  /// instead of the crop itself.
  factory fromEdit(
    EditState edit,
    Preset? preset, {
    required double mediaRatio,
    bool cropping = false,
  }) => RenderParams(
    adjustments: edit.resolveAdjustments(preset),
    curveLut: edit.resolveCurveLut(preset),
    geometry: CropGeometry.matrix(
      edit.crop,
      mediaRatio,
      includeCrop: !cropping,
    ),
  );

  static final neutral = RenderParams(
    adjustments: const Adjustments(),
    curveLut: buildCurveLut(user: const ToneCurves()),
  );

  final Adjustments adjustments;

  /// 256×1 RGBA.
  final Uint8List curveLut;

  /// Output uv → source uv.
  final Affine2 geometry;

  @override
  bool operator ==(Object other) =>
      other is RenderParams &&
      other.adjustments == adjustments &&
      other.geometry == geometry &&
      const ListEquality<int>().equals(other.curveLut, curveLut);

  @override
  int get hashCode => Object.hash(
    adjustments,
    geometry,
    const ListEquality<int>().hash(curveLut),
  );
}
