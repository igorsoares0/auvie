import 'dart:async';

import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/models/crop.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/adjustments/adjustment_family.dart';
import 'package:auvie/features/editor/elements/element_geometry.dart';
import 'package:auvie/features/editor/elements/text_presets.dart';
import 'package:auvie/features/editor/history/edit_history.dart';
import 'package:auvie/features/editor/shell/editor_session.dart';
import 'package:auvie/features/editor/video/video_playback.dart';
import 'package:auvie/features/projects/project_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'editor_controller.g.dart';

class ProjectNotFoundException implements Exception {
  const new(this.id);

  final String id;

  @override
  String toString() => 'ProjectNotFoundException($id)';
}

/// Makes ids for new elements (overridable so tests are deterministic:
/// brush and overlay textures are seeded by the id).
@Riverpod(keepAlive: true)
String Function() elementIds(Ref ref) => const Uuid().v4;

/// A missing or unreadable project won't appear by retrying.
Duration? _noRetry(int retryCount, Object error) => null;

/// State and actions of the photo and video editors for one project.
/// Edits autosave [saveDelay] after the last change (spec: errors never
/// discard an edit).
@Riverpod(retry: _noRetry)
class EditorController extends _$EditorController {
  static const saveDelay = Duration(milliseconds: 500);

  Timer? _saveTimer;
  Future<void>? _saving;

  /// Mirror of the state for onDispose, where Riverpod forbids reading it.
  EditorSession? _latest;

  @override
  Future<EditorSession> build(String projectId) async {
    final repository = ref.watch(projectRepositoryProvider);
    ref.onDispose(() {
      // Never drop a pending save, however the editor goes away.
      final pending = _saveTimer?.isActive ?? false;
      _saveTimer?.cancel();
      final session = _latest;
      if (pending && session != null) {
        unawaited(
          repository.save(session.project.copyWith(edit: session.edit)),
        );
      }
    });
    final project = await repository.find(projectId);
    if (project == null) throw ProjectNotFoundException(projectId);
    final catalog = await ref.watch(catalogProvider.future);
    return _latest = EditorSession(
      project: project,
      history: EditHistory(project.edit),
      tool: project.media.type == MediaType.video
          ? EditorTool.trim
          : EditorTool.film,
      category: catalog.sortedCollections.firstOrNull?.id ?? savedCategory,
    );
  }

  EditorSession get _session => state.requireValue;

  void _update(EditorSession next, {bool save = true}) {
    _latest = next;
    state = AsyncData(next);
    if (save) _scheduleSave();
  }

  /// The crop as of the latest preview, so successive drag events build on
  /// each other within one frame.
  CropTransform get currentCrop => _session.edit.crop;

  /// The catalog entry of the applied preset, if any.
  Preset? get preset {
    final id = _session.edit.preset?.presetId;
    return id == null ? null : ref.read(catalogProvider).value?.presetById(id);
  }

  // Edits.

  /// Records [edit] as one undo step (taps, resets).
  void record(EditState edit) =>
      _update(_session.copyWith(history: _session.history.record(edit)));

  /// Shows [edit] during a gesture; [commit] makes the gesture one step.
  void preview(EditState edit) =>
      _update(_session.copyWith(history: _session.history.preview(edit)));

  void commit() =>
      _update(_session.copyWith(history: _session.history.commit()));

  void undo() => _update(_session.copyWith(history: _session.history.undo()));

  void redo() => _update(_session.copyWith(history: _session.history.redo()));

  // Navigation inside the editor (not saved).

  void selectTool(EditorTool tool) {
    if (!tool.isAvailable) return;
    _update(_session.copyWith(tool: tool, activeBrushId: null), save: false);
  }

  void selectFamily(AdjustmentFamily family) {
    _update(_session.copyWith(family: family, parameter: 0), save: false);
  }

  /// Moves to the next (+1) or previous (−1) parameter of the family.
  void stepParameter(int delta) {
    final count = _session.family.adjustments.length;
    if (count == 0) return;
    final next = (_session.parameter + delta).clamp(0, count - 1);
    _update(_session.copyWith(parameter: next), save: false);
  }

