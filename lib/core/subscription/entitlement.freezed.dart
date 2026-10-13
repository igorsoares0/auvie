// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entitlement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Entitlement {

 bool get isPro; ProPeriod? get period; DateTime? get expiresAt; bool get inTrial;
/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntitlementCopyWith<Entitlement> get copyWith => _$EntitlementCopyWithImpl<Entitlement>(this as Entitlement, _$identity);

  /// Serializes this Entitlement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Entitlement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Entitlement&&(identical(other.isPro, _this.isPro) || other.isPro == _this.isPro)&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.inTrial, _this.inTrial) || other.inTrial == _this.inTrial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Entitlement;
  return Object.hash(runtimeType,_this.isPro,_this.period,_this.expiresAt,_this.inTrial);
}

@override
String toString() {
  final _this = this as Entitlement;
  return 'Entitlement(isPro: ${_this.isPro}, period: ${_this.period}, expiresAt: ${_this.expiresAt}, inTrial: ${_this.inTrial})';
}


}

/// @nodoc
abstract mixin class $EntitlementCopyWith<$Res>  {
  factory $EntitlementCopyWith(Entitlement value, $Res Function(Entitlement) _then) = _$EntitlementCopyWithImpl;
@useResult
$Res call({
 bool isPro, ProPeriod? period, DateTime? expiresAt, bool inTrial
});




}
/// @nodoc
class _$EntitlementCopyWithImpl<$Res>
    implements $EntitlementCopyWith<$Res> {
  _$EntitlementCopyWithImpl(this._self, this._then);

  final Entitlement _self;
  final $Res Function(Entitlement) _then;

/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isPro = null,Object? period = freezed,Object? expiresAt = freezed,Object? inTrial = null,}) {
  return _then(Entitlement(
isPro: null == isPro ? _self.isPro : isPro // ignore: cast_nullable_to_non_nullable
as bool,period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ProPeriod?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,inTrial: null == inTrial ? _self.inTrial : inTrial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Entitlement].
extension EntitlementPatterns on Entitlement {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Entitlement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Entitlement() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Entitlement value)  $default,){
final _that = this;
switch (_that) {
case _Entitlement():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Entitlement value)?  $default,){
final _that = this;
switch (_that) {
case _Entitlement() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isPro,  ProPeriod? period,  DateTime? expiresAt,  bool inTrial)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Entitlement() when $default != null:
return $default(_that.isPro,_that.period,_that.expiresAt,_that.inTrial);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isPro,  ProPeriod? period,  DateTime? expiresAt,  bool inTrial)  $default,) {final _that = this;
switch (_that) {
case _Entitlement():
return $default(_that.isPro,_that.period,_that.expiresAt,_that.inTrial);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isPro,  ProPeriod? period,  DateTime? expiresAt,  bool inTrial)?  $default,) {final _that = this;
switch (_that) {
case _Entitlement() when $default != null:
return $default(_that.isPro,_that.period,_that.expiresAt,_that.inTrial);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Entitlement implements Entitlement {
  const _Entitlement({this.isPro = false, this.period, this.expiresAt, this.inTrial = false});
  factory _Entitlement.fromJson(Map<String, dynamic> json) => _$EntitlementFromJson(json);

@override@JsonKey() final  bool isPro;
@override final  ProPeriod? period;
@override final  DateTime? expiresAt;
@override@JsonKey() final  bool inTrial;

/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntitlementCopyWith<_Entitlement> get copyWith => __$EntitlementCopyWithImpl<_Entitlement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntitlementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Entitlement&&(identical(other.isPro, isPro) || other.isPro == isPro)&&(identical(other.period, period) || other.period == period)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.inTrial, inTrial) || other.inTrial == inTrial));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,isPro,period,expiresAt,inTrial);
}

@override
String toString() {
    return 'Entitlement(isPro: $isPro, period: $period, expiresAt: $expiresAt, inTrial: $inTrial)';
}


}

