import 'dart:async';

import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/models/crop.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/adjustments/adjustment_family.dart';
import 'package:auvie/features/editor/history/edit_history.dart';
import 'package:auvie/features/editor/photo/editor_session.dart';
import 'package:auvie/features/projects/project_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_editor_controller.g.dart';

class ProjectNotFoundException implements Exception {
  const new(this.id);

  final String id;

  @override
  String toString() => 'ProjectNotFoundException($id)';
}

/// A missing or unreadable project won't appear by retrying.
Duration? _noRetry(int retryCount, Object error) => null;

/// State and actions of the photo editor for one project. Edits autosave
/// [saveDelay] after the last change (spec: errors never discard an edit).
@Riverpod(retry: _noRetry)
class PhotoEditor extends _$PhotoEditor {
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
    if (tool.isAvailable) _update(_session.copyWith(tool: tool), save: false);
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