  void selectCategory(String category) =>
      _update(_session.copyWith(category: category), save: false);

  // Elements (spec §18–26).

  String _newId() => ref.read(elementIdsProvider)();

  /// A new element of a video shows from the playhead to the end of the
  /// trim (decision M6); photos ignore time.
  EditElement _timed(EditElement element) {
    final session = _session;
    if (!session.isVideo || session.durationMs <= 0) return element;
    final playhead = ref.read(videoPlaybackProvider(projectId)).positionMs;
    return element.withTime(
      session.timeline.defaultElementTime(
        playheadMs: playhead,
        durationMs: session.durationMs,
      ),
    );
  }

  void selectElement(String? id) =>
      _update(_session.copyWith(selectedElementId: id), save: false);

  void setTypeMode(TypeMode mode) => _update(
    _session.copyWith(typeMode: mode, selectedElementId: null),
    save: false,
  );

  void setAddTab(AddTab tab) =>
      _update(_session.copyWith(addTab: tab), save: false);

  /// Style of a new text: the chosen preset, size and ink.
  TextStyleSpec get _newTextStyle =>
      _session.textPreset.style.copyWith(color: _session.textColor);

  /// Adds a text at [center] (output fractions) and opens the keyboard.
  void addText({Offset center = const Offset(0.5, 0.5)}) {
    final id = _newId();
    final element = _timed(
      EditElement.text(
        id: id,
        text: '',
        style: _newTextStyle,
        textPresetId: _session.textPreset.name,
        transform: ElementTransform(x: center.dx, y: center.dy),
      ),
    );
    _update(
      _session.copyWith(
        history: _session.history.preview(_session.edit.addElement(element)),
        selectedElementId: id,
        editingElementId: id,
      ),
      save: false,
    );
  }

  /// Adds text along [path] (output fractions) and opens the keyboard.
  void addTextPath(List<StrokePoint> path) {
    if (path.length < 2) return;
    final id = _newId();
    final element = _timed(
      EditElement.textPath(id: id, text: '', path: path, style: _newTextStyle),
    );
    _update(
      _session.copyWith(
        history: _session.history.preview(_session.edit.addElement(element)),
        selectedElementId: id,
        editingElementId: id,
      ),
      save: false,
    );
  }

  /// Opens the keyboard on the selected text.
  void editSelectedText() {
    final selected = _session.selected;
    if (selected is TextElement || selected is TextPathElement) {
      _update(_session.copyWith(editingElementId: selected!.id), save: false);
    }
  }

  /// Live text while typing (one undo step when done).
  void typeText(String text) {
    final editing = _session.element(_session.editingElementId);
    final next = switch (editing) {
      final TextElement e => e.copyWith(text: text),
      final TextPathElement e => e.copyWith(text: text),
      _ => null,
    };
    if (next != null) preview(_session.edit.replaceElement(next));
  }

  /// DONE: keeps the text (an empty text is removed).
  void finishTyping() {
    final editing = _session.element(_session.editingElementId);
    final text = switch (editing) {
      final TextElement e => e.text,
      final TextPathElement e => e.text,
      _ => '',
    };
    if (editing != null && text.trim().isEmpty) {
      _update(
        _session.copyWith(
          history: _session.history.discard(),
          editingElementId: null,
          selectedElementId: null,
        ),
      );
      if (_session.edit.elements.any((e) => e.id == editing.id)) {
        record(_session.edit.removeElement(editing.id));
      }
      return;
    }
    _update(
      _session.copyWith(
        history: _session.history.commit(),
        editingElementId: null,
      ),
    );
  }

  /// CANCEL: back to the text as it was (a new text disappears).
  void cancelTyping() {
    final id = _session.editingElementId;
    final history = _session.history.discard();
    final stillThere = history.present.elements.any((e) => e.id == id);
    _update(
      _session.copyWith(
        history: history,
        editingElementId: null,
        selectedElementId: stillThere ? id : null,
      ),
      save: false,
    );
  }