/// @nodoc
abstract mixin class _$EntitlementCopyWith<$Res> implements $EntitlementCopyWith<$Res> {
  factory _$EntitlementCopyWith(_Entitlement value, $Res Function(_Entitlement) _then) = __$EntitlementCopyWithImpl;
@override @useResult
$Res call({
 bool isPro, ProPeriod? period, DateTime? expiresAt, bool inTrial
});




}
/// @nodoc
class __$EntitlementCopyWithImpl<$Res>
    implements _$EntitlementCopyWith<$Res> {
  __$EntitlementCopyWithImpl(this._self, this._then);

  final _Entitlement _self;
  final $Res Function(_Entitlement) _then;

/// Create a copy of Entitlement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isPro = null,Object? period = freezed,Object? expiresAt = freezed,Object? inTrial = null,}) {
  return _then(_Entitlement(
isPro: null == isPro ? _self.isPro : isPro // ignore: cast_nullable_to_non_nullable
as bool,period: freezed == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ProPeriod?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,inTrial: null == inTrial ? _self.inTrial : inTrial // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ProPlan {

/// Store package id, used to buy it.
 String get id; ProPeriod get period;/// "$39.99", formatted by the store in the user's currency.
 String get price;/// [price] as a number, to compare plans.
 double get amount;/// "$3.33" for yearly plans, when the store provides it.
 String? get pricePerMonth;/// Free days before the first charge, if the plan has a trial.
 int? get trialDays;
/// Create a copy of ProPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProPlanCopyWith<ProPlan> get copyWith => _$ProPlanCopyWithImpl<ProPlan>(this as ProPlan, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ProPlan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProPlan&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.period, _this.period) || other.period == _this.period)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.pricePerMonth, _this.pricePerMonth) || other.pricePerMonth == _this.pricePerMonth)&&(identical(other.trialDays, _this.trialDays) || other.trialDays == _this.trialDays));
}


@override
int get hashCode {
  final _this = this as ProPlan;
  return Object.hash(runtimeType,_this.id,_this.period,_this.price,_this.amount,_this.pricePerMonth,_this.trialDays);
}

@override
String toString() {
  final _this = this as ProPlan;
  return 'ProPlan(id: ${_this.id}, period: ${_this.period}, price: ${_this.price}, amount: ${_this.amount}, pricePerMonth: ${_this.pricePerMonth}, trialDays: ${_this.trialDays})';
}


}

/// @nodoc
abstract mixin class $ProPlanCopyWith<$Res>  {
  factory $ProPlanCopyWith(ProPlan value, $Res Function(ProPlan) _then) = _$ProPlanCopyWithImpl;
@useResult
$Res call({
 String id, ProPeriod period, String price, double amount, String? pricePerMonth, int? trialDays
});




}
/// @nodoc
class _$ProPlanCopyWithImpl<$Res>
    implements $ProPlanCopyWith<$Res> {
  _$ProPlanCopyWithImpl(this._self, this._then);

  final ProPlan _self;
  final $Res Function(ProPlan) _then;

/// Create a copy of ProPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? period = null,Object? price = null,Object? amount = null,Object? pricePerMonth = freezed,Object? trialDays = freezed,}) {
  return _then(ProPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ProPeriod,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,pricePerMonth: freezed == pricePerMonth ? _self.pricePerMonth : pricePerMonth // ignore: cast_nullable_to_non_nullable
as String?,trialDays: freezed == trialDays ? _self.trialDays : trialDays // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProPlan].
extension ProPlanPatterns on ProPlan {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProPlan() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProPlan value)  $default,){
final _that = this;
switch (_that) {
case _ProPlan():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProPlan value)?  $default,){
final _that = this;
switch (_that) {
case _ProPlan() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ProPeriod period,  String price,  double amount,  String? pricePerMonth,  int? trialDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProPlan() when $default != null:
return $default(_that.id,_that.period,_that.price,_that.amount,_that.pricePerMonth,_that.trialDays);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ProPeriod period,  String price,  double amount,  String? pricePerMonth,  int? trialDays)  $default,) {final _that = this;
switch (_that) {
case _ProPlan():
return $default(_that.id,_that.period,_that.price,_that.amount,_that.pricePerMonth,_that.trialDays);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ProPeriod period,  String price,  double amount,  String? pricePerMonth,  int? trialDays)?  $default,) {final _that = this;
switch (_that) {
case _ProPlan() when $default != null:
return $default(_that.id,_that.period,_that.price,_that.amount,_that.pricePerMonth,_that.trialDays);case _:
  return null;

}
}

}

/// @nodoc


class _ProPlan implements ProPlan {
  const _ProPlan({required this.id, required this.period, required this.price, required this.amount, this.pricePerMonth, this.trialDays});
  

/// Store package id, used to buy it.
@override final  String id;
@override final  ProPeriod period;
/// "$39.99", formatted by the store in the user's currency.
@override final  String price;
/// [price] as a number, to compare plans.
@override final  double amount;
/// "$3.33" for yearly plans, when the store provides it.
@override final  String? pricePerMonth;
/// Free days before the first charge, if the plan has a trial.
@override final  int? trialDays;

/// Create a copy of ProPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProPlanCopyWith<_ProPlan> get copyWith => __$ProPlanCopyWithImpl<_ProPlan>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.period, period) || other.period == period)&&(identical(other.price, price) || other.price == price)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.pricePerMonth, pricePerMonth) || other.pricePerMonth == pricePerMonth)&&(identical(other.trialDays, trialDays) || other.trialDays == trialDays));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,period,price,amount,pricePerMonth,trialDays);
}

@override
String toString() {
    return 'ProPlan(id: $id, period: $period, price: $price, amount: $amount, pricePerMonth: $pricePerMonth, trialDays: $trialDays)';
}


}

/// @nodoc
abstract mixin class _$ProPlanCopyWith<$Res> implements $ProPlanCopyWith<$Res> {
  factory _$ProPlanCopyWith(_ProPlan value, $Res Function(_ProPlan) _then) = __$ProPlanCopyWithImpl;
@override @useResult
$Res call({
 String id, ProPeriod period, String price, double amount, String? pricePerMonth, int? trialDays
});




}
/// @nodoc
class __$ProPlanCopyWithImpl<$Res>
    implements _$ProPlanCopyWith<$Res> {
  __$ProPlanCopyWithImpl(this._self, this._then);

  final _ProPlan _self;
  final $Res Function(_ProPlan) _then;

/// Create a copy of ProPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? period = null,Object? price = null,Object? amount = null,Object? pricePerMonth = freezed,Object? trialDays = freezed,}) {
  return _then(_ProPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as ProPeriod,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,pricePerMonth: freezed == pricePerMonth ? _self.pricePerMonth : pricePerMonth // ignore: cast_nullable_to_non_nullable
as String?,trialDays: freezed == trialDays ? _self.trialDays : trialDays // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
