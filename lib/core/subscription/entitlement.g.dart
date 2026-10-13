// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Entitlement _$EntitlementFromJson(Map<String, dynamic> json) => _Entitlement(
  isPro: json['isPro'] as bool? ?? false,
  period: $enumDecodeNullable(_$ProPeriodEnumMap, json['period']),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  inTrial: json['inTrial'] as bool? ?? false,
);

Map<String, dynamic> _$EntitlementToJson(_Entitlement instance) =>
    <String, dynamic>{
      'isPro': instance.isPro,
      'period': _$ProPeriodEnumMap[instance.period],
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'inTrial': instance.inTrial,
    };

const _$ProPeriodEnumMap = {
  ProPeriod.monthly: 'monthly',
  ProPeriod.yearly: 'yearly',
};
