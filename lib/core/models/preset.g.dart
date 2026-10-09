// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ToneStrip _$ToneStripFromJson(Map<String, dynamic> json) => _ToneStrip(
  highlight: const HexColorConverter().fromJson(json['highlight'] as String),
  mid: const HexColorConverter().fromJson(json['mid'] as String),
  shadow: const HexColorConverter().fromJson(json['shadow'] as String),
);

Map<String, dynamic> _$ToneStripToJson(_ToneStrip instance) =>
    <String, dynamic>{
      'highlight': const HexColorConverter().toJson(instance.highlight),
      'mid': const HexColorConverter().toJson(instance.mid),
      'shadow': const HexColorConverter().toJson(instance.shadow),
    };

_Preset _$PresetFromJson(Map<String, dynamic> json) => _Preset(
  id: json['id'] as String,
  name: json['name'] as String,
  collectionId: json['collectionId'] as String,
  version: (json['version'] as num?)?.toInt() ?? 1,
  isPremium: json['isPremium'] as bool? ?? false,
  settings: json['settings'] == null
      ? const Adjustments()
      : Adjustments.fromJson(json['settings'] as Map<String, dynamic>),
  curves: json['curves'] == null
      ? null
      : ToneCurves.fromJson(json['curves'] as Map<String, dynamic>),
  tone: json['tone'] == null
      ? null
      : ToneStrip.fromJson(json['tone'] as Map<String, dynamic>),
  stock: json['stock'] as String?,
  iso: (json['iso'] as num?)?.toInt(),
  description: json['description'] as String?,
);

Map<String, dynamic> _$PresetToJson(_Preset instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'collectionId': instance.collectionId,
  'version': instance.version,
  'isPremium': instance.isPremium,
  'settings': instance.settings.toJson(),
  'curves': instance.curves?.toJson(),
  'tone': instance.tone?.toJson(),
  'stock': instance.stock,
  'iso': instance.iso,
  'description': instance.description,
};

_PresetRef _$PresetRefFromJson(Map<String, dynamic> json) => _PresetRef(
  presetId: json['presetId'] as String,
  intensity: (json['intensity'] as num?)?.toDouble() ?? 1,
);

Map<String, dynamic> _$PresetRefToJson(_PresetRef instance) =>
    <String, dynamic>{
      'presetId': instance.presetId,
      'intensity': instance.intensity,
    };
