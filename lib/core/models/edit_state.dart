import 'dart:typed_data';

import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/adjustments.dart';
import 'package:auvie/core/models/crop.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/tone_curve.dart';
import 'package:auvie/core/models/video_timeline.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_state.freezed.dart';
part 'edit_state.g.dart';

/// Everything needed to rebuild an edit from the untouched original
/// (spec §10). Small enough to keep whole copies in the undo history.
@freezed
abstract class EditState with _$EditState {
  const factory({
    @Default(Adjustments()) Adjustments adjustments,
    @Default(ToneCurves()) ToneCurves curves,
    PresetRef? preset,
    @Default(CropTransform()) CropTransform crop,
    @Default(<EditElement>[]) List<EditElement> elements,

    /// Only for video projects.
    VideoTimeline? video,
  }) = _EditState;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$EditStateFromJson(json);

  /// Offset applied to a duplicated element so it doesn't hide the original.
  static const duplicateOffset = 0.03;

  bool get isUnedited =>
      adjustments.isNeutral &&
      curves.isIdentity &&
      preset == null &&
      crop.isIdentity &&
      elements.isEmpty &&
      (video == null || video == const VideoTimeline());

  // Adjustments and preset.

  EditState withAdjustment(Adjustment adjustment, double value) =>
      copyWith(adjustments: adjustments.withValue(adjustment, value));

  /// Applies [presetId]. Switching presets keeps the current intensity.
  EditState withPreset(String presetId) => copyWith(
    preset: PresetRef(presetId: presetId, intensity: preset?.intensity ?? 1),
  );

  EditState withPresetIntensity(double intensity) {
    final current = preset;
    if (current == null) return this;
    return copyWith(preset: current.copyWith(intensity: intensity.clamp(0, 1)));
  }

  EditState withoutPreset() => copyWith(preset: null);

  /// What the engine renders: the user's adjustments plus the preset's
  /// settings scaled by intensity (spec §13). [presetData] is the catalog
  /// entry for [preset]; if it is missing or doesn't match, only the user's
  /// adjustments apply.
  Adjustments resolveAdjustments(Preset? presetData) {
    final ref = preset;
    if (ref == null || presetData == null || presetData.id != ref.presetId) {
      return adjustments;
    }
    return adjustments.combine(presetData.settings, weight: ref.intensity);
  }

  /// Curve lookup table for the engine, with the preset's curves blended by
  /// intensity under the user's curves.
  Uint8List resolveCurveLut(Preset? presetData) {
    final ref = preset;
    final matches = ref != null && presetData?.id == ref.presetId;
    return buildCurveLut(
      user: curves,
      preset: matches ? presetData?.curves : null,
      intensity: ref?.intensity ?? 0,
    );
  }

  // Elements (spec §18). Order is z-order: last is on top.

  EditState addElement(EditElement element) =>
      copyWith(elements: [...elements, element]);

  /// Replaces the element with the same id. Unknown ids are ignored.
  EditState replaceElement(EditElement element) => copyWith(
    elements: [
      for (final e in elements)
        if (e.id == element.id) element else e,
    ],
  );

  EditState removeElement(String id) => copyWith(
    elements: [
      for (final e in elements)
        if (e.id != id) e,
    ],
  );

  /// Copies element [id] as [newId], right above it and slightly offset.
  EditState duplicateElement(String id, {required String newId}) {
    final index = elements.indexWhere((e) => e.id == id);
    if (index < 0) return this;
    final copy = _offset(elements[index], newId);
    return copyWith(elements: [...elements]..insert(index + 1, copy));
  }

  static EditElement _offset(EditElement element, String newId) {
    ElementTransform shift(ElementTransform t) =>
        t.copyWith(x: t.x + duplicateOffset, y: t.y + duplicateOffset);

    return switch (element) {
      final TextElement e => e.copyWith(
        id: newId,
        transform: shift(e.transform),
      ),
      final TextPathElement e => e.copyWith(
        id: newId,
        transform: shift(e.transform),
      ),
      final BrushElement e => e.copyWith(
        id: newId,
        transform: shift(e.transform),
      ),
      final StickerElement e => e.copyWith(
        id: newId,
        transform: shift(e.transform),
      ),
      final OverlayElement e => e.copyWith(id: newId),
      final FrameElement e => e.copyWith(id: newId),
    };
  }

  // Copy / paste edits (spec §29).

  CopiedEdits copyEdits() =>
      CopiedEdits(adjustments: adjustments, curves: curves, preset: preset);

  /// Replaces adjustments, curves and preset; crop, elements and trim stay.
  EditState pasteEdits(CopiedEdits edits) => copyWith(
    adjustments: edits.adjustments,
    curves: edits.curves,
    preset: edits.preset,
  );
}

/// What "Copy Edits" carries to another media (spec §29).
@freezed
abstract class CopiedEdits with _$CopiedEdits {
  const factory({
    @Default(Adjustments()) Adjustments adjustments,
    @Default(ToneCurves()) ToneCurves curves,
    PresetRef? preset,
  }) = _CopiedEdits;

  factory fromJson(Map<String, dynamic> json) => _$CopiedEditsFromJson(json);
}