  /// Applies [change] to the selected text, or to the defaults for the next
  /// one when no text is selected.
  void styleText(
    TextStyleSpec Function(TextStyleSpec) change, {
    TextPreset? preset,
    int? color,
  }) {
    final selected = _session.selected;
    final next = switch (selected) {
      final TextElement e => e.copyWith(
        style: change(e.style),
        textPresetId: preset?.name ?? e.textPresetId,
      ),
      final TextPathElement e => e.copyWith(style: change(e.style)),
      _ => null,
    };
    if (next != null) {
      record(_session.edit.replaceElement(next));
    } else {
      _update(
        _session.copyWith(
          textPreset: preset ?? _session.textPreset,
          textColor: color ?? _session.textColor,
        ),
        save: false,
      );
    }
  }

  /// Moves / scales / turns the selected element during a gesture on an
  /// output of [size] pixels. End the gesture with [commit].
  void transformSelected(
    Size size, {
    Offset delta = Offset.zero,
    double scale = 1,
    double rotation = 0,
  }) {
    final selected = _session.selected;
    if (selected == null) return;
    preview(
      _session.edit.replaceElement(
        ElementGeometry.transformed(
          selected,
          size,
          delta: delta,
          scale: scale,
          rotation: rotation,
        ),
      ),
    );
  }

  /// Live style change while sliding SIZE; [commit] at the end.
  void previewTextStyle(TextStyleSpec Function(TextStyleSpec) change) {
    final next = switch (_session.selected) {
      final TextElement e => e.copyWith(style: change(e.style)),
      final TextPathElement e => e.copyWith(style: change(e.style)),
      _ => null,
    };
    if (next != null) preview(_session.edit.replaceElement(next));
  }

  void setSelectedOpacity(double opacity) {
    final next = switch (_session.selected) {
      final TextElement e => e.copyWith(opacity: opacity),
      final TextPathElement e => e.copyWith(opacity: opacity),
      final StickerElement e => e.copyWith(opacity: opacity),
      _ => null,
    };
    if (next != null) record(_session.edit.replaceElement(next));
  }

  void duplicateSelected() {
    final selected = _session.selected;
    if (selected == null) return;
    final id = _newId();
    record(_session.edit.duplicateElement(selected.id, newId: id));
    _update(_session.copyWith(selectedElementId: id), save: false);
  }

  void deleteSelected() {
    final selected = _session.selected;
    if (selected == null) return;
    record(_session.edit.removeElement(selected.id));
    _update(
      _session.copyWith(selectedElementId: null, activeBrushId: null),
      save: false,
    );
  }

  void setBrush(BrushSettings brush) => _update(
    _session.copyWith(brush: brush, activeBrushId: null),
    save: false,
  );

  /// Starts a brush stroke at [point] (output fractions).
  void beginStroke(StrokePoint point) {
    final active = _session.element(_session.activeBrushId);
    final stroke = BrushStroke(points: [point]);
    final brush = _session.brush;
    // On a video, strokes drawn after moving the playhead out of the
    // current drawing start a new one.
    final playhead = ref.read(videoPlaybackProvider(projectId)).positionMs;
    final visible = !_session.isVideo || (active?.visibleAt(playhead) ?? true);
    if (active is BrushElement && visible) {
      preview(
        _session.edit.replaceElement(
          active.copyWith(strokes: [...active.strokes, stroke]),
        ),
      );
      return;
    }
    final id = _newId();
    preview(
      _session.edit.addElement(
        _timed(
          EditElement.brush(
            id: id,
            brushType: brush.type,
            size: brush.size,
            color: brush.color,
            opacity: brush.opacity,
            strokes: [stroke],
          ),
        ),
      ),
    );
    _update(_session.copyWith(activeBrushId: id), save: false);
  }

  void extendStroke(StrokePoint point) {
    final active = _session.element(_session.activeBrushId);
    if (active is! BrushElement || active.strokes.isEmpty) return;
    final last = active.strokes.last;
    preview(
      _session.edit.replaceElement(
        active.copyWith(
          strokes: [
            ...active.strokes.sublist(0, active.strokes.length - 1),
            last.copyWith(points: [...last.points, point]),
          ],
        ),
      ),
    );
  }

