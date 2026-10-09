// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaRef _$MediaRefFromJson(Map<String, dynamic> json) => _MediaRef(
  uri: json['uri'] as String,
  type: $enumDecode(_$MediaTypeEnumMap, json['type']),
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  durationMs: (json['durationMs'] as num?)?.toInt(),
);

Map<String, dynamic> _$MediaRefToJson(_MediaRef instance) => <String, dynamic>{
  'uri': instance.uri,
  'type': _$MediaTypeEnumMap[instance.type]!,
  'width': instance.width,
  'height': instance.height,
  'durationMs': instance.durationMs,
};

const _$MediaTypeEnumMap = {MediaType.photo: 'photo', MediaType.video: 'video'};

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: json['id'] as String,
  media: MediaRef.fromJson(json['media'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  edit: json['edit'] == null
      ? const EditState()
      : EditState.fromJson(json['edit'] as Map<String, dynamic>),
  name: json['name'] as String?,
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'media': instance.media.toJson(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'edit': instance.edit.toJson(),
  'name': instance.name,
};
