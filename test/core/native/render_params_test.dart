import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/adjustments.dart';
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

    final params = RenderParams.fromEdit(edit, ektar);

    expect(params.adjustments[Adjustment.exposure], closeTo(0.1, 1e-9));
    expect(params.adjustments[Adjustment.saturation], closeTo(0.2, 1e-9));
  });

  test('an unedited state renders neutral', () {
    expect(
      RenderParams.fromEdit(const EditState(), null),
      RenderParams.neutral,
    );
  });

  test('equality compares LUT contents', () {
    final a = RenderParams.fromEdit(const EditState(), null);
    final b = RenderParams.fromEdit(const EditState(), ektar);
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
        ),
      ),
    );
  });
}
