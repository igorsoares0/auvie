// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tone_curve.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurvePoint _$CurvePointFromJson(Map<String, dynamic> json) => _CurvePoint(
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
);

Map<String, dynamic> _$CurvePointToJson(_CurvePoint instance) =>
    <String, dynamic>{'x': instance.x, 'y': instance.y};

_ToneCurve _$ToneCurveFromJson(Map<String, dynamic> json) => _ToneCurve(
  points:
      (json['points'] as List<dynamic>?)
          ?.map((e) => CurvePoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CurvePoint>[CurvePoint(x: 0, y: 0), CurvePoint(x: 1, y: 1)],
);

Map<String, dynamic> _$ToneCurveToJson(_ToneCurve instance) =>
    <String, dynamic>{
      'points': instance.points.map((e) => e.toJson()).toList(),
    };

_ToneCurves _$ToneCurvesFromJson(Map<String, dynamic> json) => _ToneCurves(
  master: json['master'] == null
      ? const ToneCurve()
      : ToneCurve.fromJson(json['master'] as Map<String, dynamic>),
  red: json['red'] == null
      ? const ToneCurve()
      : ToneCurve.fromJson(json['red'] as Map<String, dynamic>),
  green: json['green'] == null
      ? const ToneCurve()
      : ToneCurve.fromJson(json['green'] as Map<String, dynamic>),
  blue: json['blue'] == null
      ? const ToneCurve()
      : ToneCurve.fromJson(json['blue'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ToneCurvesToJson(_ToneCurves instance) =>
    <String, dynamic>{
      'master': instance.master.toJson(),
      'red': instance.red.toJson(),
      'green': instance.green.toJson(),
      'blue': instance.blue.toJson(),
    };
