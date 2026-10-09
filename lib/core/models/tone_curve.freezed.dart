// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tone_curve.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CurvePoint {

 double get x; double get y;
/// Create a copy of CurvePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurvePointCopyWith<CurvePoint> get copyWith => _$CurvePointCopyWithImpl<CurvePoint>(this as CurvePoint, _$identity);

  /// Serializes this CurvePoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CurvePoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurvePoint&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.y, _this.y) || other.y == _this.y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CurvePoint;
  return Object.hash(runtimeType,_this.x,_this.y);
}

@override
String toString() {
  final _this = this as CurvePoint;
  return 'CurvePoint(x: ${_this.x}, y: ${_this.y})';
}


}

/// @nodoc
abstract mixin class $CurvePointCopyWith<$Res>  {
  factory $CurvePointCopyWith(CurvePoint value, $Res Function(CurvePoint) _then) = _$CurvePointCopyWithImpl;
@useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class _$CurvePointCopyWithImpl<$Res>
    implements $CurvePointCopyWith<$Res> {
  _$CurvePointCopyWithImpl(this._self, this._then);

  final CurvePoint _self;
  final $Res Function(CurvePoint) _then;

/// Create a copy of CurvePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,}) {
  return _then(CurvePoint(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CurvePoint].
extension CurvePointPatterns on CurvePoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurvePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurvePoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurvePoint value)  $default,){
final _that = this;
switch (_that) {
case _CurvePoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurvePoint value)?  $default,){
final _that = this;
switch (_that) {
case _CurvePoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double y)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurvePoint() when $default != null:
return $default(_that.x,_that.y);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double y)  $default,) {final _that = this;
switch (_that) {
case _CurvePoint():
return $default(_that.x,_that.y);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double y)?  $default,) {final _that = this;
switch (_that) {
case _CurvePoint() when $default != null:
return $default(_that.x,_that.y);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurvePoint implements CurvePoint {
  const _CurvePoint({required this.x, required this.y});
  factory _CurvePoint.fromJson(Map<String, dynamic> json) => _$CurvePointFromJson(json);

@override final  double x;
@override final  double y;

/// Create a copy of CurvePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurvePointCopyWith<_CurvePoint> get copyWith => __$CurvePointCopyWithImpl<_CurvePoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurvePointToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurvePoint&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,x,y);
}

@override
String toString() {
    return 'CurvePoint(x: $x, y: $y)';
}


}

/// @nodoc
abstract mixin class _$CurvePointCopyWith<$Res> implements $CurvePointCopyWith<$Res> {
  factory _$CurvePointCopyWith(_CurvePoint value, $Res Function(_CurvePoint) _then) = __$CurvePointCopyWithImpl;
@override @useResult
$Res call({
 double x, double y
});




}
/// @nodoc
class __$CurvePointCopyWithImpl<$Res>
    implements _$CurvePointCopyWith<$Res> {
  __$CurvePointCopyWithImpl(this._self, this._then);

  final _CurvePoint _self;
  final $Res Function(_CurvePoint) _then;

/// Create a copy of CurvePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,}) {
  return _then(_CurvePoint(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ToneCurve {

 List<CurvePoint> get points;
/// Create a copy of ToneCurve
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToneCurveCopyWith<ToneCurve> get copyWith => _$ToneCurveCopyWithImpl<ToneCurve>(this as ToneCurve, _$identity);

  /// Serializes this ToneCurve to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ToneCurve;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToneCurve&&const DeepCollectionEquality().equals(other.points, _this.points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ToneCurve;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.points));
}

@override
String toString() {
  final _this = this as ToneCurve;
  return 'ToneCurve(points: ${_this.points})';
}


}

/// @nodoc
abstract mixin class $ToneCurveCopyWith<$Res>  {
  factory $ToneCurveCopyWith(ToneCurve value, $Res Function(ToneCurve) _then) = _$ToneCurveCopyWithImpl;
@useResult
$Res call({
 List<CurvePoint> points
});




}
/// @nodoc
class _$ToneCurveCopyWithImpl<$Res>
    implements $ToneCurveCopyWith<$Res> {
  _$ToneCurveCopyWithImpl(this._self, this._then);

  final ToneCurve _self;
  final $Res Function(ToneCurve) _then;

/// Create a copy of ToneCurve
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? points = null,}) {
  return _then(ToneCurve(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<CurvePoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [ToneCurve].
extension ToneCurvePatterns on ToneCurve {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToneCurve value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToneCurve() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToneCurve value)  $default,){
final _that = this;
switch (_that) {
case _ToneCurve():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToneCurve value)?  $default,){
final _that = this;
switch (_that) {
case _ToneCurve() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CurvePoint> points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToneCurve() when $default != null:
return $default(_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CurvePoint> points)  $default,) {final _that = this;
switch (_that) {
case _ToneCurve():
return $default(_that.points);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CurvePoint> points)?  $default,) {final _that = this;
switch (_that) {
case _ToneCurve() when $default != null:
return $default(_that.points);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ToneCurve extends ToneCurve {
  const _ToneCurve({ List<CurvePoint> points = const <CurvePoint>[CurvePoint(x: 0, y: 0), CurvePoint(x: 1, y: 1)]}): _points = points,super._();
  factory _ToneCurve.fromJson(Map<String, dynamic> json) => _$ToneCurveFromJson(json);

 final  List<CurvePoint> _points;
@override@JsonKey() List<CurvePoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


/// Create a copy of ToneCurve
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToneCurveCopyWith<_ToneCurve> get copyWith => __$ToneCurveCopyWithImpl<_ToneCurve>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ToneCurveToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToneCurve&&const DeepCollectionEquality().equals(other.points, _points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_points));
}

@override
String toString() {
    return 'ToneCurve(points: $points)';
}


}

/// @nodoc
abstract mixin class _$ToneCurveCopyWith<$Res> implements $ToneCurveCopyWith<$Res> {
  factory _$ToneCurveCopyWith(_ToneCurve value, $Res Function(_ToneCurve) _then) = __$ToneCurveCopyWithImpl;
@override @useResult
$Res call({
 List<CurvePoint> points
});




}
/// @nodoc
class __$ToneCurveCopyWithImpl<$Res>
    implements _$ToneCurveCopyWith<$Res> {
  __$ToneCurveCopyWithImpl(this._self, this._then);

  final _ToneCurve _self;
  final $Res Function(_ToneCurve) _then;

/// Create a copy of ToneCurve
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? points = null,}) {
  return _then(_ToneCurve(
points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<CurvePoint>,
  ));
}


}


/// @nodoc
mixin _$ToneCurves {

 ToneCurve get master; ToneCurve get red; ToneCurve get green; ToneCurve get blue;
/// Create a copy of ToneCurves
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToneCurvesCopyWith<ToneCurves> get copyWith => _$ToneCurvesCopyWithImpl<ToneCurves>(this as ToneCurves, _$identity);

  /// Serializes this ToneCurves to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ToneCurves;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToneCurves&&(identical(other.master, _this.master) || other.master == _this.master)&&(identical(other.red, _this.red) || other.red == _this.red)&&(identical(other.green, _this.green) || other.green == _this.green)&&(identical(other.blue, _this.blue) || other.blue == _this.blue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ToneCurves;
  return Object.hash(runtimeType,_this.master,_this.red,_this.green,_this.blue);
}

@override
String toString() {
  final _this = this as ToneCurves;
  return 'ToneCurves(master: ${_this.master}, red: ${_this.red}, green: ${_this.green}, blue: ${_this.blue})';
}


}

/// @nodoc
abstract mixin class $ToneCurvesCopyWith<$Res>  {
  factory $ToneCurvesCopyWith(ToneCurves value, $Res Function(ToneCurves) _then) = _$ToneCurvesCopyWithImpl;
@useResult
$Res call({
 ToneCurve master, ToneCurve red, ToneCurve green, ToneCurve blue
});


$ToneCurveCopyWith<$Res> get master;$ToneCurveCopyWith<$Res> get red;$ToneCurveCopyWith<$Res> get green;$ToneCurveCopyWith<$Res> get blue;

}
/// @nodoc
class _$ToneCurvesCopyWithImpl<$Res>
    implements $ToneCurvesCopyWith<$Res> {
  _$ToneCurvesCopyWithImpl(this._self, this._then);

  final ToneCurves _self;
  final $Res Function(ToneCurves) _then;

/// Create a copy of ToneCurves
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? master = null,Object? red = null,Object? green = null,Object? blue = null,}) {
  return _then(ToneCurves(
master: null == master ? _self.master : master // ignore: cast_nullable_to_non_nullable
as ToneCurve,red: null == red ? _self.red : red // ignore: cast_nullable_to_non_nullable
as ToneCurve,green: null == green ? _self.green : green // ignore: cast_nullable_to_non_nullable
as ToneCurve,blue: null == blue ? _self.blue : blue // ignore: cast_nullable_to_non_nullable
as ToneCurve,
  ));
}
/// Create a copy of ToneCurves
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurveCopyWith<$Res> get master {
  
  return $ToneCurveCopyWith<$Res>(_self.master, (value) {
    return _then(_self.copyWith(master: value));
  });
}/// Create a copy of ToneCurves
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurveCopyWith<$Res> get red {
  
  return $ToneCurveCopyWith<$Res>(_self.red, (value) {
    return _then(_self.copyWith(red: value));
  });
}/// Create a copy of ToneCurves
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurveCopyWith<$Res> get green {
  
  return $ToneCurveCopyWith<$Res>(_self.green, (value) {
    return _then(_self.copyWith(green: value));
  });
}/// Create a copy of ToneCurves
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurveCopyWith<$Res> get blue {
  
  return $ToneCurveCopyWith<$Res>(_self.blue, (value) {
    return _then(_self.copyWith(blue: value));
  });
}
}


