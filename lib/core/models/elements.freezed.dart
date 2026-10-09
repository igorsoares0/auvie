// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'elements.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ElementTransform {

 double get x; double get y; double get scale;/// Radians, clockwise.
 double get rotation;
/// Create a copy of ElementTransform
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ElementTransformCopyWith<ElementTransform> get copyWith => _$ElementTransformCopyWithImpl<ElementTransform>(this as ElementTransform, _$identity);

  /// Serializes this ElementTransform to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ElementTransform;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ElementTransform&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.y, _this.y) || other.y == _this.y)&&(identical(other.scale, _this.scale) || other.scale == _this.scale)&&(identical(other.rotation, _this.rotation) || other.rotation == _this.rotation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ElementTransform;
  return Object.hash(runtimeType,_this.x,_this.y,_this.scale,_this.rotation);
}

@override
String toString() {
  final _this = this as ElementTransform;
  return 'ElementTransform(x: ${_this.x}, y: ${_this.y}, scale: ${_this.scale}, rotation: ${_this.rotation})';
}


}

/// @nodoc
abstract mixin class $ElementTransformCopyWith<$Res>  {
  factory $ElementTransformCopyWith(ElementTransform value, $Res Function(ElementTransform) _then) = _$ElementTransformCopyWithImpl;
@useResult
$Res call({
 double x, double y, double scale, double rotation
});




}
/// @nodoc
class _$ElementTransformCopyWithImpl<$Res>
    implements $ElementTransformCopyWith<$Res> {
  _$ElementTransformCopyWithImpl(this._self, this._then);

  final ElementTransform _self;
  final $Res Function(ElementTransform) _then;

/// Create a copy of ElementTransform
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,Object? scale = null,Object? rotation = null,}) {
  return _then(ElementTransform(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ElementTransform].
extension ElementTransformPatterns on ElementTransform {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ElementTransform value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ElementTransform() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ElementTransform value)  $default,){
final _that = this;
switch (_that) {
case _ElementTransform():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ElementTransform value)?  $default,){
final _that = this;
switch (_that) {
case _ElementTransform() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double y,  double scale,  double rotation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ElementTransform() when $default != null:
return $default(_that.x,_that.y,_that.scale,_that.rotation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double y,  double scale,  double rotation)  $default,) {final _that = this;
switch (_that) {
case _ElementTransform():
return $default(_that.x,_that.y,_that.scale,_that.rotation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double y,  double scale,  double rotation)?  $default,) {final _that = this;
switch (_that) {
case _ElementTransform() when $default != null:
return $default(_that.x,_that.y,_that.scale,_that.rotation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ElementTransform implements ElementTransform {
  const _ElementTransform({this.x = 0.5, this.y = 0.5, this.scale = 1, this.rotation = 0});
  factory _ElementTransform.fromJson(Map<String, dynamic> json) => _$ElementTransformFromJson(json);

@override@JsonKey() final  double x;
@override@JsonKey() final  double y;
@override@JsonKey() final  double scale;
/// Radians, clockwise.
@override@JsonKey() final  double rotation;

/// Create a copy of ElementTransform
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ElementTransformCopyWith<_ElementTransform> get copyWith => __$ElementTransformCopyWithImpl<_ElementTransform>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ElementTransformToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ElementTransform&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.scale, scale) || other.scale == scale)&&(identical(other.rotation, rotation) || other.rotation == rotation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,x,y,scale,rotation);
}

@override
String toString() {
    return 'ElementTransform(x: $x, y: $y, scale: $scale, rotation: $rotation)';
}


}

/// @nodoc
abstract mixin class _$ElementTransformCopyWith<$Res> implements $ElementTransformCopyWith<$Res> {
  factory _$ElementTransformCopyWith(_ElementTransform value, $Res Function(_ElementTransform) _then) = __$ElementTransformCopyWithImpl;
@override @useResult
$Res call({
 double x, double y, double scale, double rotation
});




}
/// @nodoc
class __$ElementTransformCopyWithImpl<$Res>
    implements _$ElementTransformCopyWith<$Res> {
  __$ElementTransformCopyWithImpl(this._self, this._then);

  final _ElementTransform _self;
  final $Res Function(_ElementTransform) _then;

/// Create a copy of ElementTransform
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,Object? scale = null,Object? rotation = null,}) {
  return _then(_ElementTransform(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,scale: null == scale ? _self.scale : scale // ignore: cast_nullable_to_non_nullable
as double,rotation: null == rotation ? _self.rotation : rotation // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$TimeRange {

 int get startMs; int get endMs;
/// Create a copy of TimeRange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeRangeCopyWith<TimeRange> get copyWith => _$TimeRangeCopyWithImpl<TimeRange>(this as TimeRange, _$identity);

  /// Serializes this TimeRange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TimeRange;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeRange&&(identical(other.startMs, _this.startMs) || other.startMs == _this.startMs)&&(identical(other.endMs, _this.endMs) || other.endMs == _this.endMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TimeRange;
  return Object.hash(runtimeType,_this.startMs,_this.endMs);
}

@override
String toString() {
  final _this = this as TimeRange;
  return 'TimeRange(startMs: ${_this.startMs}, endMs: ${_this.endMs})';
}


}

/// @nodoc
abstract mixin class $TimeRangeCopyWith<$Res>  {
  factory $TimeRangeCopyWith(TimeRange value, $Res Function(TimeRange) _then) = _$TimeRangeCopyWithImpl;
@useResult
$Res call({
 int startMs, int endMs
});




}
/// @nodoc
class _$TimeRangeCopyWithImpl<$Res>
    implements $TimeRangeCopyWith<$Res> {
  _$TimeRangeCopyWithImpl(this._self, this._then);

  final TimeRange _self;
  final $Res Function(TimeRange) _then;

/// Create a copy of TimeRange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startMs = null,Object? endMs = null,}) {
  return _then(TimeRange(
startMs: null == startMs ? _self.startMs : startMs // ignore: cast_nullable_to_non_nullable
as int,endMs: null == endMs ? _self.endMs : endMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeRange].
extension TimeRangePatterns on TimeRange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeRange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeRange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeRange value)  $default,){
final _that = this;
switch (_that) {
case _TimeRange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeRange value)?  $default,){
final _that = this;
switch (_that) {
case _TimeRange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int startMs,  int endMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeRange() when $default != null:
return $default(_that.startMs,_that.endMs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int startMs,  int endMs)  $default,) {final _that = this;
switch (_that) {
case _TimeRange():
return $default(_that.startMs,_that.endMs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int startMs,  int endMs)?  $default,) {final _that = this;
switch (_that) {
case _TimeRange() when $default != null:
return $default(_that.startMs,_that.endMs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimeRange extends TimeRange {
  const _TimeRange({required this.startMs, required this.endMs}): super._();
  factory _TimeRange.fromJson(Map<String, dynamic> json) => _$TimeRangeFromJson(json);

@override final  int startMs;
@override final  int endMs;

/// Create a copy of TimeRange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeRangeCopyWith<_TimeRange> get copyWith => __$TimeRangeCopyWithImpl<_TimeRange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimeRangeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeRange&&(identical(other.startMs, startMs) || other.startMs == startMs)&&(identical(other.endMs, endMs) || other.endMs == endMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,startMs,endMs);
}

@override
String toString() {
    return 'TimeRange(startMs: $startMs, endMs: $endMs)';
}


}

/// @nodoc
abstract mixin class _$TimeRangeCopyWith<$Res> implements $TimeRangeCopyWith<$Res> {
  factory _$TimeRangeCopyWith(_TimeRange value, $Res Function(_TimeRange) _then) = __$TimeRangeCopyWithImpl;
@override @useResult
$Res call({
 int startMs, int endMs
});




}
/// @nodoc
class __$TimeRangeCopyWithImpl<$Res>
    implements _$TimeRangeCopyWith<$Res> {
  __$TimeRangeCopyWithImpl(this._self, this._then);

  final _TimeRange _self;
  final $Res Function(_TimeRange) _then;

/// Create a copy of TimeRange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startMs = null,Object? endMs = null,}) {
  return _then(_TimeRange(
startMs: null == startMs ? _self.startMs : startMs // ignore: cast_nullable_to_non_nullable
as int,endMs: null == endMs ? _self.endMs : endMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TextShadowSpec {

 int get color; double get blur; double get dx; double get dy;
/// Create a copy of TextShadowSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextShadowSpecCopyWith<TextShadowSpec> get copyWith => _$TextShadowSpecCopyWithImpl<TextShadowSpec>(this as TextShadowSpec, _$identity);

  /// Serializes this TextShadowSpec to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TextShadowSpec;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextShadowSpec&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.blur, _this.blur) || other.blur == _this.blur)&&(identical(other.dx, _this.dx) || other.dx == _this.dx)&&(identical(other.dy, _this.dy) || other.dy == _this.dy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TextShadowSpec;
  return Object.hash(runtimeType,_this.color,_this.blur,_this.dx,_this.dy);
}

@override
String toString() {
  final _this = this as TextShadowSpec;
  return 'TextShadowSpec(color: ${_this.color}, blur: ${_this.blur}, dx: ${_this.dx}, dy: ${_this.dy})';
}


}

/// @nodoc
abstract mixin class $TextShadowSpecCopyWith<$Res>  {
  factory $TextShadowSpecCopyWith(TextShadowSpec value, $Res Function(TextShadowSpec) _then) = _$TextShadowSpecCopyWithImpl;
@useResult
$Res call({
 int color, double blur, double dx, double dy
});




}
/// @nodoc
class _$TextShadowSpecCopyWithImpl<$Res>
    implements $TextShadowSpecCopyWith<$Res> {
  _$TextShadowSpecCopyWithImpl(this._self, this._then);

  final TextShadowSpec _self;
  final $Res Function(TextShadowSpec) _then;

/// Create a copy of TextShadowSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? blur = null,Object? dx = null,Object? dy = null,}) {
  return _then(TextShadowSpec(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,blur: null == blur ? _self.blur : blur // ignore: cast_nullable_to_non_nullable
as double,dx: null == dx ? _self.dx : dx // ignore: cast_nullable_to_non_nullable
as double,dy: null == dy ? _self.dy : dy // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TextShadowSpec].
extension TextShadowSpecPatterns on TextShadowSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextShadowSpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextShadowSpec() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextShadowSpec value)  $default,){
final _that = this;
switch (_that) {
case _TextShadowSpec():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextShadowSpec value)?  $default,){
final _that = this;
switch (_that) {
case _TextShadowSpec() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int color,  double blur,  double dx,  double dy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextShadowSpec() when $default != null:
return $default(_that.color,_that.blur,_that.dx,_that.dy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int color,  double blur,  double dx,  double dy)  $default,) {final _that = this;
switch (_that) {
case _TextShadowSpec():
return $default(_that.color,_that.blur,_that.dx,_that.dy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int color,  double blur,  double dx,  double dy)?  $default,) {final _that = this;
switch (_that) {
case _TextShadowSpec() when $default != null:
return $default(_that.color,_that.blur,_that.dx,_that.dy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextShadowSpec implements TextShadowSpec {
  const _TextShadowSpec({this.color = 0x66000000, this.blur = 0.01, this.dx = 0, this.dy = 0.004});
  factory _TextShadowSpec.fromJson(Map<String, dynamic> json) => _$TextShadowSpecFromJson(json);

@override@JsonKey() final  int color;
@override@JsonKey() final  double blur;
@override@JsonKey() final  double dx;
@override@JsonKey() final  double dy;

/// Create a copy of TextShadowSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextShadowSpecCopyWith<_TextShadowSpec> get copyWith => __$TextShadowSpecCopyWithImpl<_TextShadowSpec>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextShadowSpecToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextShadowSpec&&(identical(other.color, color) || other.color == color)&&(identical(other.blur, blur) || other.blur == blur)&&(identical(other.dx, dx) || other.dx == dx)&&(identical(other.dy, dy) || other.dy == dy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,color,blur,dx,dy);
}

@override
String toString() {
    return 'TextShadowSpec(color: $color, blur: $blur, dx: $dx, dy: $dy)';
}


}

/// @nodoc
abstract mixin class _$TextShadowSpecCopyWith<$Res> implements $TextShadowSpecCopyWith<$Res> {
  factory _$TextShadowSpecCopyWith(_TextShadowSpec value, $Res Function(_TextShadowSpec) _then) = __$TextShadowSpecCopyWithImpl;
@override @useResult
$Res call({
 int color, double blur, double dx, double dy
});




}
/// @nodoc
class __$TextShadowSpecCopyWithImpl<$Res>
    implements _$TextShadowSpecCopyWith<$Res> {
  __$TextShadowSpecCopyWithImpl(this._self, this._then);

  final _TextShadowSpec _self;
  final $Res Function(_TextShadowSpec) _then;

/// Create a copy of TextShadowSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? blur = null,Object? dx = null,Object? dy = null,}) {
  return _then(_TextShadowSpec(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,blur: null == blur ? _self.blur : blur // ignore: cast_nullable_to_non_nullable
as double,dx: null == dx ? _self.dx : dx // ignore: cast_nullable_to_non_nullable
as double,dy: null == dy ? _self.dy : dy // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$TextOutlineSpec {

 int get color; double get width;
/// Create a copy of TextOutlineSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextOutlineSpecCopyWith<TextOutlineSpec> get copyWith => _$TextOutlineSpecCopyWithImpl<TextOutlineSpec>(this as TextOutlineSpec, _$identity);

  /// Serializes this TextOutlineSpec to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TextOutlineSpec;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextOutlineSpec&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.width, _this.width) || other.width == _this.width));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TextOutlineSpec;
  return Object.hash(runtimeType,_this.color,_this.width);
}

@override
String toString() {
  final _this = this as TextOutlineSpec;
  return 'TextOutlineSpec(color: ${_this.color}, width: ${_this.width})';
}


}

/// @nodoc
abstract mixin class $TextOutlineSpecCopyWith<$Res>  {
  factory $TextOutlineSpecCopyWith(TextOutlineSpec value, $Res Function(TextOutlineSpec) _then) = _$TextOutlineSpecCopyWithImpl;
@useResult
$Res call({
 int color, double width
});




}
/// @nodoc
class _$TextOutlineSpecCopyWithImpl<$Res>
    implements $TextOutlineSpecCopyWith<$Res> {
  _$TextOutlineSpecCopyWithImpl(this._self, this._then);

  final TextOutlineSpec _self;
  final $Res Function(TextOutlineSpec) _then;

/// Create a copy of TextOutlineSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? width = null,}) {
  return _then(TextOutlineSpec(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TextOutlineSpec].
extension TextOutlineSpecPatterns on TextOutlineSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextOutlineSpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextOutlineSpec() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextOutlineSpec value)  $default,){
final _that = this;
switch (_that) {
case _TextOutlineSpec():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextOutlineSpec value)?  $default,){
final _that = this;
switch (_that) {
case _TextOutlineSpec() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int color,  double width)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextOutlineSpec() when $default != null:
return $default(_that.color,_that.width);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int color,  double width)  $default,) {final _that = this;
switch (_that) {
case _TextOutlineSpec():
return $default(_that.color,_that.width);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int color,  double width)?  $default,) {final _that = this;
switch (_that) {
case _TextOutlineSpec() when $default != null:
return $default(_that.color,_that.width);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextOutlineSpec implements TextOutlineSpec {
  const _TextOutlineSpec({this.color = 0xFF161412, this.width = 0.003});
  factory _TextOutlineSpec.fromJson(Map<String, dynamic> json) => _$TextOutlineSpecFromJson(json);

@override@JsonKey() final  int color;
@override@JsonKey() final  double width;

/// Create a copy of TextOutlineSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextOutlineSpecCopyWith<_TextOutlineSpec> get copyWith => __$TextOutlineSpecCopyWithImpl<_TextOutlineSpec>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextOutlineSpecToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextOutlineSpec&&(identical(other.color, color) || other.color == color)&&(identical(other.width, width) || other.width == width));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,color,width);
}

@override
String toString() {
    return 'TextOutlineSpec(color: $color, width: $width)';
}


}

/// @nodoc
abstract mixin class _$TextOutlineSpecCopyWith<$Res> implements $TextOutlineSpecCopyWith<$Res> {
  factory _$TextOutlineSpecCopyWith(_TextOutlineSpec value, $Res Function(_TextOutlineSpec) _then) = __$TextOutlineSpecCopyWithImpl;
@override @useResult
$Res call({
 int color, double width
});




}
/// @nodoc
class __$TextOutlineSpecCopyWithImpl<$Res>
    implements _$TextOutlineSpecCopyWith<$Res> {
  __$TextOutlineSpecCopyWithImpl(this._self, this._then);

  final _TextOutlineSpec _self;
  final $Res Function(_TextOutlineSpec) _then;

/// Create a copy of TextOutlineSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? width = null,}) {
  return _then(_TextOutlineSpec(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$TextBackgroundSpec {

 int get color; double get padding;
/// Create a copy of TextBackgroundSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextBackgroundSpecCopyWith<TextBackgroundSpec> get copyWith => _$TextBackgroundSpecCopyWithImpl<TextBackgroundSpec>(this as TextBackgroundSpec, _$identity);

  /// Serializes this TextBackgroundSpec to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TextBackgroundSpec;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextBackgroundSpec&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.padding, _this.padding) || other.padding == _this.padding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TextBackgroundSpec;
  return Object.hash(runtimeType,_this.color,_this.padding);
}

@override
String toString() {
  final _this = this as TextBackgroundSpec;
  return 'TextBackgroundSpec(color: ${_this.color}, padding: ${_this.padding})';
}


}

/// @nodoc
abstract mixin class $TextBackgroundSpecCopyWith<$Res>  {
  factory $TextBackgroundSpecCopyWith(TextBackgroundSpec value, $Res Function(TextBackgroundSpec) _then) = _$TextBackgroundSpecCopyWithImpl;
@useResult
$Res call({
 int color, double padding
});




}
/// @nodoc
class _$TextBackgroundSpecCopyWithImpl<$Res>
    implements $TextBackgroundSpecCopyWith<$Res> {
  _$TextBackgroundSpecCopyWithImpl(this._self, this._then);

  final TextBackgroundSpec _self;
  final $Res Function(TextBackgroundSpec) _then;

/// Create a copy of TextBackgroundSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? padding = null,}) {
  return _then(TextBackgroundSpec(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,padding: null == padding ? _self.padding : padding // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TextBackgroundSpec].
extension TextBackgroundSpecPatterns on TextBackgroundSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextBackgroundSpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextBackgroundSpec() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextBackgroundSpec value)  $default,){
final _that = this;
switch (_that) {
case _TextBackgroundSpec():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextBackgroundSpec value)?  $default,){
final _that = this;
switch (_that) {
case _TextBackgroundSpec() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int color,  double padding)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextBackgroundSpec() when $default != null:
return $default(_that.color,_that.padding);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int color,  double padding)  $default,) {final _that = this;
switch (_that) {
case _TextBackgroundSpec():
return $default(_that.color,_that.padding);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int color,  double padding)?  $default,) {final _that = this;
switch (_that) {
case _TextBackgroundSpec() when $default != null:
return $default(_that.color,_that.padding);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextBackgroundSpec implements TextBackgroundSpec {
  const _TextBackgroundSpec({this.color = 0xFFEFE8DC, this.padding = 0.01});
  factory _TextBackgroundSpec.fromJson(Map<String, dynamic> json) => _$TextBackgroundSpecFromJson(json);

@override@JsonKey() final  int color;
@override@JsonKey() final  double padding;

/// Create a copy of TextBackgroundSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextBackgroundSpecCopyWith<_TextBackgroundSpec> get copyWith => __$TextBackgroundSpecCopyWithImpl<_TextBackgroundSpec>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextBackgroundSpecToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextBackgroundSpec&&(identical(other.color, color) || other.color == color)&&(identical(other.padding, padding) || other.padding == padding));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,color,padding);
}

@override
String toString() {
    return 'TextBackgroundSpec(color: $color, padding: $padding)';
}


}

/// @nodoc
abstract mixin class _$TextBackgroundSpecCopyWith<$Res> implements $TextBackgroundSpecCopyWith<$Res> {
  factory _$TextBackgroundSpecCopyWith(_TextBackgroundSpec value, $Res Function(_TextBackgroundSpec) _then) = __$TextBackgroundSpecCopyWithImpl;
@override @useResult
$Res call({
 int color, double padding
});




}
/// @nodoc
class __$TextBackgroundSpecCopyWithImpl<$Res>
    implements _$TextBackgroundSpecCopyWith<$Res> {
  __$TextBackgroundSpecCopyWithImpl(this._self, this._then);

  final _TextBackgroundSpec _self;
  final $Res Function(_TextBackgroundSpec) _then;

/// Create a copy of TextBackgroundSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? padding = null,}) {
  return _then(_TextBackgroundSpec(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,padding: null == padding ? _self.padding : padding // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$TextStyleSpec {

 String get fontFamily;/// Fraction of the media's shorter side.
 double get fontSize; int get fontWeight; bool get italic; TextAlignment get align; int get color;/// In em.
 double get letterSpacing; double get lineHeight; TextShadowSpec? get shadow; TextOutlineSpec? get outline; TextBackgroundSpec? get background;
/// Create a copy of TextStyleSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextStyleSpecCopyWith<TextStyleSpec> get copyWith => _$TextStyleSpecCopyWithImpl<TextStyleSpec>(this as TextStyleSpec, _$identity);

  /// Serializes this TextStyleSpec to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TextStyleSpec;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextStyleSpec&&(identical(other.fontFamily, _this.fontFamily) || other.fontFamily == _this.fontFamily)&&(identical(other.fontSize, _this.fontSize) || other.fontSize == _this.fontSize)&&(identical(other.fontWeight, _this.fontWeight) || other.fontWeight == _this.fontWeight)&&(identical(other.italic, _this.italic) || other.italic == _this.italic)&&(identical(other.align, _this.align) || other.align == _this.align)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.letterSpacing, _this.letterSpacing) || other.letterSpacing == _this.letterSpacing)&&(identical(other.lineHeight, _this.lineHeight) || other.lineHeight == _this.lineHeight)&&(identical(other.shadow, _this.shadow) || other.shadow == _this.shadow)&&(identical(other.outline, _this.outline) || other.outline == _this.outline)&&(identical(other.background, _this.background) || other.background == _this.background));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TextStyleSpec;
  return Object.hash(runtimeType,_this.fontFamily,_this.fontSize,_this.fontWeight,_this.italic,_this.align,_this.color,_this.letterSpacing,_this.lineHeight,_this.shadow,_this.outline,_this.background);
}

@override
String toString() {
  final _this = this as TextStyleSpec;
  return 'TextStyleSpec(fontFamily: ${_this.fontFamily}, fontSize: ${_this.fontSize}, fontWeight: ${_this.fontWeight}, italic: ${_this.italic}, align: ${_this.align}, color: ${_this.color}, letterSpacing: ${_this.letterSpacing}, lineHeight: ${_this.lineHeight}, shadow: ${_this.shadow}, outline: ${_this.outline}, background: ${_this.background})';
}


}

/// @nodoc
abstract mixin class $TextStyleSpecCopyWith<$Res>  {
  factory $TextStyleSpecCopyWith(TextStyleSpec value, $Res Function(TextStyleSpec) _then) = _$TextStyleSpecCopyWithImpl;
@useResult
$Res call({
 String fontFamily, double fontSize, int fontWeight, bool italic, TextAlignment align, int color, double letterSpacing, double lineHeight, TextShadowSpec? shadow, TextOutlineSpec? outline, TextBackgroundSpec? background
});


$TextShadowSpecCopyWith<$Res>? get shadow;$TextOutlineSpecCopyWith<$Res>? get outline;$TextBackgroundSpecCopyWith<$Res>? get background;

}
/// @nodoc
class _$TextStyleSpecCopyWithImpl<$Res>
    implements $TextStyleSpecCopyWith<$Res> {
  _$TextStyleSpecCopyWithImpl(this._self, this._then);

  final TextStyleSpec _self;
  final $Res Function(TextStyleSpec) _then;

/// Create a copy of TextStyleSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fontFamily = null,Object? fontSize = null,Object? fontWeight = null,Object? italic = null,Object? align = null,Object? color = null,Object? letterSpacing = null,Object? lineHeight = null,Object? shadow = freezed,Object? outline = freezed,Object? background = freezed,}) {
  return _then(TextStyleSpec(
fontFamily: null == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,fontWeight: null == fontWeight ? _self.fontWeight : fontWeight // ignore: cast_nullable_to_non_nullable
as int,italic: null == italic ? _self.italic : italic // ignore: cast_nullable_to_non_nullable
as bool,align: null == align ? _self.align : align // ignore: cast_nullable_to_non_nullable
as TextAlignment,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,letterSpacing: null == letterSpacing ? _self.letterSpacing : letterSpacing // ignore: cast_nullable_to_non_nullable
as double,lineHeight: null == lineHeight ? _self.lineHeight : lineHeight // ignore: cast_nullable_to_non_nullable
as double,shadow: freezed == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as TextShadowSpec?,outline: freezed == outline ? _self.outline : outline // ignore: cast_nullable_to_non_nullable
as TextOutlineSpec?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as TextBackgroundSpec?,
  ));
}
/// Create a copy of TextStyleSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextShadowSpecCopyWith<$Res>? get shadow {
    if (_self.shadow == null) {
    return null;
  }

  return $TextShadowSpecCopyWith<$Res>(_self.shadow!, (value) {
    return _then(_self.copyWith(shadow: value));
  });
}/// Create a copy of TextStyleSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextOutlineSpecCopyWith<$Res>? get outline {
    if (_self.outline == null) {
    return null;
  }

  return $TextOutlineSpecCopyWith<$Res>(_self.outline!, (value) {
    return _then(_self.copyWith(outline: value));
  });
}/// Create a copy of TextStyleSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextBackgroundSpecCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $TextBackgroundSpecCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}
}


/// Adds pattern-matching-related methods to [TextStyleSpec].
extension TextStyleSpecPatterns on TextStyleSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextStyleSpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextStyleSpec() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextStyleSpec value)  $default,){
final _that = this;
switch (_that) {
case _TextStyleSpec():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextStyleSpec value)?  $default,){
final _that = this;
switch (_that) {
case _TextStyleSpec() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fontFamily,  double fontSize,  int fontWeight,  bool italic,  TextAlignment align,  int color,  double letterSpacing,  double lineHeight,  TextShadowSpec? shadow,  TextOutlineSpec? outline,  TextBackgroundSpec? background)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextStyleSpec() when $default != null:
return $default(_that.fontFamily,_that.fontSize,_that.fontWeight,_that.italic,_that.align,_that.color,_that.letterSpacing,_that.lineHeight,_that.shadow,_that.outline,_that.background);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fontFamily,  double fontSize,  int fontWeight,  bool italic,  TextAlignment align,  int color,  double letterSpacing,  double lineHeight,  TextShadowSpec? shadow,  TextOutlineSpec? outline,  TextBackgroundSpec? background)  $default,) {final _that = this;
switch (_that) {
case _TextStyleSpec():
return $default(_that.fontFamily,_that.fontSize,_that.fontWeight,_that.italic,_that.align,_that.color,_that.letterSpacing,_that.lineHeight,_that.shadow,_that.outline,_that.background);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fontFamily,  double fontSize,  int fontWeight,  bool italic,  TextAlignment align,  int color,  double letterSpacing,  double lineHeight,  TextShadowSpec? shadow,  TextOutlineSpec? outline,  TextBackgroundSpec? background)?  $default,) {final _that = this;
switch (_that) {
case _TextStyleSpec() when $default != null:
return $default(_that.fontFamily,_that.fontSize,_that.fontWeight,_that.italic,_that.align,_that.color,_that.letterSpacing,_that.lineHeight,_that.shadow,_that.outline,_that.background);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextStyleSpec implements TextStyleSpec {
  const _TextStyleSpec({this.fontFamily = 'Newsreader', this.fontSize = 0.06, this.fontWeight = 400, this.italic = false, this.align = TextAlignment.center, this.color = 0xFFEFE8DC, this.letterSpacing = 0, this.lineHeight = 1.2, this.shadow, this.outline, this.background});
  factory _TextStyleSpec.fromJson(Map<String, dynamic> json) => _$TextStyleSpecFromJson(json);

@override@JsonKey() final  String fontFamily;
/// Fraction of the media's shorter side.
@override@JsonKey() final  double fontSize;
@override@JsonKey() final  int fontWeight;
@override@JsonKey() final  bool italic;
@override@JsonKey() final  TextAlignment align;
@override@JsonKey() final  int color;
/// In em.
@override@JsonKey() final  double letterSpacing;
@override@JsonKey() final  double lineHeight;
@override final  TextShadowSpec? shadow;
@override final  TextOutlineSpec? outline;
@override final  TextBackgroundSpec? background;

/// Create a copy of TextStyleSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextStyleSpecCopyWith<_TextStyleSpec> get copyWith => __$TextStyleSpecCopyWithImpl<_TextStyleSpec>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextStyleSpecToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextStyleSpec&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.fontWeight, fontWeight) || other.fontWeight == fontWeight)&&(identical(other.italic, italic) || other.italic == italic)&&(identical(other.align, align) || other.align == align)&&(identical(other.color, color) || other.color == color)&&(identical(other.letterSpacing, letterSpacing) || other.letterSpacing == letterSpacing)&&(identical(other.lineHeight, lineHeight) || other.lineHeight == lineHeight)&&(identical(other.shadow, shadow) || other.shadow == shadow)&&(identical(other.outline, outline) || other.outline == outline)&&(identical(other.background, background) || other.background == background));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,fontFamily,fontSize,fontWeight,italic,align,color,letterSpacing,lineHeight,shadow,outline,background);
}

@override
String toString() {
    return 'TextStyleSpec(fontFamily: $fontFamily, fontSize: $fontSize, fontWeight: $fontWeight, italic: $italic, align: $align, color: $color, letterSpacing: $letterSpacing, lineHeight: $lineHeight, shadow: $shadow, outline: $outline, background: $background)';
}


}

/// @nodoc
abstract mixin class _$TextStyleSpecCopyWith<$Res> implements $TextStyleSpecCopyWith<$Res> {
  factory _$TextStyleSpecCopyWith(_TextStyleSpec value, $Res Function(_TextStyleSpec) _then) = __$TextStyleSpecCopyWithImpl;
@override @useResult
$Res call({
 String fontFamily, double fontSize, int fontWeight, bool italic, TextAlignment align, int color, double letterSpacing, double lineHeight, TextShadowSpec? shadow, TextOutlineSpec? outline, TextBackgroundSpec? background
});


@override $TextShadowSpecCopyWith<$Res>? get shadow;@override $TextOutlineSpecCopyWith<$Res>? get outline;@override $TextBackgroundSpecCopyWith<$Res>? get background;

}
/// @nodoc
class __$TextStyleSpecCopyWithImpl<$Res>
    implements _$TextStyleSpecCopyWith<$Res> {
  __$TextStyleSpecCopyWithImpl(this._self, this._then);

  final _TextStyleSpec _self;
  final $Res Function(_TextStyleSpec) _then;

/// Create a copy of TextStyleSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fontFamily = null,Object? fontSize = null,Object? fontWeight = null,Object? italic = null,Object? align = null,Object? color = null,Object? letterSpacing = null,Object? lineHeight = null,Object? shadow = freezed,Object? outline = freezed,Object? background = freezed,}) {
  return _then(_TextStyleSpec(
fontFamily: null == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String,fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,fontWeight: null == fontWeight ? _self.fontWeight : fontWeight // ignore: cast_nullable_to_non_nullable
as int,italic: null == italic ? _self.italic : italic // ignore: cast_nullable_to_non_nullable
as bool,align: null == align ? _self.align : align // ignore: cast_nullable_to_non_nullable
as TextAlignment,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,letterSpacing: null == letterSpacing ? _self.letterSpacing : letterSpacing // ignore: cast_nullable_to_non_nullable
as double,lineHeight: null == lineHeight ? _self.lineHeight : lineHeight // ignore: cast_nullable_to_non_nullable
as double,shadow: freezed == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as TextShadowSpec?,outline: freezed == outline ? _self.outline : outline // ignore: cast_nullable_to_non_nullable
as TextOutlineSpec?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as TextBackgroundSpec?,
  ));
}

/// Create a copy of TextStyleSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextShadowSpecCopyWith<$Res>? get shadow {
    if (_self.shadow == null) {
    return null;
  }

  return $TextShadowSpecCopyWith<$Res>(_self.shadow!, (value) {
    return _then(_self.copyWith(shadow: value));
  });
}/// Create a copy of TextStyleSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextOutlineSpecCopyWith<$Res>? get outline {
    if (_self.outline == null) {
    return null;
  }

  return $TextOutlineSpecCopyWith<$Res>(_self.outline!, (value) {
    return _then(_self.copyWith(outline: value));
  });
}/// Create a copy of TextStyleSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextBackgroundSpecCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $TextBackgroundSpecCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}
}


/// @nodoc
mixin _$StrokePoint {

 double get x; double get y; double? get pressure;
/// Create a copy of StrokePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StrokePointCopyWith<StrokePoint> get copyWith => _$StrokePointCopyWithImpl<StrokePoint>(this as StrokePoint, _$identity);

  /// Serializes this StrokePoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StrokePoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StrokePoint&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.y, _this.y) || other.y == _this.y)&&(identical(other.pressure, _this.pressure) || other.pressure == _this.pressure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StrokePoint;
  return Object.hash(runtimeType,_this.x,_this.y,_this.pressure);
}

@override
String toString() {
  final _this = this as StrokePoint;
  return 'StrokePoint(x: ${_this.x}, y: ${_this.y}, pressure: ${_this.pressure})';
}


}

/// @nodoc
abstract mixin class $StrokePointCopyWith<$Res>  {
  factory $StrokePointCopyWith(StrokePoint value, $Res Function(StrokePoint) _then) = _$StrokePointCopyWithImpl;
@useResult
$Res call({
 double x, double y, double? pressure
});




}
/// @nodoc
class _$StrokePointCopyWithImpl<$Res>
    implements $StrokePointCopyWith<$Res> {
  _$StrokePointCopyWithImpl(this._self, this._then);

  final StrokePoint _self;
  final $Res Function(StrokePoint) _then;

/// Create a copy of StrokePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? y = null,Object? pressure = freezed,}) {
  return _then(StrokePoint(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,pressure: freezed == pressure ? _self.pressure : pressure // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [StrokePoint].
extension StrokePointPatterns on StrokePoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StrokePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StrokePoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StrokePoint value)  $default,){
final _that = this;
switch (_that) {
case _StrokePoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StrokePoint value)?  $default,){
final _that = this;
switch (_that) {
case _StrokePoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double y,  double? pressure)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StrokePoint() when $default != null:
return $default(_that.x,_that.y,_that.pressure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double y,  double? pressure)  $default,) {final _that = this;
switch (_that) {
case _StrokePoint():
return $default(_that.x,_that.y,_that.pressure);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double y,  double? pressure)?  $default,) {final _that = this;
switch (_that) {
case _StrokePoint() when $default != null:
return $default(_that.x,_that.y,_that.pressure);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StrokePoint implements StrokePoint {
  const _StrokePoint({required this.x, required this.y, this.pressure});
  factory _StrokePoint.fromJson(Map<String, dynamic> json) => _$StrokePointFromJson(json);

@override final  double x;
@override final  double y;
@override final  double? pressure;

/// Create a copy of StrokePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StrokePointCopyWith<_StrokePoint> get copyWith => __$StrokePointCopyWithImpl<_StrokePoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StrokePointToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StrokePoint&&(identical(other.x, x) || other.x == x)&&(identical(other.y, y) || other.y == y)&&(identical(other.pressure, pressure) || other.pressure == pressure));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,x,y,pressure);
}

@override
String toString() {
    return 'StrokePoint(x: $x, y: $y, pressure: $pressure)';
}


}

/// @nodoc
abstract mixin class _$StrokePointCopyWith<$Res> implements $StrokePointCopyWith<$Res> {
  factory _$StrokePointCopyWith(_StrokePoint value, $Res Function(_StrokePoint) _then) = __$StrokePointCopyWithImpl;
@override @useResult
$Res call({
 double x, double y, double? pressure
});




}
/// @nodoc
class __$StrokePointCopyWithImpl<$Res>
    implements _$StrokePointCopyWith<$Res> {
  __$StrokePointCopyWithImpl(this._self, this._then);

  final _StrokePoint _self;
  final $Res Function(_StrokePoint) _then;

/// Create a copy of StrokePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? y = null,Object? pressure = freezed,}) {
  return _then(_StrokePoint(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,y: null == y ? _self.y : y // ignore: cast_nullable_to_non_nullable
as double,pressure: freezed == pressure ? _self.pressure : pressure // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$BrushStroke {

 List<StrokePoint> get points;
/// Create a copy of BrushStroke
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrushStrokeCopyWith<BrushStroke> get copyWith => _$BrushStrokeCopyWithImpl<BrushStroke>(this as BrushStroke, _$identity);

  /// Serializes this BrushStroke to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BrushStroke;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BrushStroke&&const DeepCollectionEquality().equals(other.points, _this.points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BrushStroke;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.points));
}

@override
String toString() {
  final _this = this as BrushStroke;
  return 'BrushStroke(points: ${_this.points})';
}


}

/// @nodoc
abstract mixin class $BrushStrokeCopyWith<$Res>  {
  factory $BrushStrokeCopyWith(BrushStroke value, $Res Function(BrushStroke) _then) = _$BrushStrokeCopyWithImpl;
@useResult
$Res call({
 List<StrokePoint> points
});




}
/// @nodoc
class _$BrushStrokeCopyWithImpl<$Res>
    implements $BrushStrokeCopyWith<$Res> {
  _$BrushStrokeCopyWithImpl(this._self, this._then);

  final BrushStroke _self;
  final $Res Function(BrushStroke) _then;

/// Create a copy of BrushStroke
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? points = null,}) {
  return _then(BrushStroke(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<StrokePoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [BrushStroke].
extension BrushStrokePatterns on BrushStroke {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BrushStroke value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BrushStroke() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BrushStroke value)  $default,){
final _that = this;
switch (_that) {
case _BrushStroke():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BrushStroke value)?  $default,){
final _that = this;
switch (_that) {
case _BrushStroke() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<StrokePoint> points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BrushStroke() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<StrokePoint> points)  $default,) {final _that = this;
switch (_that) {
case _BrushStroke():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<StrokePoint> points)?  $default,) {final _that = this;
switch (_that) {
case _BrushStroke() when $default != null:
return $default(_that.points);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BrushStroke implements BrushStroke {
  const _BrushStroke({ List<StrokePoint> points = const <StrokePoint>[]}): _points = points;
  factory _BrushStroke.fromJson(Map<String, dynamic> json) => _$BrushStrokeFromJson(json);

 final  List<StrokePoint> _points;
@override@JsonKey() List<StrokePoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


/// Create a copy of BrushStroke
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BrushStrokeCopyWith<_BrushStroke> get copyWith => __$BrushStrokeCopyWithImpl<_BrushStroke>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrushStrokeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BrushStroke&&const DeepCollectionEquality().equals(other.points, _points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_points));
}

@override
String toString() {
    return 'BrushStroke(points: $points)';
}


}

/// @nodoc
abstract mixin class _$BrushStrokeCopyWith<$Res> implements $BrushStrokeCopyWith<$Res> {
  factory _$BrushStrokeCopyWith(_BrushStroke value, $Res Function(_BrushStroke) _then) = __$BrushStrokeCopyWithImpl;
@override @useResult
$Res call({
 List<StrokePoint> points
});




}
/// @nodoc
class __$BrushStrokeCopyWithImpl<$Res>
    implements _$BrushStrokeCopyWith<$Res> {
  __$BrushStrokeCopyWithImpl(this._self, this._then);

  final _BrushStroke _self;
  final $Res Function(_BrushStroke) _then;

/// Create a copy of BrushStroke
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? points = null,}) {
  return _then(_BrushStroke(
points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<StrokePoint>,
  ));
}


}

EditElement _$EditElementFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'text':
          return TextElement.fromJson(
            json
          );
                case 'textPath':
          return TextPathElement.fromJson(
            json
          );
                case 'brush':
          return BrushElement.fromJson(
            json
          );
                case 'sticker':
          return StickerElement.fromJson(
            json
          );
                case 'overlay':
          return OverlayElement.fromJson(
            json
          );
                case 'frame':
          return FrameElement.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'EditElement',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$EditElement {

 String get id;
/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditElementCopyWith<EditElement> get copyWith => _$EditElementCopyWithImpl<EditElement>(this as EditElement, _$identity);

  /// Serializes this EditElement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EditElement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditElement&&(identical(other.id, _this.id) || other.id == _this.id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EditElement;
  return Object.hash(runtimeType,_this.id);
}

@override
String toString() {
  final _this = this as EditElement;
  return 'EditElement(id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $EditElementCopyWith<$Res>  {
  factory $EditElementCopyWith(EditElement value, $Res Function(EditElement) _then) = _$EditElementCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$EditElementCopyWithImpl<$Res>
    implements $EditElementCopyWith<$Res> {
  _$EditElementCopyWithImpl(this._self, this._then);

  final EditElement _self;
  final $Res Function(EditElement) _then;

/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EditElement].
extension EditElementPatterns on EditElement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TextElement value)?  text,TResult Function( TextPathElement value)?  textPath,TResult Function( BrushElement value)?  brush,TResult Function( StickerElement value)?  sticker,TResult Function( OverlayElement value)?  overlay,TResult Function( FrameElement value)?  frame,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TextElement() when text != null:
return text(_that);case TextPathElement() when textPath != null:
return textPath(_that);case BrushElement() when brush != null:
return brush(_that);case StickerElement() when sticker != null:
return sticker(_that);case OverlayElement() when overlay != null:
return overlay(_that);case FrameElement() when frame != null:
return frame(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TextElement value)  text,required TResult Function( TextPathElement value)  textPath,required TResult Function( BrushElement value)  brush,required TResult Function( StickerElement value)  sticker,required TResult Function( OverlayElement value)  overlay,required TResult Function( FrameElement value)  frame,}){
final _that = this;
switch (_that) {
case TextElement():
return text(_that);case TextPathElement():
return textPath(_that);case BrushElement():
return brush(_that);case StickerElement():
return sticker(_that);case OverlayElement():
return overlay(_that);case FrameElement():
return frame(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TextElement value)?  text,TResult? Function( TextPathElement value)?  textPath,TResult? Function( BrushElement value)?  brush,TResult? Function( StickerElement value)?  sticker,TResult? Function( OverlayElement value)?  overlay,TResult? Function( FrameElement value)?  frame,}){
final _that = this;
switch (_that) {
case TextElement() when text != null:
return text(_that);case TextPathElement() when textPath != null:
return textPath(_that);case BrushElement() when brush != null:
return brush(_that);case StickerElement() when sticker != null:
return sticker(_that);case OverlayElement() when overlay != null:
return overlay(_that);case FrameElement() when frame != null:
return frame(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String text,  TextStyleSpec style,  String? textPresetId,  ElementTransform transform,  double opacity,  TimeRange? time)?  text,TResult Function( String id,  String text,  List<StrokePoint> path,  TextStyleSpec style,  ElementTransform transform,  double opacity,  TimeRange? time)?  textPath,TResult Function( String id,  BrushType brushType,  double size,  int color,  double smoothing,  List<BrushStroke> strokes,  ElementTransform transform,  double opacity,  TimeRange? time)?  brush,TResult Function( String id,  String assetId,  ElementTransform transform,  double opacity,  TimeRange? time)?  sticker,TResult Function( String id,  String assetId,  OverlayBlend blend,  double opacity,  TimeRange? time)?  overlay,TResult Function( String id,  String assetId)?  frame,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TextElement() when text != null:
return text(_that.id,_that.text,_that.style,_that.textPresetId,_that.transform,_that.opacity,_that.time);case TextPathElement() when textPath != null:
return textPath(_that.id,_that.text,_that.path,_that.style,_that.transform,_that.opacity,_that.time);case BrushElement() when brush != null:
return brush(_that.id,_that.brushType,_that.size,_that.color,_that.smoothing,_that.strokes,_that.transform,_that.opacity,_that.time);case StickerElement() when sticker != null:
return sticker(_that.id,_that.assetId,_that.transform,_that.opacity,_that.time);case OverlayElement() when overlay != null:
return overlay(_that.id,_that.assetId,_that.blend,_that.opacity,_that.time);case FrameElement() when frame != null:
return frame(_that.id,_that.assetId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String text,  TextStyleSpec style,  String? textPresetId,  ElementTransform transform,  double opacity,  TimeRange? time)  text,required TResult Function( String id,  String text,  List<StrokePoint> path,  TextStyleSpec style,  ElementTransform transform,  double opacity,  TimeRange? time)  textPath,required TResult Function( String id,  BrushType brushType,  double size,  int color,  double smoothing,  List<BrushStroke> strokes,  ElementTransform transform,  double opacity,  TimeRange? time)  brush,required TResult Function( String id,  String assetId,  ElementTransform transform,  double opacity,  TimeRange? time)  sticker,required TResult Function( String id,  String assetId,  OverlayBlend blend,  double opacity,  TimeRange? time)  overlay,required TResult Function( String id,  String assetId)  frame,}) {final _that = this;
switch (_that) {
case TextElement():
return text(_that.id,_that.text,_that.style,_that.textPresetId,_that.transform,_that.opacity,_that.time);case TextPathElement():
return textPath(_that.id,_that.text,_that.path,_that.style,_that.transform,_that.opacity,_that.time);case BrushElement():
return brush(_that.id,_that.brushType,_that.size,_that.color,_that.smoothing,_that.strokes,_that.transform,_that.opacity,_that.time);case StickerElement():
return sticker(_that.id,_that.assetId,_that.transform,_that.opacity,_that.time);case OverlayElement():
return overlay(_that.id,_that.assetId,_that.blend,_that.opacity,_that.time);case FrameElement():
return frame(_that.id,_that.assetId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String text,  TextStyleSpec style,  String? textPresetId,  ElementTransform transform,  double opacity,  TimeRange? time)?  text,TResult? Function( String id,  String text,  List<StrokePoint> path,  TextStyleSpec style,  ElementTransform transform,  double opacity,  TimeRange? time)?  textPath,TResult? Function( String id,  BrushType brushType,  double size,  int color,  double smoothing,  List<BrushStroke> strokes,  ElementTransform transform,  double opacity,  TimeRange? time)?  brush,TResult? Function( String id,  String assetId,  ElementTransform transform,  double opacity,  TimeRange? time)?  sticker,TResult? Function( String id,  String assetId,  OverlayBlend blend,  double opacity,  TimeRange? time)?  overlay,TResult? Function( String id,  String assetId)?  frame,}) {final _that = this;
switch (_that) {
case TextElement() when text != null:
return text(_that.id,_that.text,_that.style,_that.textPresetId,_that.transform,_that.opacity,_that.time);case TextPathElement() when textPath != null:
return textPath(_that.id,_that.text,_that.path,_that.style,_that.transform,_that.opacity,_that.time);case BrushElement() when brush != null:
return brush(_that.id,_that.brushType,_that.size,_that.color,_that.smoothing,_that.strokes,_that.transform,_that.opacity,_that.time);case StickerElement() when sticker != null:
return sticker(_that.id,_that.assetId,_that.transform,_that.opacity,_that.time);case OverlayElement() when overlay != null:
return overlay(_that.id,_that.assetId,_that.blend,_that.opacity,_that.time);case FrameElement() when frame != null:
return frame(_that.id,_that.assetId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class TextElement implements EditElement {
  const TextElement({required this.id, required this.text, this.style = const TextStyleSpec(), this.textPresetId, this.transform = const ElementTransform(), this.opacity = 1, this.time,  String? $type}): $type = $type ?? 'text';
  factory TextElement.fromJson(Map<String, dynamic> json) => _$TextElementFromJson(json);

@override final  String id;
 final  String text;
@JsonKey() final  TextStyleSpec style;
 final  String? textPresetId;
@JsonKey() final  ElementTransform transform;
@JsonKey() final  double opacity;
 final  TimeRange? time;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextElementCopyWith<TextElement> get copyWith => _$TextElementCopyWithImpl<TextElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextElementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TextElement&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.style, style) || other.style == style)&&(identical(other.textPresetId, textPresetId) || other.textPresetId == textPresetId)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,text,style,textPresetId,transform,opacity,time);
}

@override
String toString() {
    return 'EditElement.text(id: $id, text: $text, style: $style, textPresetId: $textPresetId, transform: $transform, opacity: $opacity, time: $time)';
}


}

/// @nodoc
abstract mixin class $TextElementCopyWith<$Res> implements $EditElementCopyWith<$Res> {
  factory $TextElementCopyWith(TextElement value, $Res Function(TextElement) _then) = _$TextElementCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, TextStyleSpec style, String? textPresetId, ElementTransform transform, double opacity, TimeRange? time
});


$TextStyleSpecCopyWith<$Res> get style;$ElementTransformCopyWith<$Res> get transform;$TimeRangeCopyWith<$Res>? get time;

}
/// @nodoc
class _$TextElementCopyWithImpl<$Res>
    implements $TextElementCopyWith<$Res> {
  _$TextElementCopyWithImpl(this._self, this._then);

  final TextElement _self;
  final $Res Function(TextElement) _then;

/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? style = null,Object? textPresetId = freezed,Object? transform = null,Object? opacity = null,Object? time = freezed,}) {
  return _then(TextElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as TextStyleSpec,textPresetId: freezed == textPresetId ? _self.textPresetId : textPresetId // ignore: cast_nullable_to_non_nullable
as String?,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as ElementTransform,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as TimeRange?,
  ));
}

/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextStyleSpecCopyWith<$Res> get style {
  
  return $TextStyleSpecCopyWith<$Res>(_self.style, (value) {
    return _then(_self.copyWith(style: value));
  });
}/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ElementTransformCopyWith<$Res> get transform {
  
  return $ElementTransformCopyWith<$Res>(_self.transform, (value) {
    return _then(_self.copyWith(transform: value));
  });
}/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimeRangeCopyWith<$Res>? get time {
    if (_self.time == null) {
    return null;
  }

  return $TimeRangeCopyWith<$Res>(_self.time!, (value) {
    return _then(_self.copyWith(time: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class TextPathElement implements EditElement {
  const TextPathElement({required this.id, required this.text, required  List<StrokePoint> path, this.style = const TextStyleSpec(), this.transform = const ElementTransform(), this.opacity = 1, this.time,  String? $type}): _path = path,$type = $type ?? 'textPath';
  factory TextPathElement.fromJson(Map<String, dynamic> json) => _$TextPathElementFromJson(json);

@override final  String id;
 final  String text;
 final  List<StrokePoint> _path;
 List<StrokePoint> get path {
  if (_path is EqualUnmodifiableListView) return _path;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_path);
}

@JsonKey() final  TextStyleSpec style;
@JsonKey() final  ElementTransform transform;
@JsonKey() final  double opacity;
 final  TimeRange? time;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextPathElementCopyWith<TextPathElement> get copyWith => _$TextPathElementCopyWithImpl<TextPathElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextPathElementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TextPathElement&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.path, _path)&&(identical(other.style, style) || other.style == style)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,text,const DeepCollectionEquality().hash(_path),style,transform,opacity,time);
}

@override
String toString() {
    return 'EditElement.textPath(id: $id, text: $text, path: $path, style: $style, transform: $transform, opacity: $opacity, time: $time)';
}


}

/// @nodoc
abstract mixin class $TextPathElementCopyWith<$Res> implements $EditElementCopyWith<$Res> {
  factory $TextPathElementCopyWith(TextPathElement value, $Res Function(TextPathElement) _then) = _$TextPathElementCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, List<StrokePoint> path, TextStyleSpec style, ElementTransform transform, double opacity, TimeRange? time
});


$TextStyleSpecCopyWith<$Res> get style;$ElementTransformCopyWith<$Res> get transform;$TimeRangeCopyWith<$Res>? get time;

}
/// @nodoc
class _$TextPathElementCopyWithImpl<$Res>
    implements $TextPathElementCopyWith<$Res> {
  _$TextPathElementCopyWithImpl(this._self, this._then);

  final TextPathElement _self;
  final $Res Function(TextPathElement) _then;

/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? path = null,Object? style = null,Object? transform = null,Object? opacity = null,Object? time = freezed,}) {
  return _then(TextPathElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self._path : path // ignore: cast_nullable_to_non_nullable
as List<StrokePoint>,style: null == style ? _self.style : style // ignore: cast_nullable_to_non_nullable
as TextStyleSpec,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as ElementTransform,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as TimeRange?,
  ));
}

/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextStyleSpecCopyWith<$Res> get style {
  
  return $TextStyleSpecCopyWith<$Res>(_self.style, (value) {
    return _then(_self.copyWith(style: value));
  });
}/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ElementTransformCopyWith<$Res> get transform {
  
  return $ElementTransformCopyWith<$Res>(_self.transform, (value) {
    return _then(_self.copyWith(transform: value));
  });
}/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimeRangeCopyWith<$Res>? get time {
    if (_self.time == null) {
    return null;
  }

  return $TimeRangeCopyWith<$Res>(_self.time!, (value) {
    return _then(_self.copyWith(time: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class BrushElement implements EditElement {
  const BrushElement({required this.id, this.brushType = BrushType.pen, this.size = 0.01, this.color = 0xFFEFE8DC, this.smoothing = 0.5,  List<BrushStroke> strokes = const <BrushStroke>[], this.transform = const ElementTransform(), this.opacity = 1, this.time,  String? $type}): _strokes = strokes,$type = $type ?? 'brush';
  factory BrushElement.fromJson(Map<String, dynamic> json) => _$BrushElementFromJson(json);

@override final  String id;
@JsonKey() final  BrushType brushType;
@JsonKey() final  double size;
@JsonKey() final  int color;
@JsonKey() final  double smoothing;
 final  List<BrushStroke> _strokes;
@JsonKey() List<BrushStroke> get strokes {
  if (_strokes is EqualUnmodifiableListView) return _strokes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_strokes);
}

@JsonKey() final  ElementTransform transform;
@JsonKey() final  double opacity;
 final  TimeRange? time;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BrushElementCopyWith<BrushElement> get copyWith => _$BrushElementCopyWithImpl<BrushElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BrushElementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BrushElement&&(identical(other.id, id) || other.id == id)&&(identical(other.brushType, brushType) || other.brushType == brushType)&&(identical(other.size, size) || other.size == size)&&(identical(other.color, color) || other.color == color)&&(identical(other.smoothing, smoothing) || other.smoothing == smoothing)&&const DeepCollectionEquality().equals(other.strokes, _strokes)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,brushType,size,color,smoothing,const DeepCollectionEquality().hash(_strokes),transform,opacity,time);
}

@override
String toString() {
    return 'EditElement.brush(id: $id, brushType: $brushType, size: $size, color: $color, smoothing: $smoothing, strokes: $strokes, transform: $transform, opacity: $opacity, time: $time)';
}


}

/// @nodoc
abstract mixin class $BrushElementCopyWith<$Res> implements $EditElementCopyWith<$Res> {
  factory $BrushElementCopyWith(BrushElement value, $Res Function(BrushElement) _then) = _$BrushElementCopyWithImpl;
@override @useResult
$Res call({
 String id, BrushType brushType, double size, int color, double smoothing, List<BrushStroke> strokes, ElementTransform transform, double opacity, TimeRange? time
});


$ElementTransformCopyWith<$Res> get transform;$TimeRangeCopyWith<$Res>? get time;

}
/// @nodoc
class _$BrushElementCopyWithImpl<$Res>
    implements $BrushElementCopyWith<$Res> {
  _$BrushElementCopyWithImpl(this._self, this._then);

  final BrushElement _self;
  final $Res Function(BrushElement) _then;

/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? brushType = null,Object? size = null,Object? color = null,Object? smoothing = null,Object? strokes = null,Object? transform = null,Object? opacity = null,Object? time = freezed,}) {
  return _then(BrushElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,brushType: null == brushType ? _self.brushType : brushType // ignore: cast_nullable_to_non_nullable
as BrushType,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,smoothing: null == smoothing ? _self.smoothing : smoothing // ignore: cast_nullable_to_non_nullable
as double,strokes: null == strokes ? _self._strokes : strokes // ignore: cast_nullable_to_non_nullable
as List<BrushStroke>,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as ElementTransform,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as TimeRange?,
  ));
}

/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ElementTransformCopyWith<$Res> get transform {
  
  return $ElementTransformCopyWith<$Res>(_self.transform, (value) {
    return _then(_self.copyWith(transform: value));
  });
}/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimeRangeCopyWith<$Res>? get time {
    if (_self.time == null) {
    return null;
  }

  return $TimeRangeCopyWith<$Res>(_self.time!, (value) {
    return _then(_self.copyWith(time: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class StickerElement implements EditElement {
  const StickerElement({required this.id, required this.assetId, this.transform = const ElementTransform(), this.opacity = 1, this.time,  String? $type}): $type = $type ?? 'sticker';
  factory StickerElement.fromJson(Map<String, dynamic> json) => _$StickerElementFromJson(json);

@override final  String id;
 final  String assetId;
@JsonKey() final  ElementTransform transform;
@JsonKey() final  double opacity;
 final  TimeRange? time;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StickerElementCopyWith<StickerElement> get copyWith => _$StickerElementCopyWithImpl<StickerElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StickerElementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is StickerElement&&(identical(other.id, id) || other.id == id)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.transform, transform) || other.transform == transform)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,assetId,transform,opacity,time);
}

@override
String toString() {
    return 'EditElement.sticker(id: $id, assetId: $assetId, transform: $transform, opacity: $opacity, time: $time)';
}


}

/// @nodoc
abstract mixin class $StickerElementCopyWith<$Res> implements $EditElementCopyWith<$Res> {
  factory $StickerElementCopyWith(StickerElement value, $Res Function(StickerElement) _then) = _$StickerElementCopyWithImpl;
@override @useResult
$Res call({
 String id, String assetId, ElementTransform transform, double opacity, TimeRange? time
});


$ElementTransformCopyWith<$Res> get transform;$TimeRangeCopyWith<$Res>? get time;

}
/// @nodoc
class _$StickerElementCopyWithImpl<$Res>
    implements $StickerElementCopyWith<$Res> {
  _$StickerElementCopyWithImpl(this._self, this._then);

  final StickerElement _self;
  final $Res Function(StickerElement) _then;

/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetId = null,Object? transform = null,Object? opacity = null,Object? time = freezed,}) {
  return _then(StickerElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,transform: null == transform ? _self.transform : transform // ignore: cast_nullable_to_non_nullable
as ElementTransform,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as TimeRange?,
  ));
}

/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ElementTransformCopyWith<$Res> get transform {
  
  return $ElementTransformCopyWith<$Res>(_self.transform, (value) {
    return _then(_self.copyWith(transform: value));
  });
}/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimeRangeCopyWith<$Res>? get time {
    if (_self.time == null) {
    return null;
  }

  return $TimeRangeCopyWith<$Res>(_self.time!, (value) {
    return _then(_self.copyWith(time: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class OverlayElement implements EditElement {
  const OverlayElement({required this.id, required this.assetId, this.blend = OverlayBlend.screen, this.opacity = 1, this.time,  String? $type}): $type = $type ?? 'overlay';
  factory OverlayElement.fromJson(Map<String, dynamic> json) => _$OverlayElementFromJson(json);

@override final  String id;
 final  String assetId;
@JsonKey() final  OverlayBlend blend;
@JsonKey() final  double opacity;
 final  TimeRange? time;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OverlayElementCopyWith<OverlayElement> get copyWith => _$OverlayElementCopyWithImpl<OverlayElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OverlayElementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OverlayElement&&(identical(other.id, id) || other.id == id)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.blend, blend) || other.blend == blend)&&(identical(other.opacity, opacity) || other.opacity == opacity)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,assetId,blend,opacity,time);
}

@override
String toString() {
    return 'EditElement.overlay(id: $id, assetId: $assetId, blend: $blend, opacity: $opacity, time: $time)';
}


}

/// @nodoc
abstract mixin class $OverlayElementCopyWith<$Res> implements $EditElementCopyWith<$Res> {
  factory $OverlayElementCopyWith(OverlayElement value, $Res Function(OverlayElement) _then) = _$OverlayElementCopyWithImpl;
@override @useResult
$Res call({
 String id, String assetId, OverlayBlend blend, double opacity, TimeRange? time
});


$TimeRangeCopyWith<$Res>? get time;

}
/// @nodoc
class _$OverlayElementCopyWithImpl<$Res>
    implements $OverlayElementCopyWith<$Res> {
  _$OverlayElementCopyWithImpl(this._self, this._then);

  final OverlayElement _self;
  final $Res Function(OverlayElement) _then;

/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetId = null,Object? blend = null,Object? opacity = null,Object? time = freezed,}) {
  return _then(OverlayElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,blend: null == blend ? _self.blend : blend // ignore: cast_nullable_to_non_nullable
as OverlayBlend,opacity: null == opacity ? _self.opacity : opacity // ignore: cast_nullable_to_non_nullable
as double,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as TimeRange?,
  ));
}

