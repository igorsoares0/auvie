// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EditState _$EditStateFromJson(Map<String, dynamic> json) => _EditState(
  adjustments: json['adjustments'] == null
      ? const Adjustments()
      : Adjustments.fromJson(json['adjustments'] as Map<String, dynamic>),
  curves: json['curves'] == null
      ? const ToneCurves()
      : ToneCurves.fromJson(json['curves'] as Map<String, dynamic>),
  preset: json['preset'] == null
      ? null
      : PresetRef.fromJson(json['preset'] as Map<String, dynamic>),
  crop: json['crop'] == null
      ? const CropTransform()
      : CropTransform.fromJson(json['crop'] as Map<String, dynamic>),
  elements:
      (json['elements'] as List<dynamic>?)
          ?.map((e) => EditElement.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <EditElement>[],
  video: json['video'] == null
      ? null
      : VideoTimeline.fromJson(json['video'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EditStateToJson(_EditState instance) =>
    <String, dynamic>{
      'adjustments': instance.adjustments.toJson(),
      'curves': instance.curves.toJson(),
      'preset': instance.preset?.toJson(),
      'crop': instance.crop.toJson(),
      'elements': instance.elements.map((e) => e.toJson()).toList(),
      'video': instance.video?.toJson(),
    };

_CopiedEdits _$CopiedEditsFromJson(Map<String, dynamic> json) => _CopiedEdits(
  adjustments: json['adjustments'] == null
      ? const Adjustments()
      : Adjustments.fromJson(json['adjustments'] as Map<String, dynamic>),
  curves: json['curves'] == null
      ? const ToneCurves()
      : ToneCurves.fromJson(json['curves'] as Map<String, dynamic>),
  preset: json['preset'] == null
      ? null
      : PresetRef.fromJson(json['preset'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CopiedEditsToJson(_CopiedEdits instance) =>
    <String, dynamic>{
      'adjustments': instance.adjustments.toJson(),
      'curves': instance.curves.toJson(),
      'preset': instance.preset?.toJson(),
    };
