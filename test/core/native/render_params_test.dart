import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/adjustments.dart';
import 'package:auvie/core/models/crop.dart';
import 'package:auvie/core/models/crop_geometry.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/tone_curve.dart';
import 'package:auvie/core/native/render_params.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ektar = Preset(
    id: 'ektar_02',
    name: 'Ektar 02',
    collectionId: 'film',
    settings: Adjustments.of(const {Adjustment.saturation: 0.4}),
  );

  test('neutral has no adjustments and an identity LUT', () {
    expect(RenderParams.neutral.adjustments.isNeutral, isTrue);
    expect(RenderParams.neutral.curveLut, hasLength(curveLutSize * 4));
    expect(RenderParams.neutral.curveLut[128 * 4], 128);
  });

  test('applies the preset at its intensity', () {
    final edit = const EditState()
        .withAdjustment(Adjustment.exposure, 0.1)
        .withPreset('ektar_02')
        .withPresetIntensity(0.5);

    final params = RenderParams.fromEdit(edit, ektar, mediaRatio: 1.5);

    expect(params.adjustments[Adjustment.exposure], closeTo(0.1, 1e-9));
    expect(params.adjustments[Adjustment.saturation], closeTo(0.2, 1e-9));
  });

  test('an unedited state renders neutral', () {
    expect(
      RenderParams.fromEdit(const EditState(), null, mediaRatio: 1.5),
      RenderParams.neutral,
    );
  });

  test('carries the crop geometry; cropping mode shows the whole frame', () {
    const crop = CropTransform(rect: NormalizedRect(left: 0.25, width: 0.5));
    const edit = EditState(crop: crop);
    final params = RenderParams.fromEdit(edit, null, mediaRatio: 1.5);
    expect(params.geometry, CropGeometry.matrix(crop, 1.5));
    expect(
      RenderParams.fromEdit(
        edit,
        null,
        mediaRatio: 1.5,
        cropping: true,
      ).geometry,
      Affine2.identity,
    );
    expect(RenderParams.neutral.geometry, Affine2.identity);
  });

  test('equality compares LUT contents', () {
    final a = RenderParams.fromEdit(const EditState(), null, mediaRatio: 1.5);
    final b = RenderParams.fromEdit(const EditState(), ektar, mediaRatio: 1.5);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(
      a,
      isNot(
        RenderParams.fromEdit(
          const EditState(
            curves: ToneCurves(
              master: ToneCurve(
                points: [CurvePoint(x: 0, y: 0.3), CurvePoint(x: 1, y: 1)],
              ),
            ),
          ),
          null,
          mediaRatio: 1.5,
        ),
      ),
    );
  });
}
