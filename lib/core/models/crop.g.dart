// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NormalizedRect _$NormalizedRectFromJson(Map<String, dynamic> json) =>
    _NormalizedRect(
      left: (json['left'] as num?)?.toDouble() ?? 0,
      top: (json['top'] as num?)?.toDouble() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? 1,
      height: (json['height'] as num?)?.toDouble() ?? 1,
    );

Map<String, dynamic> _$NormalizedRectToJson(_NormalizedRect instance) =>
    <String, dynamic>{
      'left': instance.left,
      'top': instance.top,
      'width': instance.width,
      'height': instance.height,
    };

_CropTransform _$CropTransformFromJson(Map<String, dynamic> json) =>
    _CropTransform(
      aspect:
          $enumDecodeNullable(_$CropAspectEnumMap, json['aspect']) ??
          CropAspect.original,
      rect: json['rect'] == null
          ? NormalizedRect.full
          : NormalizedRect.fromJson(json['rect'] as Map<String, dynamic>),
      quarterTurns: (json['quarterTurns'] as num?)?.toInt() ?? 0,
      straighten: (json['straighten'] as num?)?.toDouble() ?? 0,
      flipHorizontal: json['flipHorizontal'] as bool? ?? false,
      flipVertical: json['flipVertical'] as bool? ?? false,
    );

Map<String, dynamic> _$CropTransformToJson(_CropTransform instance) =>
    <String, dynamic>{
      'aspect': _$CropAspectEnumMap[instance.aspect]!,
      'rect': instance.rect.toJson(),
      'quarterTurns': instance.quarterTurns,
      'straighten': instance.straighten,
      'flipHorizontal': instance.flipHorizontal,
      'flipVertical': instance.flipVertical,
    };

const _$CropAspectEnumMap = {
  CropAspect.original: 'original',
  CropAspect.square: 'square',
  CropAspect.portrait4x5: 'portrait4x5',
  CropAspect.portrait3x4: 'portrait3x4',
  CropAspect.story9x16: 'story9x16',
  CropAspect.landscape16x9: 'landscape16x9',
};
