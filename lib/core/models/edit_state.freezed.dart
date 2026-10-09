// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EditState {

 Adjustments get adjustments; ToneCurves get curves; PresetRef? get preset; CropTransform get crop; List<EditElement> get elements;/// Only for video projects.
 VideoTimeline? get video;
/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditStateCopyWith<EditState> get copyWith => _$EditStateCopyWithImpl<EditState>(this as EditState, _$identity);

  /// Serializes this EditState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EditState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditState&&(identical(other.adjustments, _this.adjustments) || other.adjustments == _this.adjustments)&&(identical(other.curves, _this.curves) || other.curves == _this.curves)&&(identical(other.preset, _this.preset) || other.preset == _this.preset)&&(identical(other.crop, _this.crop) || other.crop == _this.crop)&&const DeepCollectionEquality().equals(other.elements, _this.elements)&&(identical(other.video, _this.video) || other.video == _this.video));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EditState;
  return Object.hash(runtimeType,_this.adjustments,_this.curves,_this.preset,_this.crop,const DeepCollectionEquality().hash(_this.elements),_this.video);
}

@override
String toString() {
  final _this = this as EditState;
  return 'EditState(adjustments: ${_this.adjustments}, curves: ${_this.curves}, preset: ${_this.preset}, crop: ${_this.crop}, elements: ${_this.elements}, video: ${_this.video})';
}


}

/// @nodoc
abstract mixin class $EditStateCopyWith<$Res>  {
  factory $EditStateCopyWith(EditState value, $Res Function(EditState) _then) = _$EditStateCopyWithImpl;
@useResult
$Res call({
 Adjustments adjustments, ToneCurves curves, PresetRef? preset, CropTransform crop, List<EditElement> elements, VideoTimeline? video
});


$ToneCurvesCopyWith<$Res> get curves;$PresetRefCopyWith<$Res>? get preset;$CropTransformCopyWith<$Res> get crop;$VideoTimelineCopyWith<$Res>? get video;

}
/// @nodoc
class _$EditStateCopyWithImpl<$Res>
    implements $EditStateCopyWith<$Res> {
  _$EditStateCopyWithImpl(this._self, this._then);

  final EditState _self;
  final $Res Function(EditState) _then;

/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? adjustments = null,Object? curves = null,Object? preset = freezed,Object? crop = null,Object? elements = null,Object? video = freezed,}) {
  return _then(EditState(
adjustments: null == adjustments ? _self.adjustments : adjustments // ignore: cast_nullable_to_non_nullable
as Adjustments,curves: null == curves ? _self.curves : curves // ignore: cast_nullable_to_non_nullable
as ToneCurves,preset: freezed == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as PresetRef?,crop: null == crop ? _self.crop : crop // ignore: cast_nullable_to_non_nullable
as CropTransform,elements: null == elements ? _self.elements : elements // ignore: cast_nullable_to_non_nullable
as List<EditElement>,video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as VideoTimeline?,
  ));
}
/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurvesCopyWith<$Res> get curves {
  
  return $ToneCurvesCopyWith<$Res>(_self.curves, (value) {
    return _then(_self.copyWith(curves: value));
  });
}/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresetRefCopyWith<$Res>? get preset {
    if (_self.preset == null) {
    return null;
  }

  return $PresetRefCopyWith<$Res>(_self.preset!, (value) {
    return _then(_self.copyWith(preset: value));
  });
}/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CropTransformCopyWith<$Res> get crop {
  
  return $CropTransformCopyWith<$Res>(_self.crop, (value) {
    return _then(_self.copyWith(crop: value));
  });
}/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoTimelineCopyWith<$Res>? get video {
    if (_self.video == null) {
    return null;
  }

  return $VideoTimelineCopyWith<$Res>(_self.video!, (value) {
    return _then(_self.copyWith(video: value));
  });
}
}


