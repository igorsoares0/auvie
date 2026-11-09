import 'package:auvie/core/models/color_mix.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/models/video_timeline.dart';
import 'package:auvie/features/editor/adjustments/adjustment_family.dart';
import 'package:auvie/features/editor/elements/text_presets.dart';
import 'package:auvie/features/editor/history/edit_history.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'editor_session.freezed.dart';

/// Tools of the editor toolbar. Videos add TRIM (the timeline) first.
enum EditorTool {
  trim,
  film,
  adjust,

  type,
  add;

  bool get isAvailable => true;

  static List<EditorTool> forMedia(MediaType media) => switch (media) {
    MediaType.photo => const [film, adjust, type, add],
    MediaType.video => values,
  };
}

/// TYPE's two modes (handoff 04).
enum TypeMode { setType, textBrush }

/// ADD's tabs.
enum AddTab { stickers, overlays, frames }

/// Special FILM category listing favorites.
const savedCategory = 'saved';

/// Everything on screen in the editor, besides the pixels (and, for
/// videos, the playhead: see VideoPlayback).
@freezed
abstract class EditorSession with _$EditorSession {
  const factory({
    required Project project,
    required EditHistory<EditState> history,
    @Default(EditorTool.film) EditorTool tool,
    @Default(AdjustmentFamily.light) AdjustmentFamily family,

    /// Index into [family]'s adjustments; for HSL, into `ColorChannel`.
    @Default(0) int parameter,

    /// Color range edited by HSL.
    @Default(ColorBand.red) ColorBand colorBand,

    /// Collection id, or [savedCategory].
    String? category,

    /// Element shown with its frame and pill.
    String? selectedElementId,

    /// Text element being typed (the keyboard is up).
    String? editingElementId,
    @Default(TypeMode.setType) TypeMode typeMode,

    /// Look of the next text added (when no text is selected).
    @Default(TextPreset.didone) TextPreset textPreset,
    @Default(0xFFF6F0E6) int textColor,
    @Default(AddTab.stickers) AddTab addTab,
  }) = _EditorSession;

  const new _();

  EditState get edit => history.present;

  EditElement? element(String? id) =>
      id == null ? null : edit.elements.where((e) => e.id == id).firstOrNull;

  EditElement? get selected => element(selectedElementId);

  /// Tools with more controls than the compact panel holds.
  bool get needsTallPanel => switch (tool) {
    EditorTool.type => true,
    EditorTool.adjust => !family.usesRuler,
    EditorTool.add => addTab == AddTab.overlays,
    EditorTool.trim || EditorTool.film => false,
  };

  bool get isVideo => project.media.type == MediaType.video;

  /// The trim and sound of a video (default for photos, unused).
  VideoTimeline get timeline => edit.video ?? const VideoTimeline();

  /// Length of the original clip; 0 for photos.
  int get durationMs => project.media.durationMs ?? 0;
}
