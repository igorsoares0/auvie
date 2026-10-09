// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'crop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NormalizedRect {

 double get left; double get top; double get width; double get height;
/// Create a copy of NormalizedRect
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NormalizedRectCopyWith<NormalizedRect> get copyWith => _$NormalizedRectCopyWithImpl<NormalizedRect>(this as NormalizedRect, _$identity);

  /// Serializes this NormalizedRect to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NormalizedRect;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NormalizedRect&&(identical(other.left, _this.left) || other.left == _this.left)&&(identical(other.top, _this.top) || other.top == _this.top)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NormalizedRect;
  return Object.hash(runtimeType,_this.left,_this.top,_this.width,_this.height);
}

@override
String toString() {
  final _this = this as NormalizedRect;
  return 'NormalizedRect(left: ${_this.left}, top: ${_this.top}, width: ${_this.width}, height: ${_this.height})';
}


}

/// @nodoc
abstract mixin class $NormalizedRectCopyWith<$Res>  {
  factory $NormalizedRectCopyWith(NormalizedRect value, $Res Function(NormalizedRect) _then) = _$NormalizedRectCopyWithImpl;
@useResult
$Res call({
 double left, double top, double width, double height
});




}
/// @nodoc
class _$NormalizedRectCopyWithImpl<$Res>
    implements $NormalizedRectCopyWith<$Res> {
  _$NormalizedRectCopyWithImpl(this._self, this._then);

  final NormalizedRect _self;
  final $Res Function(NormalizedRect) _then;

/// Create a copy of NormalizedRect
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? left = null,Object? top = null,Object? width = null,Object? height = null,}) {
  return _then(NormalizedRect(
left: null == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as double,top: null == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [NormalizedRect].
extension NormalizedRectPatterns on NormalizedRect {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NormalizedRect value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NormalizedRect() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NormalizedRect value)  $default,){
final _that = this;
switch (_that) {
case _NormalizedRect():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NormalizedRect value)?  $default,){
final _that = this;
switch (_that) {
case _NormalizedRect() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double left,  double top,  double width,  double height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NormalizedRect() when $default != null:
return $default(_that.left,_that.top,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double left,  double top,  double width,  double height)  $default,) {final _that = this;
switch (_that) {
case _NormalizedRect():
return $default(_that.left,_that.top,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double left,  double top,  double width,  double height)?  $default,) {final _that = this;
switch (_that) {
case _NormalizedRect() when $default != null:
return $default(_that.left,_that.top,_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NormalizedRect extends NormalizedRect {
  const _NormalizedRect({this.left = 0, this.top = 0, this.width = 1, this.height = 1}): super._();
  factory _NormalizedRect.fromJson(Map<String, dynamic> json) => _$NormalizedRectFromJson(json);

@override@JsonKey() final  double left;
@override@JsonKey() final  double top;
@override@JsonKey() final  double width;
@override@JsonKey() final  double height;

/// Create a copy of NormalizedRect
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NormalizedRectCopyWith<_NormalizedRect> get copyWith => __$NormalizedRectCopyWithImpl<_NormalizedRect>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NormalizedRectToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NormalizedRect&&(identical(other.left, left) || other.left == left)&&(identical(other.top, top) || other.top == top)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,left,top,width,height);
}

@override
String toString() {
    return 'NormalizedRect(left: $left, top: $top, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$NormalizedRectCopyWith<$Res> implements $NormalizedRectCopyWith<$Res> {
  factory _$NormalizedRectCopyWith(_NormalizedRect value, $Res Function(_NormalizedRect) _then) = __$NormalizedRectCopyWithImpl;
@override @useResult
$Res call({
 double left, double top, double width, double height
});




}
/// @nodoc
class __$NormalizedRectCopyWithImpl<$Res>
    implements _$NormalizedRectCopyWith<$Res> {
  __$NormalizedRectCopyWithImpl(this._self, this._then);

  final _NormalizedRect _self;
  final $Res Function(_NormalizedRect) _then;

/// Create a copy of NormalizedRect
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? left = null,Object? top = null,Object? width = null,Object? height = null,}) {
  return _then(_NormalizedRect(
left: null == left ? _self.left : left // ignore: cast_nullable_to_non_nullable
as double,top: null == top ? _self.top : top // ignore: cast_nullable_to_non_nullable
as double,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$CropTransform {

 CropAspect get aspect;/// Crop area in the media after [quarterTurns] are applied.
 NormalizedRect get rect;/// Clockwise 90° turns, 0…3.
 int get quarterTurns;/// Fine rotation in degrees, −45…45.
 double get straighten; bool get flipHorizontal; bool get flipVertical;
/// Create a copy of CropTransform
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CropTransformCopyWith<CropTransform> get copyWith => _$CropTransformCopyWithImpl<CropTransform>(this as CropTransform, _$identity);

  /// Serializes this CropTransform to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CropTransform;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CropTransform&&(identical(other.aspect, _this.aspect) || other.aspect == _this.aspect)&&(identical(other.rect, _this.rect) || other.rect == _this.rect)&&(identical(other.quarterTurns, _this.quarterTurns) || other.quarterTurns == _this.quarterTurns)&&(identical(other.straighten, _this.straighten) || other.straighten == _this.straighten)&&(identical(other.flipHorizontal, _this.flipHorizontal) || other.flipHorizontal == _this.flipHorizontal)&&(identical(other.flipVertical, _this.flipVertical) || other.flipVertical == _this.flipVertical));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CropTransform;
  return Object.hash(runtimeType,_this.aspect,_this.rect,_this.quarterTurns,_this.straighten,_this.flipHorizontal,_this.flipVertical);
}

@override
String toString() {
  final _this = this as CropTransform;
  return 'CropTransform(aspect: ${_this.aspect}, rect: ${_this.rect}, quarterTurns: ${_this.quarterTurns}, straighten: ${_this.straighten}, flipHorizontal: ${_this.flipHorizontal}, flipVertical: ${_this.flipVertical})';
}


}

/// @nodoc
abstract mixin class $CropTransformCopyWith<$Res>  {
  factory $CropTransformCopyWith(CropTransform value, $Res Function(CropTransform) _then) = _$CropTransformCopyWithImpl;
@useResult
$Res call({
 CropAspect aspect, NormalizedRect rect, int quarterTurns, double straighten, bool flipHorizontal, bool flipVertical
});


$NormalizedRectCopyWith<$Res> get rect;

}
/// @nodoc
class _$CropTransformCopyWithImpl<$Res>
    implements $CropTransformCopyWith<$Res> {
  _$CropTransformCopyWithImpl(this._self, this._then);

  final CropTransform _self;
  final $Res Function(CropTransform) _then;

/// Create a copy of CropTransform
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? aspect = null,Object? rect = null,Object? quarterTurns = null,Object? straighten = null,Object? flipHorizontal = null,Object? flipVertical = null,}) {
  return _then(CropTransform(
aspect: null == aspect ? _self.aspect : aspect // ignore: cast_nullable_to_non_nullable
as CropAspect,rect: null == rect ? _self.rect : rect // ignore: cast_nullable_to_non_nullable
as NormalizedRect,quarterTurns: null == quarterTurns ? _self.quarterTurns : quarterTurns // ignore: cast_nullable_to_non_nullable
as int,straighten: null == straighten ? _self.straighten : straighten // ignore: cast_nullable_to_non_nullable
as double,flipHorizontal: null == flipHorizontal ? _self.flipHorizontal : flipHorizontal // ignore: cast_nullable_to_non_nullable
as bool,flipVertical: null == flipVertical ? _self.flipVertical : flipVertical // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of CropTransform
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NormalizedRectCopyWith<$Res> get rect {
  
  return $NormalizedRectCopyWith<$Res>(_self.rect, (value) {
    return _then(_self.copyWith(rect: value));
  });
}
}


/// Adds pattern-matching-related methods to [CropTransform].
extension CropTransformPatterns on CropTransform {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CropTransform value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CropTransform() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CropTransform value)  $default,){
final _that = this;
switch (_that) {
case _CropTransform():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CropTransform value)?  $default,){
final _that = this;
switch (_that) {
case _CropTransform() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CropAspect aspect,  NormalizedRect rect,  int quarterTurns,  double straighten,  bool flipHorizontal,  bool flipVertical)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CropTransform() when $default != null:
return $default(_that.aspect,_that.rect,_that.quarterTurns,_that.straighten,_that.flipHorizontal,_that.flipVertical);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CropAspect aspect,  NormalizedRect rect,  int quarterTurns,  double straighten,  bool flipHorizontal,  bool flipVertical)  $default,) {final _that = this;
switch (_that) {
case _CropTransform():
return $default(_that.aspect,_that.rect,_that.quarterTurns,_that.straighten,_that.flipHorizontal,_that.flipVertical);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CropAspect aspect,  NormalizedRect rect,  int quarterTurns,  double straighten,  bool flipHorizontal,  bool flipVertical)?  $default,) {final _that = this;
switch (_that) {
case _CropTransform() when $default != null:
return $default(_that.aspect,_that.rect,_that.quarterTurns,_that.straighten,_that.flipHorizontal,_that.flipVertical);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CropTransform extends CropTransform {
  const _CropTransform({this.aspect = CropAspect.original, this.rect = NormalizedRect.full, this.quarterTurns = 0, this.straighten = 0, this.flipHorizontal = false, this.flipVertical = false}): super._();
  factory _CropTransform.fromJson(Map<String, dynamic> json) => _$CropTransformFromJson(json);

@override@JsonKey() final  CropAspect aspect;
/// Crop area in the media after [quarterTurns] are applied.
@override@JsonKey() final  NormalizedRect rect;
/// Clockwise 90° turns, 0…3.
@override@JsonKey() final  int quarterTurns;
/// Fine rotation in degrees, −45…45.
@override@JsonKey() final  double straighten;
@override@JsonKey() final  bool flipHorizontal;
@override@JsonKey() final  bool flipVertical;

/// Create a copy of CropTransform
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CropTransformCopyWith<_CropTransform> get copyWith => __$CropTransformCopyWithImpl<_CropTransform>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CropTransformToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CropTransform&&(identical(other.aspect, aspect) || other.aspect == aspect)&&(identical(other.rect, rect) || other.rect == rect)&&(identical(other.quarterTurns, quarterTurns) || other.quarterTurns == quarterTurns)&&(identical(other.straighten, straighten) || other.straighten == straighten)&&(identical(other.flipHorizontal, flipHorizontal) || other.flipHorizontal == flipHorizontal)&&(identical(other.flipVertical, flipVertical) || other.flipVertical == flipVertical));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,aspect,rect,quarterTurns,straighten,flipHorizontal,flipVertical);
}

@override
String toString() {
    return 'CropTransform(aspect: $aspect, rect: $rect, quarterTurns: $quarterTurns, straighten: $straighten, flipHorizontal: $flipHorizontal, flipVertical: $flipVertical)';
}


}

/// @nodoc
abstract mixin class _$CropTransformCopyWith<$Res> implements $CropTransformCopyWith<$Res> {
  factory _$CropTransformCopyWith(_CropTransform value, $Res Function(_CropTransform) _then) = __$CropTransformCopyWithImpl;
@override @useResult
$Res call({
 CropAspect aspect, NormalizedRect rect, int quarterTurns, double straighten, bool flipHorizontal, bool flipVertical
});


@override $NormalizedRectCopyWith<$Res> get rect;

}
/// @nodoc
class __$CropTransformCopyWithImpl<$Res>
    implements _$CropTransformCopyWith<$Res> {
  __$CropTransformCopyWithImpl(this._self, this._then);

  final _CropTransform _self;
  final $Res Function(_CropTransform) _then;

/// Create a copy of CropTransform
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? aspect = null,Object? rect = null,Object? quarterTurns = null,Object? straighten = null,Object? flipHorizontal = null,Object? flipVertical = null,}) {
  return _then(_CropTransform(
aspect: null == aspect ? _self.aspect : aspect // ignore: cast_nullable_to_non_nullable
as CropAspect,rect: null == rect ? _self.rect : rect // ignore: cast_nullable_to_non_nullable
as NormalizedRect,quarterTurns: null == quarterTurns ? _self.quarterTurns : quarterTurns // ignore: cast_nullable_to_non_nullable
as int,straighten: null == straighten ? _self.straighten : straighten // ignore: cast_nullable_to_non_nullable
as double,flipHorizontal: null == flipHorizontal ? _self.flipHorizontal : flipHorizontal // ignore: cast_nullable_to_non_nullable
as bool,flipVertical: null == flipVertical ? _self.flipVertical : flipVertical // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of CropTransform
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NormalizedRectCopyWith<$Res> get rect {
  
  return $NormalizedRectCopyWith<$Res>(_self.rect, (value) {
    return _then(_self.copyWith(rect: value));
  });
}
}

// dart format on