  /// Each stroke is one undo step.
  void endStroke() => commit();

  /// Adds a sticker in the middle, tinted with the current ink.
  void addSticker(String assetId) {
    final id = _newId();
    record(
      _session.edit.addElement(
        _timed(
          EditElement.sticker(
            id: id,
            assetId: assetId,
            color: _session.textColor,
          ),
        ),
      ),
    );
    _update(_session.copyWith(selectedElementId: id), save: false);
  }

  /// Turns an overlay on (with its catalog blend and opacity) or off.
  void toggleOverlay(
    String assetId, {
    OverlayBlend blend = OverlayBlend.screen,
    double opacity = 1,
  }) {
    final existing = _session.edit.elements
        .whereType<OverlayElement>()
        .where((e) => e.assetId == assetId)
        .firstOrNull;
    if (existing != null) {
      record(_session.edit.removeElement(existing.id));
      return;
    }
    record(
      _session.edit.addElement(
        _timed(
          EditElement.overlay(
            id: _newId(),
            assetId: assetId,
            blend: blend,
            opacity: opacity,
          ),
        ),
      ),
    );
  }

  /// Live opacity of an overlay while sliding; [commit] at the end.
  void setOverlayOpacity(String elementId, double opacity) {
    final overlay = _session.element(elementId);
    if (overlay is OverlayElement) {
      preview(
        _session.edit.replaceElement(
          overlay.copyWith(opacity: opacity.clamp(0, 1)),
        ),
      );
    }
  }

  void setOverlayBlend(String elementId, OverlayBlend blend) {
    final overlay = _session.element(elementId);
    if (overlay is OverlayElement) {
      record(_session.edit.replaceElement(overlay.copyWith(blend: blend)));
    }
  }

  /// One frame at a time: choosing it again removes it.
  void toggleFrame(String assetId) {
    final current = _session.edit.elements.whereType<FrameElement>().toList();
    var edit = _session.edit;
    for (final f in current) {
      edit = edit.removeElement(f.id);
    }
    if (!current.any((f) => f.assetId == assetId)) {
      edit = edit.addElement(EditElement.frame(id: _newId(), assetId: assetId));
    }
    record(edit);
  }

  // Video timeline (spec §16–17, §23).

  /// Moves a trim handle during a drag; end the gesture with [commit].
  void previewTrim({int? startMs, int? endMs}) {
    final session = _session;
    if (!session.isVideo) return;
    preview(
      session.edit.copyWith(
        video: session.timeline.withTrim(
          durationMs: session.durationMs,
          startMs: startMs,
          endMs: endMs,
        ),
      ),
    );
  }

  void toggleMute() {
    final session = _session;
    if (!session.isVideo) return;
    final timeline = session.timeline;
    record(
      session.edit.copyWith(video: timeline.copyWith(muted: !timeline.muted)),
    );
  }

  /// Changes when element [id] shows during a drag on its lane bar; end
  /// the gesture with [commit].
  void previewElementTime(String id, TimeRange time) {
    final element = _session.element(id);
    if (element == null || element is FrameElement) return;
    preview(_session.edit.replaceElement(element.withTime(time)));
  }

  // Saving.

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDelay, () => unawaited(save()));
  }

  /// Saves now. Safe to call repeatedly; saves run one after another.
  Future<void> save() async {
    _saveTimer?.cancel();
    final previous = _saving;
    if (previous != null) await previous;
    final session = state.value;
    if (session == null) return;
    final saving = ref
        .read(projectRepositoryProvider)
        .save(session.project.copyWith(edit: session.edit));
    _saving = saving;
    await saving;
    if (identical(_saving, saving)) _saving = null;
  }

  /// Saves and refreshes the Home thumbnail. Call when leaving the editor.
  Future<void> close() async {
    final session = state.value;
    if (session == null) return;
    await save();
    try {
      await ref
          .read(projectThumbnailsProvider)
          .refresh(session.project.copyWith(edit: session.edit), preset);
    } on Object catch (e) {
      debugPrint('Thumbnail for ${session.project.id} failed: $e');
    }
  }
}
