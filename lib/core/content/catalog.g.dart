// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PresetCollection _$PresetCollectionFromJson(Map<String, dynamic> json) =>
    _PresetCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
      isPremium: json['isPremium'] as bool? ?? false,
    );

Map<String, dynamic> _$PresetCollectionToJson(_PresetCollection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'order': instance.order,
      'isPremium': instance.isPremium,
    };

_ContentAsset _$ContentAssetFromJson(Map<String, dynamic> json) =>
    _ContentAsset(
      id: json['id'] as String,
      type: $enumDecode(_$ContentAssetTypeEnumMap, json['type']),
      name: json['name'] as String,
      file: json['file'] as String? ?? '',
      collectionId: json['collectionId'] as String?,
      thumbnail: json['thumbnail'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      version: (json['version'] as num?)?.toInt() ?? 1,
      params:
          json['params'] as Map<String, dynamic>? ?? const <String, Object?>{},
    );

Map<String, dynamic> _$ContentAssetToJson(_ContentAsset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ContentAssetTypeEnumMap[instance.type]!,
      'name': instance.name,
      'file': instance.file,
      'collectionId': instance.collectionId,
      'thumbnail': instance.thumbnail,
      'isPremium': instance.isPremium,
      'version': instance.version,
      'params': instance.params,
    };

const _$ContentAssetTypeEnumMap = {
  ContentAssetType.sticker: 'sticker',
  ContentAssetType.overlay: 'overlay',
  ContentAssetType.frame: 'frame',
  ContentAssetType.font: 'font',
};

_Catalog _$CatalogFromJson(Map<String, dynamic> json) => _Catalog(
  catalogVersion: (json['catalogVersion'] as num).toInt(),
  collections:
      (json['collections'] as List<dynamic>?)
          ?.map((e) => PresetCollection.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PresetCollection>[],
  presets:
      (json['presets'] as List<dynamic>?)
          ?.map((e) => Preset.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Preset>[],
  assets:
      (json['assets'] as List<dynamic>?)
          ?.map((e) => ContentAsset.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ContentAsset>[],
);

Map<String, dynamic> _$CatalogToJson(_Catalog instance) => <String, dynamic>{
  'catalogVersion': instance.catalogVersion,
  'collections': instance.collections.map((e) => e.toJson()).toList(),
  'presets': instance.presets.map((e) => e.toJson()).toList(),
  'assets': instance.assets.map((e) => e.toJson()).toList(),
};
