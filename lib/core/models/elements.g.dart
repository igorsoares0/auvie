// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elements.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ElementTransform _$ElementTransformFromJson(Map<String, dynamic> json) =>
    _ElementTransform(
      x: (json['x'] as num?)?.toDouble() ?? 0.5,
      y: (json['y'] as num?)?.toDouble() ?? 0.5,
      scale: (json['scale'] as num?)?.toDouble() ?? 1,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$ElementTransformToJson(_ElementTransform instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'scale': instance.scale,
      'rotation': instance.rotation,
    };

_TimeRange _$TimeRangeFromJson(Map<String, dynamic> json) => _TimeRange(
  startMs: (json['startMs'] as num).toInt(),
  endMs: (json['endMs'] as num).toInt(),
);

Map<String, dynamic> _$TimeRangeToJson(_TimeRange instance) =>
    <String, dynamic>{'startMs': instance.startMs, 'endMs': instance.endMs};

_TextShadowSpec _$TextShadowSpecFromJson(Map<String, dynamic> json) =>
    _TextShadowSpec(
      color: (json['color'] as num?)?.toInt() ?? 0x66000000,
      blur: (json['blur'] as num?)?.toDouble() ?? 0.01,
      dx: (json['dx'] as num?)?.toDouble() ?? 0,
      dy: (json['dy'] as num?)?.toDouble() ?? 0.004,
    );

Map<String, dynamic> _$TextShadowSpecToJson(_TextShadowSpec instance) =>
    <String, dynamic>{
      'color': instance.color,
      'blur': instance.blur,
      'dx': instance.dx,
      'dy': instance.dy,
    };

_TextOutlineSpec _$TextOutlineSpecFromJson(Map<String, dynamic> json) =>
    _TextOutlineSpec(
      color: (json['color'] as num?)?.toInt() ?? 0xFF161412,
      width: (json['width'] as num?)?.toDouble() ?? 0.003,
    );

Map<String, dynamic> _$TextOutlineSpecToJson(_TextOutlineSpec instance) =>
    <String, dynamic>{'color': instance.color, 'width': instance.width};

_TextBackgroundSpec _$TextBackgroundSpecFromJson(Map<String, dynamic> json) =>
    _TextBackgroundSpec(
      color: (json['color'] as num?)?.toInt() ?? 0xFFEFE8DC,
      padding: (json['padding'] as num?)?.toDouble() ?? 0.01,
    );

Map<String, dynamic> _$TextBackgroundSpecToJson(_TextBackgroundSpec instance) =>
    <String, dynamic>{'color': instance.color, 'padding': instance.padding};

_TextStyleSpec _$TextStyleSpecFromJson(Map<String, dynamic> json) =>
    _TextStyleSpec(
      fontFamily: json['fontFamily'] as String? ?? 'Newsreader',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 0.06,
      fontWeight: (json['fontWeight'] as num?)?.toInt() ?? 400,
      italic: json['italic'] as bool? ?? false,
      align:
          $enumDecodeNullable(_$TextAlignmentEnumMap, json['align']) ??
          TextAlignment.center,
      color: (json['color'] as num?)?.toInt() ?? 0xFFEFE8DC,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.2,
      shadow: json['shadow'] == null
          ? null
          : TextShadowSpec.fromJson(json['shadow'] as Map<String, dynamic>),
      outline: json['outline'] == null
          ? null
          : TextOutlineSpec.fromJson(json['outline'] as Map<String, dynamic>),
      background: json['background'] == null
          ? null
          : TextBackgroundSpec.fromJson(
              json['background'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$TextStyleSpecToJson(_TextStyleSpec instance) =>
    <String, dynamic>{
      'fontFamily': instance.fontFamily,
      'fontSize': instance.fontSize,
      'fontWeight': instance.fontWeight,
      'italic': instance.italic,
      'align': _$TextAlignmentEnumMap[instance.align]!,
      'color': instance.color,
      'letterSpacing': instance.letterSpacing,
      'lineHeight': instance.lineHeight,
      'shadow': instance.shadow?.toJson(),
      'outline': instance.outline?.toJson(),
      'background': instance.background?.toJson(),
    };

const _$TextAlignmentEnumMap = {
  TextAlignment.left: 'left',
  TextAlignment.center: 'center',
  TextAlignment.right: 'right',
};

_StrokePoint _$StrokePointFromJson(Map<String, dynamic> json) => _StrokePoint(
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  pressure: (json['pressure'] as num?)?.toDouble(),
);

Map<String, dynamic> _$StrokePointToJson(_StrokePoint instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'pressure': instance.pressure,
    };

_BrushStroke _$BrushStrokeFromJson(Map<String, dynamic> json) => _BrushStroke(
  points:
      (json['points'] as List<dynamic>?)
          ?.map((e) => StrokePoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <StrokePoint>[],
);

Map<String, dynamic> _$BrushStrokeToJson(_BrushStroke instance) =>
    <String, dynamic>{
      'points': instance.points.map((e) => e.toJson()).toList(),
    };

TextElement _$TextElementFromJson(Map<String, dynamic> json) => TextElement(
  id: json['id'] as String,
  text: json['text'] as String,
  style: json['style'] == null
      ? const TextStyleSpec()
      : TextStyleSpec.fromJson(json['style'] as Map<String, dynamic>),
  textPresetId: json['textPresetId'] as String?,
  transform: json['transform'] == null
      ? const ElementTransform()
      : ElementTransform.fromJson(json['transform'] as Map<String, dynamic>),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
  time: json['time'] == null
      ? null
      : TimeRange.fromJson(json['time'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$TextElementToJson(TextElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'style': instance.style.toJson(),
      'textPresetId': instance.textPresetId,
      'transform': instance.transform.toJson(),
      'opacity': instance.opacity,
      'time': instance.time?.toJson(),
      'type': instance.$type,
    };

TextPathElement _$TextPathElementFromJson(Map<String, dynamic> json) =>
    TextPathElement(
      id: json['id'] as String,
      text: json['text'] as String,
      path: (json['path'] as List<dynamic>)
          .map((e) => StrokePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      style: json['style'] == null
          ? const TextStyleSpec()
          : TextStyleSpec.fromJson(json['style'] as Map<String, dynamic>),
      transform: json['transform'] == null
          ? const ElementTransform()
          : ElementTransform.fromJson(
              json['transform'] as Map<String, dynamic>,
            ),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
      time: json['time'] == null
          ? null
          : TimeRange.fromJson(json['time'] as Map<String, dynamic>),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$TextPathElementToJson(TextPathElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'path': instance.path.map((e) => e.toJson()).toList(),
      'style': instance.style.toJson(),
      'transform': instance.transform.toJson(),
      'opacity': instance.opacity,
      'time': instance.time?.toJson(),
      'type': instance.$type,
    };

BrushElement _$BrushElementFromJson(Map<String, dynamic> json) => BrushElement(
  id: json['id'] as String,
  brushType:
      $enumDecodeNullable(_$BrushTypeEnumMap, json['brushType']) ??
      BrushType.pen,
  size: (json['size'] as num?)?.toDouble() ?? 0.01,
  color: (json['color'] as num?)?.toInt() ?? 0xFFEFE8DC,
  smoothing: (json['smoothing'] as num?)?.toDouble() ?? 0.5,
  strokes:
      (json['strokes'] as List<dynamic>?)
          ?.map((e) => BrushStroke.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <BrushStroke>[],
  transform: json['transform'] == null
      ? const ElementTransform()
      : ElementTransform.fromJson(json['transform'] as Map<String, dynamic>),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
  time: json['time'] == null
      ? null
      : TimeRange.fromJson(json['time'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$BrushElementToJson(BrushElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brushType': _$BrushTypeEnumMap[instance.brushType]!,
      'size': instance.size,
      'color': instance.color,
      'smoothing': instance.smoothing,
      'strokes': instance.strokes.map((e) => e.toJson()).toList(),
      'transform': instance.transform.toJson(),
      'opacity': instance.opacity,
      'time': instance.time?.toJson(),
      'type': instance.$type,
    };

const _$BrushTypeEnumMap = {
  BrushType.pen: 'pen',
  BrushType.marker: 'marker',
  BrushType.pencil: 'pencil',
  BrushType.chalk: 'chalk',
  BrushType.paint: 'paint',
  BrushType.highlighter: 'highlighter',
};

StickerElement _$StickerElementFromJson(Map<String, dynamic> json) =>
    StickerElement(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      transform: json['transform'] == null
          ? const ElementTransform()
          : ElementTransform.fromJson(
              json['transform'] as Map<String, dynamic>,
            ),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
      time: json['time'] == null
          ? null
          : TimeRange.fromJson(json['time'] as Map<String, dynamic>),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$StickerElementToJson(StickerElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assetId': instance.assetId,
      'transform': instance.transform.toJson(),
      'opacity': instance.opacity,
      'time': instance.time?.toJson(),
      'type': instance.$type,
    };

OverlayElement _$OverlayElementFromJson(Map<String, dynamic> json) =>
    OverlayElement(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      blend:
          $enumDecodeNullable(_$OverlayBlendEnumMap, json['blend']) ??
          OverlayBlend.screen,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
      time: json['time'] == null
          ? null
          : TimeRange.fromJson(json['time'] as Map<String, dynamic>),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$OverlayElementToJson(OverlayElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assetId': instance.assetId,
      'blend': _$OverlayBlendEnumMap[instance.blend]!,
      'opacity': instance.opacity,
      'time': instance.time?.toJson(),
      'type': instance.$type,
    };

const _$OverlayBlendEnumMap = {
  OverlayBlend.screen: 'screen',
  OverlayBlend.multiply: 'multiply',
  OverlayBlend.overlay: 'overlay',
  OverlayBlend.softLight: 'softLight',
};

FrameElement _$FrameElementFromJson(Map<String, dynamic> json) => FrameElement(
  id: json['id'] as String,
  assetId: json['assetId'] as String,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FrameElementToJson(FrameElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assetId': instance.assetId,
      'type': instance.$type,
    };