/// Adds pattern-matching-related methods to [EditState].
extension EditStatePatterns on EditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditState value)  $default,){
final _that = this;
switch (_that) {
case _EditState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditState value)?  $default,){
final _that = this;
switch (_that) {
case _EditState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Adjustments adjustments,  ToneCurves curves,  PresetRef? preset,  CropTransform crop,  List<EditElement> elements,  VideoTimeline? video)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditState() when $default != null:
return $default(_that.adjustments,_that.curves,_that.preset,_that.crop,_that.elements,_that.video);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Adjustments adjustments,  ToneCurves curves,  PresetRef? preset,  CropTransform crop,  List<EditElement> elements,  VideoTimeline? video)  $default,) {final _that = this;
switch (_that) {
case _EditState():
return $default(_that.adjustments,_that.curves,_that.preset,_that.crop,_that.elements,_that.video);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Adjustments adjustments,  ToneCurves curves,  PresetRef? preset,  CropTransform crop,  List<EditElement> elements,  VideoTimeline? video)?  $default,) {final _that = this;
switch (_that) {
case _EditState() when $default != null:
return $default(_that.adjustments,_that.curves,_that.preset,_that.crop,_that.elements,_that.video);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EditState extends EditState {
  const _EditState({this.adjustments = const Adjustments(), this.curves = const ToneCurves(), this.preset, this.crop = const CropTransform(),  List<EditElement> elements = const <EditElement>[], this.video}): _elements = elements,super._();
  factory _EditState.fromJson(Map<String, dynamic> json) => _$EditStateFromJson(json);

@override@JsonKey() final  Adjustments adjustments;
@override@JsonKey() final  ToneCurves curves;
@override final  PresetRef? preset;
@override@JsonKey() final  CropTransform crop;
 final  List<EditElement> _elements;
@override@JsonKey() List<EditElement> get elements {
  if (_elements is EqualUnmodifiableListView) return _elements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_elements);
}

/// Only for video projects.
@override final  VideoTimeline? video;

/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditStateCopyWith<_EditState> get copyWith => __$EditStateCopyWithImpl<_EditState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EditStateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditState&&(identical(other.adjustments, adjustments) || other.adjustments == adjustments)&&(identical(other.curves, curves) || other.curves == curves)&&(identical(other.preset, preset) || other.preset == preset)&&(identical(other.crop, crop) || other.crop == crop)&&const DeepCollectionEquality().equals(other.elements, _elements)&&(identical(other.video, video) || other.video == video));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,adjustments,curves,preset,crop,const DeepCollectionEquality().hash(_elements),video);
}

@override
String toString() {
    return 'EditState(adjustments: $adjustments, curves: $curves, preset: $preset, crop: $crop, elements: $elements, video: $video)';
}


}

/// @nodoc
abstract mixin class _$EditStateCopyWith<$Res> implements $EditStateCopyWith<$Res> {
  factory _$EditStateCopyWith(_EditState value, $Res Function(_EditState) _then) = __$EditStateCopyWithImpl;
@override @useResult
$Res call({
 Adjustments adjustments, ToneCurves curves, PresetRef? preset, CropTransform crop, List<EditElement> elements, VideoTimeline? video
});


@override $ToneCurvesCopyWith<$Res> get curves;@override $PresetRefCopyWith<$Res>? get preset;@override $CropTransformCopyWith<$Res> get crop;@override $VideoTimelineCopyWith<$Res>? get video;

}
/// @nodoc
class __$EditStateCopyWithImpl<$Res>
    implements _$EditStateCopyWith<$Res> {
  __$EditStateCopyWithImpl(this._self, this._then);

  final _EditState _self;
  final $Res Function(_EditState) _then;

/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? adjustments = null,Object? curves = null,Object? preset = freezed,Object? crop = null,Object? elements = null,Object? video = freezed,}) {
  return _then(_EditState(
adjustments: null == adjustments ? _self.adjustments : adjustments // ignore: cast_nullable_to_non_nullable
as Adjustments,curves: null == curves ? _self.curves : curves // ignore: cast_nullable_to_non_nullable
as ToneCurves,preset: freezed == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as PresetRef?,crop: null == crop ? _self.crop : crop // ignore: cast_nullable_to_non_nullable
as CropTransform,elements: null == elements ? _self._elements : elements // ignore: cast_nullable_to_non_nullable
as List<EditElement>,video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as VideoTimeline?,
  ));
}

