import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/elements.dart';

/// What kind of Pro content an edit uses.
enum PremiumKind { preset, sticker, overlay, frame }

/// One piece of Pro content in an edit, named as the catalog names it.
typedef PremiumItem = ({PremiumKind kind, String id, String name});

/// The Pro content [edit] uses (spec §50): its preset and its stickers,
/// overlays and frames. Text and brush are never Pro. Content missing from
/// [catalog] doesn't count, so a removed item never locks an export. Each
/// item is listed once, preset first.
List<PremiumItem> premiumContent(EditState edit, Catalog catalog) {
  final items = <PremiumItem>[];
  final seen = <String>{};

  void add(PremiumKind kind, String id, String name) {
    if (seen.add('${kind.name}:$id')) {
      items.add((kind: kind, id: id, name: name));
    }
  }

  final presetId = edit.preset?.presetId;
  final preset = presetId == null ? null : catalog.presetById(presetId);
  if (preset != null && preset.isPremium) {
    add(PremiumKind.preset, preset.id, preset.name);
  }
  for (final element in edit.elements) {
    final (kind, assetId) = switch (element) {
      StickerElement(:final assetId) => (PremiumKind.sticker, assetId),
      OverlayElement(:final assetId) => (PremiumKind.overlay, assetId),
      FrameElement(:final assetId) => (PremiumKind.frame, assetId),
      TextElement() || TextPathElement() || BrushElement() => (null, null),
    };
    if (kind == null || assetId == null) continue;
    final asset = catalog.assetById(assetId);
    if (asset != null && asset.isPremium) add(kind, asset.id, asset.name);
  }
  return items;
}
