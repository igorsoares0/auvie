// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_timeline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VideoTimeline _$VideoTimelineFromJson(Map<String, dynamic> json) =>
    _VideoTimeline(
      trimStartMs: (json['trimStartMs'] as num?)?.toInt() ?? 0,
      trimEndMs: (json['trimEndMs'] as num?)?.toInt(),
      muted: json['muted'] as bool? ?? false,
    );

Map<String, dynamic> _$VideoTimelineToJson(_VideoTimeline instance) =>
    <String, dynamic>{
      'trimStartMs': instance.trimStartMs,
      'trimEndMs': instance.trimEndMs,
      'muted': instance.muted,
    };