/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurvesCopyWith<$Res> get curves {
  
  return $ToneCurvesCopyWith<$Res>(_self.curves, (value) {
    return _then(_self.copyWith(curves: value));
  });
}/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresetRefCopyWith<$Res>? get preset {
    if (_self.preset == null) {
    return null;
  }

  return $PresetRefCopyWith<$Res>(_self.preset!, (value) {
    return _then(_self.copyWith(preset: value));
  });
}/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CropTransformCopyWith<$Res> get crop {
  
  return $CropTransformCopyWith<$Res>(_self.crop, (value) {
    return _then(_self.copyWith(crop: value));
  });
}/// Create a copy of EditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoTimelineCopyWith<$Res>? get video {
    if (_self.video == null) {
    return null;
  }

  return $VideoTimelineCopyWith<$Res>(_self.video!, (value) {
    return _then(_self.copyWith(video: value));
  });
}
}


/// @nodoc
mixin _$CopiedEdits {

 Adjustments get adjustments; ToneCurves get curves; PresetRef? get preset;
/// Create a copy of CopiedEdits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CopiedEditsCopyWith<CopiedEdits> get copyWith => _$CopiedEditsCopyWithImpl<CopiedEdits>(this as CopiedEdits, _$identity);

  /// Serializes this CopiedEdits to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CopiedEdits;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CopiedEdits&&(identical(other.adjustments, _this.adjustments) || other.adjustments == _this.adjustments)&&(identical(other.curves, _this.curves) || other.curves == _this.curves)&&(identical(other.preset, _this.preset) || other.preset == _this.preset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CopiedEdits;
  return Object.hash(runtimeType,_this.adjustments,_this.curves,_this.preset);
}

@override
String toString() {
  final _this = this as CopiedEdits;
  return 'CopiedEdits(adjustments: ${_this.adjustments}, curves: ${_this.curves}, preset: ${_this.preset})';
}


}

/// @nodoc
abstract mixin class $CopiedEditsCopyWith<$Res>  {
  factory $CopiedEditsCopyWith(CopiedEdits value, $Res Function(CopiedEdits) _then) = _$CopiedEditsCopyWithImpl;
@useResult
$Res call({
 Adjustments adjustments, ToneCurves curves, PresetRef? preset
});


$ToneCurvesCopyWith<$Res> get curves;$PresetRefCopyWith<$Res>? get preset;

}
/// @nodoc
class _$CopiedEditsCopyWithImpl<$Res>
    implements $CopiedEditsCopyWith<$Res> {
  _$CopiedEditsCopyWithImpl(this._self, this._then);

  final CopiedEdits _self;
  final $Res Function(CopiedEdits) _then;

/// Create a copy of CopiedEdits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? adjustments = null,Object? curves = null,Object? preset = freezed,}) {
  return _then(CopiedEdits(
adjustments: null == adjustments ? _self.adjustments : adjustments // ignore: cast_nullable_to_non_nullable
as Adjustments,curves: null == curves ? _self.curves : curves // ignore: cast_nullable_to_non_nullable
as ToneCurves,preset: freezed == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as PresetRef?,
  ));
}
/// Create a copy of CopiedEdits
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurvesCopyWith<$Res> get curves {
  
  return $ToneCurvesCopyWith<$Res>(_self.curves, (value) {
    return _then(_self.copyWith(curves: value));
  });
}/// Create a copy of CopiedEdits
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresetRefCopyWith<$Res>? get preset {
    if (_self.preset == null) {
    return null;
  }

  return $PresetRefCopyWith<$Res>(_self.preset!, (value) {
    return _then(_self.copyWith(preset: value));
  });
}
}


