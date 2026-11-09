import 'dart:convert';

import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/projects/project_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edits_clipboard.g.dart';

/// "Copy edits" / "Paste edits" (spec §29): the film, its intensity, the
/// adjustments, curves and color mix of one edit, ready for others. Kept
/// in the preferences, so a look copied yesterday can still be pasted.
@Riverpod(keepAlive: true)
class EditsClipboard extends _$EditsClipboard {
  @override
  CopiedEdits? build() {
    final json = ref.watch(appSettingsProvider).copiedEdits;
    if (json == null) return null;
    try {
      return CopiedEdits.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } on Object catch (e) {
      debugPrint('Copied edits unreadable, dropped: $e');
      return null;
    }
  }

  Future<void> copy(CopiedEdits edits) async {
    state = edits;
    await ref
        .read(appSettingsProvider)
        .saveCopiedEdits(jsonEncode(edits.toJson()));
  }

  /// Copies the edits of the saved project [projectId] (Home).
  Future<bool> copyFrom(String projectId) async {
    final project = await ref.read(projectRepositoryProvider).find(projectId);
    if (project == null) return false;
    await copy(project.edit.copyEdits());
    return true;
  }

  /// Applies the copied edits to the saved project [projectId] (Home) and
  /// redraws its thumbnail. Its crop, elements and trim stay.
  Future<bool> pasteInto(String projectId) async {
    final edits = state;
    if (edits == null) return false;
    final repository = ref.read(projectRepositoryProvider);
    final project = await repository.find(projectId);
    if (project == null) return false;
    final saved = await repository.save(
      project.copyWith(edit: project.edit.pasteEdits(edits)),
    );
    try {
      final id = edits.preset?.presetId;
      final catalog = await ref.read(catalogProvider.future);
      final preset = id == null ? null : catalog.presetById(id);
      await ref.read(projectThumbnailsProvider).refresh(saved, preset);
    } on Object catch (e) {
      debugPrint('Thumbnail for $projectId failed: $e');
    }
    return true;
  }
}
