import 'dart:typed_data';

import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:auvie/core/native/render_params.dart';
import 'package:auvie/core/storage/database.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'preset_providers.g.dart';

/// Longer side of a preset card preview: 90 pt at 3x.
const presetThumbnailPx = 270;

/// The user's photo developed with [presetId] at full intensity (null:
/// the original). Kept while a card shows it.
@riverpod
Future<Uint8List> presetThumbnail(Ref ref, String uri, String? presetId) async {
  final catalog = await ref.watch(catalogProvider.future);
  final preset = presetId == null ? null : catalog.presetById(presetId);
  final edit = preset == null
      ? const EditState()
      : const EditState().withPreset(preset.id);
  return await ref
      .watch(mediaEngineProvider)
      .renderPhoto(
        uri,
        RenderParams.fromEdit(edit, preset),
        maxPx: presetThumbnailPx,
      );
}

/// Preset ids saved as favorites (FILM → SAVED), newest first.
@riverpod
Stream<List<String>> favoritePresets(Ref ref) =>
    ref.watch(favoritesRepositoryProvider).watch(FavoriteKind.preset);