/// Adds pattern-matching-related methods to [CopiedEdits].
extension CopiedEditsPatterns on CopiedEdits {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CopiedEdits value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CopiedEdits() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CopiedEdits value)  $default,){
final _that = this;
switch (_that) {
case _CopiedEdits():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CopiedEdits value)?  $default,){
final _that = this;
switch (_that) {
case _CopiedEdits() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Adjustments adjustments,  ToneCurves curves,  PresetRef? preset)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CopiedEdits() when $default != null:
return $default(_that.adjustments,_that.curves,_that.preset);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Adjustments adjustments,  ToneCurves curves,  PresetRef? preset)  $default,) {final _that = this;
switch (_that) {
case _CopiedEdits():
return $default(_that.adjustments,_that.curves,_that.preset);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Adjustments adjustments,  ToneCurves curves,  PresetRef? preset)?  $default,) {final _that = this;
switch (_that) {
case _CopiedEdits() when $default != null:
return $default(_that.adjustments,_that.curves,_that.preset);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CopiedEdits implements CopiedEdits {
  const _CopiedEdits({this.adjustments = const Adjustments(), this.curves = const ToneCurves(), this.preset});
  factory _CopiedEdits.fromJson(Map<String, dynamic> json) => _$CopiedEditsFromJson(json);

@override@JsonKey() final  Adjustments adjustments;
@override@JsonKey() final  ToneCurves curves;
@override final  PresetRef? preset;

/// Create a copy of CopiedEdits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CopiedEditsCopyWith<_CopiedEdits> get copyWith => __$CopiedEditsCopyWithImpl<_CopiedEdits>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CopiedEditsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CopiedEdits&&(identical(other.adjustments, adjustments) || other.adjustments == adjustments)&&(identical(other.curves, curves) || other.curves == curves)&&(identical(other.preset, preset) || other.preset == preset));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,adjustments,curves,preset);
}

@override
String toString() {
    return 'CopiedEdits(adjustments: $adjustments, curves: $curves, preset: $preset)';
}


}

/// @nodoc
abstract mixin class _$CopiedEditsCopyWith<$Res> implements $CopiedEditsCopyWith<$Res> {
  factory _$CopiedEditsCopyWith(_CopiedEdits value, $Res Function(_CopiedEdits) _then) = __$CopiedEditsCopyWithImpl;
@override @useResult
$Res call({
 Adjustments adjustments, ToneCurves curves, PresetRef? preset
});


@override $ToneCurvesCopyWith<$Res> get curves;@override $PresetRefCopyWith<$Res>? get preset;

}
/// @nodoc
class __$CopiedEditsCopyWithImpl<$Res>
    implements _$CopiedEditsCopyWith<$Res> {
  __$CopiedEditsCopyWithImpl(this._self, this._then);

  final _CopiedEdits _self;
  final $Res Function(_CopiedEdits) _then;

/// Create a copy of CopiedEdits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? adjustments = null,Object? curves = null,Object? preset = freezed,}) {
  return _then(_CopiedEdits(
adjustments: null == adjustments ? _self.adjustments : adjustments // ignore: cast_nullable_to_non_nullable
as Adjustments,curves: null == curves ? _self.curves : curves // ignore: cast_nullable_to_non_nullable
as ToneCurves,preset: freezed == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as PresetRef?,
  ));
}

/// Create a copy of CopiedEdits
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurvesCopyWith<$Res> get curves {
  
  return $ToneCurvesCopyWith<$Res>(_self.curves, (value) {
    return _then(_self.copyWith(curves: value));
  });
}/// Create a copy of CopiedEdits
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresetRefCopyWith<$Res>? get preset {
    if (_self.preset == null) {
    return null;
  }

  return $PresetRefCopyWith<$Res>(_self.preset!, (value) {
    return _then(_self.copyWith(preset: value));
  });
}
}

// dart format on