/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TimeRangeCopyWith<$Res>? get time {
    if (_self.time == null) {
    return null;
  }

  return $TimeRangeCopyWith<$Res>(_self.time!, (value) {
    return _then(_self.copyWith(time: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class FrameElement implements EditElement {
  const FrameElement({required this.id, required this.assetId,  String? $type}): $type = $type ?? 'frame';
  factory FrameElement.fromJson(Map<String, dynamic> json) => _$FrameElementFromJson(json);

@override final  String id;
 final  String assetId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FrameElementCopyWith<FrameElement> get copyWith => _$FrameElementCopyWithImpl<FrameElement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FrameElementToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FrameElement&&(identical(other.id, id) || other.id == id)&&(identical(other.assetId, assetId) || other.assetId == assetId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,assetId);
}

@override
String toString() {
    return 'EditElement.frame(id: $id, assetId: $assetId)';
}


}

/// @nodoc
abstract mixin class $FrameElementCopyWith<$Res> implements $EditElementCopyWith<$Res> {
  factory $FrameElementCopyWith(FrameElement value, $Res Function(FrameElement) _then) = _$FrameElementCopyWithImpl;
@override @useResult
$Res call({
 String id, String assetId
});




}
/// @nodoc
class _$FrameElementCopyWithImpl<$Res>
    implements $FrameElementCopyWith<$Res> {
  _$FrameElementCopyWithImpl(this._self, this._then);

  final FrameElement _self;
  final $Res Function(FrameElement) _then;

/// Create a copy of EditElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetId = null,}) {
  return _then(FrameElement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
