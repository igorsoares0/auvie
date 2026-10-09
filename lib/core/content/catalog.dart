import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog.freezed.dart';
part 'catalog.g.dart';

/// A group of presets and assets (spec §14), e.g. Film, Vintage, Night.
@freezed
abstract class PresetCollection with _$PresetCollection {
  const factory({
    required String id,
    required String name,
    String? description,
    @Default(0) int order,
    @Default(false) bool isPremium,
  }) = _PresetCollection;

  factory fromJson(Map<String, dynamic> json) =>
      _$PresetCollectionFromJson(json);
}

enum ContentAssetType { sticker, overlay, frame, font }

/// A file distributed as content (spec §44): stickers, overlays, frames,
/// fonts. [file] is an asset path when bundled, a URL when remote (M8).
@freezed
abstract class ContentAsset with _$ContentAsset {
  const factory({
    required String id,
    required ContentAssetType type,
    required String name,
    required String file,
    String? collectionId,
    String? thumbnail,
    @Default(false) bool isPremium,
    @Default(1) int version,
  }) = _ContentAsset;

  factory fromJson(Map<String, dynamic> json) => _$ContentAssetFromJson(json);
}

/// Everything the app can offer (spec §46–47).
@freezed
abstract class Catalog with _$Catalog {
  const factory({
    required int catalogVersion,
    @Default(<PresetCollection>[]) List<PresetCollection> collections,
    @Default(<Preset>[]) List<Preset> presets,
    @Default(<ContentAsset>[]) List<ContentAsset> assets,
  }) = _Catalog;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$CatalogFromJson(json);

  List<PresetCollection> get sortedCollections =>
      collections.sortedBy<num>((c) => c.order);

  Preset? presetById(String id) => presets.firstWhereOrNull((p) => p.id == id);

  List<Preset> presetsIn(String collectionId) => [
    for (final p in presets)
      if (p.collectionId == collectionId) p,
  ];

  ContentAsset? assetById(String id) =>
      assets.firstWhereOrNull((a) => a.id == id);

  List<ContentAsset> assetsOfType(ContentAssetType type) => [
    for (final a in assets)
      if (a.type == type) a,
  ];

  /// Problems that would break the app: duplicate ids, references to
  /// unknown collections, out-of-range settings. Empty when valid.
  List<String> validate() {
    final issues = <String>[];
    final collectionIds = collections.map((c) => c.id).toSet();

    void checkUnique(String what, Iterable<String> ids) {
      final seen = <String>{};
      for (final id in ids) {
        if (!seen.add(id)) issues.add('Duplicate $what id "$id"');
      }
    }

    checkUnique('collection', collections.map((c) => c.id));
    checkUnique('preset', presets.map((p) => p.id));
    checkUnique('asset', assets.map((a) => a.id));

    for (final preset in presets) {
      if (!collectionIds.contains(preset.collectionId)) {
        issues.add(
          'Preset "${preset.id}" is in unknown collection '
          '"${preset.collectionId}"',
        );
      }
    }
    for (final asset in assets) {
      final collectionId = asset.collectionId;
      if (collectionId != null && !collectionIds.contains(collectionId)) {
        issues.add(
          'Asset "${asset.id}" is in unknown collection "$collectionId"',
        );
      }
    }
    return issues;
  }
}

/// Raw preset settings outside their range are clamped by `Adjustments`;
/// this reports them so content authors notice (used by [Catalog] tests and,
/// later, the Admin).
List<String> outOfRangeSettings(Map<String, dynamic> rawSettings) => [
  for (final adjustment in Adjustment.values)
    if (rawSettings[adjustment.name] case final num v
        when v < adjustment.min || v > adjustment.max)
      '${adjustment.name}=$v',
];
