import 'dart:convert';

import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/adjustments.dart';
import 'package:auvie/core/models/crop.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/tone_curve.dart';
import 'package:auvie/core/models/video_timeline.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  const edit = EditState();

  test('a new edit is unedited', () {
    expect(edit.isUnedited, isTrue);
    expect(const EditState(video: VideoTimeline()).isUnedited, isTrue);
    expect(edit.withAdjustment(Adjustment.fade, 0.2).isUnedited, isFalse);
    expect(edit.withPreset('ektar_02').isUnedited, isFalse);
    expect(
      const EditState(crop: CropTransform(quarterTurns: 1)).isUnedited,
      isFalse,
    );
    expect(
      const EditState(video: VideoTimeline(muted: true)).isUnedited,
      isFalse,
    );
  });

  group('preset', () {
    test('applies at full intensity', () {
      expect(
        edit.withPreset('ektar_02').preset,
        const PresetRef(presetId: 'ektar_02'),
      );
    });

    test('switching presets keeps the intensity', () {
      final next = edit
          .withPreset('ektar_02')
          .withPresetIntensity(0.72)
          .withPreset('portra_04');
      expect(
        next.preset,
        const PresetRef(presetId: 'portra_04', intensity: 0.72),
      );
    });

    test('intensity is clamped to 0…1 and ignored without a preset', () {
      final withPreset = edit.withPreset('ektar_02');
      expect(withPreset.withPresetIntensity(1.4).preset!.intensity, 1);
      expect(withPreset.withPresetIntensity(-1).preset!.intensity, 0);
      expect(edit.withPresetIntensity(0.5), edit);
    });

    test('can be removed', () {
      expect(edit.withPreset('ektar_02').withoutPreset().preset, isNull);
    });
  });

  group('resolveAdjustments', () {
    final ektar = Preset(
      id: 'ektar_02',
      name: 'Ektar 02',
      collectionId: 'film',
      settings: Adjustments.of(const {Adjustment.exposure: 0.2}),
    );
    final manual = edit.withAdjustment(Adjustment.exposure, 0.1);

    test('adds the preset scaled by intensity to manual values', () {
      final resolved = manual
          .withPreset('ektar_02')
          .withPresetIntensity(0.5)
          .resolveAdjustments(ektar);
      expect(resolved[Adjustment.exposure], closeTo(0.2, 1e-9));
    });

    test('uses only manual values without a preset', () {
      expect(manual.resolveAdjustments(ektar), manual.adjustments);
    });

    test('ignores preset data that does not match (removed from catalog)', () {
      final other = manual.withPreset('portra_04');
      expect(other.resolveAdjustments(ektar), manual.adjustments);
      expect(other.resolveAdjustments(null), manual.adjustments);
    });
  });

  group('resolveCurveLut', () {
    const faded = Preset(
      id: 'fade',
      name: 'Fade',
      collectionId: 'vintage',
      curves: ToneCurves(
        master: ToneCurve(
          points: [CurvePoint(x: 0, y: 0.2), CurvePoint(x: 1, y: 1)],
        ),
      ),
    );
    final identity = buildCurveLut(user: const ToneCurves());

    test('includes the preset curves', () {
      final lut = edit.withPreset('fade').resolveCurveLut(faded);
      expect(lut[0], (0.2 * 255).round());
    });

    test('preset curves follow intensity', () {
      final lut = edit
          .withPreset('fade')
          .withPresetIntensity(0)
          .resolveCurveLut(faded);
      expect(lut, identity);
    });

    test('without a matching preset only user curves apply', () {
      expect(edit.resolveCurveLut(faded), identity);
      expect(edit.withPreset('other').resolveCurveLut(faded), identity);
    });
  });

  group('elements', () {
    const a = EditElement.sticker(id: 'a', assetId: 'star');
    const b = EditElement.sticker(id: 'b', assetId: 'moon');

    test('are added on top', () {
      final next = edit.addElement(a).addElement(b);
      expect(next.elements.map((e) => e.id), ['a', 'b']);
    });

    test('are replaced by id, unknown ids ignored', () {
      final moved = (a as StickerElement).copyWith(opacity: 0.5);
      final next = edit.addElement(a).addElement(b).replaceElement(moved);
      expect(next.elements, [moved, b]);
      expect(
        next.replaceElement(const EditElement.sticker(id: 'zzz', assetId: 'x')),
        next,
      );
    });

    test('are removed by id', () {
      final next = edit.addElement(a).addElement(b).removeElement('a');
      expect(next.elements, [b]);
    });

    test('duplicates sit right above the original, slightly offset', () {
      final next = edit
          .addElement(a)
          .addElement(b)
          .duplicateElement('a', newId: 'a2');
      expect(next.elements.map((e) => e.id), ['a', 'a2', 'b']);
      final copy = next.elements[1] as StickerElement;
      expect(copy.assetId, 'star');
      expect(copy.transform.x, closeTo(0.5 + EditState.duplicateOffset, 1e-9));
      expect(copy.transform.y, closeTo(0.5 + EditState.duplicateOffset, 1e-9));
    });

    test('every element type can be duplicated', () {
      var state = EditState(elements: allElements);
      for (final e in allElements) {
        state = state.duplicateElement(e.id, newId: '${e.id}-copy');
      }
      expect(state.elements, hasLength(allElements.length * 2));
      for (final e in allElements) {
        final copy = state.elements.firstWhere((c) => c.id == '${e.id}-copy');
        expect(copy.runtimeType, e.runtimeType);
      }
    });

    test('duplicating an unknown id does nothing', () {
      final state = edit.addElement(a);
      expect(state.duplicateElement('zzz', newId: 'x'), state);
    });
  });

  group('copy / paste edits (spec §29)', () {
    test('carries adjustments, curves and preset only', () {
      final source = richEdit();
      final target = const EditState(
        crop: CropTransform(flipVertical: true),
        elements: [EditElement.sticker(id: 'mine', assetId: 'star')],
        video: VideoTimeline(trimStartMs: 1000),
      ).withAdjustment(Adjustment.tint, 0.4);

      final pasted = target.pasteEdits(source.copyEdits());

      expect(pasted.adjustments, source.adjustments);
      expect(pasted.curves, source.curves);
      expect(pasted.preset, source.preset);
      expect(pasted.crop, target.crop);
      expect(pasted.elements, target.elements);
      expect(pasted.video, target.video);
    });

    test('copied edits round-trip through JSON', () {
      final copied = richEdit().copyEdits();
      final json = jsonDecode(jsonEncode(copied)) as Map<String, dynamic>;
      expect(CopiedEdits.fromJson(json), copied);
    });
  });

  test('a full edit round-trips through JSON text', () {
    final state = richEdit();
    final json = jsonDecode(jsonEncode(state)) as Map<String, dynamic>;
    expect(EditState.fromJson(json), state);
  });
}