/// Adds pattern-matching-related methods to [ToneCurves].
extension ToneCurvesPatterns on ToneCurves {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToneCurves value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToneCurves() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToneCurves value)  $default,){
final _that = this;
switch (_that) {
case _ToneCurves():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToneCurves value)?  $default,){
final _that = this;
switch (_that) {
case _ToneCurves() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ToneCurve master,  ToneCurve red,  ToneCurve green,  ToneCurve blue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToneCurves() when $default != null:
return $default(_that.master,_that.red,_that.green,_that.blue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ToneCurve master,  ToneCurve red,  ToneCurve green,  ToneCurve blue)  $default,) {final _that = this;
switch (_that) {
case _ToneCurves():
return $default(_that.master,_that.red,_that.green,_that.blue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ToneCurve master,  ToneCurve red,  ToneCurve green,  ToneCurve blue)?  $default,) {final _that = this;
switch (_that) {
case _ToneCurves() when $default != null:
return $default(_that.master,_that.red,_that.green,_that.blue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ToneCurves extends ToneCurves {
  const _ToneCurves({this.master = const ToneCurve(), this.red = const ToneCurve(), this.green = const ToneCurve(), this.blue = const ToneCurve()}): super._();
  factory _ToneCurves.fromJson(Map<String, dynamic> json) => _$ToneCurvesFromJson(json);

@override@JsonKey() final  ToneCurve master;
@override@JsonKey() final  ToneCurve red;
@override@JsonKey() final  ToneCurve green;
@override@JsonKey() final  ToneCurve blue;

/// Create a copy of ToneCurves
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToneCurvesCopyWith<_ToneCurves> get copyWith => __$ToneCurvesCopyWithImpl<_ToneCurves>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ToneCurvesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToneCurves&&(identical(other.master, master) || other.master == master)&&(identical(other.red, red) || other.red == red)&&(identical(other.green, green) || other.green == green)&&(identical(other.blue, blue) || other.blue == blue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,master,red,green,blue);
}

@override
String toString() {
    return 'ToneCurves(master: $master, red: $red, green: $green, blue: $blue)';
}


}

/// @nodoc
abstract mixin class _$ToneCurvesCopyWith<$Res> implements $ToneCurvesCopyWith<$Res> {
  factory _$ToneCurvesCopyWith(_ToneCurves value, $Res Function(_ToneCurves) _then) = __$ToneCurvesCopyWithImpl;
@override @useResult
$Res call({
 ToneCurve master, ToneCurve red, ToneCurve green, ToneCurve blue
});


@override $ToneCurveCopyWith<$Res> get master;@override $ToneCurveCopyWith<$Res> get red;@override $ToneCurveCopyWith<$Res> get green;@override $ToneCurveCopyWith<$Res> get blue;

}
/// @nodoc
class __$ToneCurvesCopyWithImpl<$Res>
    implements _$ToneCurvesCopyWith<$Res> {
  __$ToneCurvesCopyWithImpl(this._self, this._then);

  final _ToneCurves _self;
  final $Res Function(_ToneCurves) _then;

/// Create a copy of ToneCurves
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? master = null,Object? red = null,Object? green = null,Object? blue = null,}) {
  return _then(_ToneCurves(
master: null == master ? _self.master : master // ignore: cast_nullable_to_non_nullable
as ToneCurve,red: null == red ? _self.red : red // ignore: cast_nullable_to_non_nullable
as ToneCurve,green: null == green ? _self.green : green // ignore: cast_nullable_to_non_nullable
as ToneCurve,blue: null == blue ? _self.blue : blue // ignore: cast_nullable_to_non_nullable
as ToneCurve,
  ));
}

/// Create a copy of ToneCurves
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurveCopyWith<$Res> get master {
  
  return $ToneCurveCopyWith<$Res>(_self.master, (value) {
    return _then(_self.copyWith(master: value));
  });
}/// Create a copy of ToneCurves
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurveCopyWith<$Res> get red {
  
  return $ToneCurveCopyWith<$Res>(_self.red, (value) {
    return _then(_self.copyWith(red: value));
  });
}/// Create a copy of ToneCurves
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurveCopyWith<$Res> get green {
  
  return $ToneCurveCopyWith<$Res>(_self.green, (value) {
    return _then(_self.copyWith(green: value));
  });
}/// Create a copy of ToneCurves
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurveCopyWith<$Res> get blue {
  
  return $ToneCurveCopyWith<$Res>(_self.blue, (value) {
    return _then(_self.copyWith(blue: value));
  });
}
}

// dart format on
