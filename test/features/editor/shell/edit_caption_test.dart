import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/tone_curve.dart';
import 'package:auvie/features/editor/shell/edit_caption.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ektar = Preset(
    id: 'ektar_02',
    name: 'Ektar 02',
    collectionId: 'film',
    iso: 100,
  );

  group('describeEdit', () {
    test('an untouched photo is the original', () {
      expect(describeEdit(const EditState(), null), 'Original');
    });

    test('a preset alone shows its intensity', () {
      final edit = const EditState()
          .withPreset('ektar_02')
          .withPresetIntensity(0.72);
      expect(describeEdit(edit, ektar), 'Ektar, at 72%');
    });

    test('counts adjustments, curves included', () {
      final edit = const EditState()
          .withPreset('ektar_02')
          .withPresetIntensity(0.72)
          .withAdjustment(Adjustment.exposure, -0.34)
          .withAdjustment(Adjustment.grain, 0.2)
          .copyWith(
            curves: const ToneCurves(
              master: ToneCurve(
                points: [CurvePoint(x: 0, y: 0.1), CurvePoint(x: 1, y: 1)],
              ),
            ),
          );
      expect(describeEdit(edit, ektar), 'Ektar 72%, three adjustments');
    });

    test('adjustments without a preset', () {
      expect(
        describeEdit(
          const EditState().withAdjustment(Adjustment.fade, 0.3),
          null,
        ),
        'One adjustment',
      );
      expect(
        describeEdit(
          const EditState()
              .withAdjustment(Adjustment.fade, 0.3)
              .withAdjustment(Adjustment.tint, 0.1),
          null,
        ),
        'Two adjustments',
      );
    });

    test('a preset missing from the catalog is ignored', () {
      expect(
        describeEdit(const EditState().withPreset('gone'), null),
        'Original',
      );
    });
  });

  group('preset labels', () {
    test('split the stock number from the name', () {
      expect(presetBaseName('Ektar 02'), 'Ektar');
      expect(presetStockNumber('Ektar 02'), '02');
      expect(presetBaseName('Portra Fade'), 'Portra Fade');
      expect(presetStockNumber('Portra Fade'), isNull);
      expect(presetStockNumber('Vitrine'), isNull);
    });

    test('card meta is "number · ISO"', () {
      expect(presetMeta(ektar), '02 · 100');
      expect(
        presetMeta(
          const Preset(id: 'v', name: 'Vitrine', collectionId: 'c', iso: 100),
        ),
        '100',
      );
      expect(
        presetMeta(const Preset(id: 'x', name: 'Plain', collectionId: 'c')),
        '—',
      );
      expect(presetMeta(null), '—');
    });
  });
}
