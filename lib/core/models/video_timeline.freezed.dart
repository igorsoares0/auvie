// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_timeline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoTimeline {

 int get trimStartMs;/// Null means the end of the clip.
 int? get trimEndMs; bool get muted;
/// Create a copy of VideoTimeline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoTimelineCopyWith<VideoTimeline> get copyWith => _$VideoTimelineCopyWithImpl<VideoTimeline>(this as VideoTimeline, _$identity);

  /// Serializes this VideoTimeline to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VideoTimeline;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoTimeline&&(identical(other.trimStartMs, _this.trimStartMs) || other.trimStartMs == _this.trimStartMs)&&(identical(other.trimEndMs, _this.trimEndMs) || other.trimEndMs == _this.trimEndMs)&&(identical(other.muted, _this.muted) || other.muted == _this.muted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VideoTimeline;
  return Object.hash(runtimeType,_this.trimStartMs,_this.trimEndMs,_this.muted);
}

@override
String toString() {
  final _this = this as VideoTimeline;
  return 'VideoTimeline(trimStartMs: ${_this.trimStartMs}, trimEndMs: ${_this.trimEndMs}, muted: ${_this.muted})';
}


}

/// @nodoc
abstract mixin class $VideoTimelineCopyWith<$Res>  {
  factory $VideoTimelineCopyWith(VideoTimeline value, $Res Function(VideoTimeline) _then) = _$VideoTimelineCopyWithImpl;
@useResult
$Res call({
 int trimStartMs, int? trimEndMs, bool muted
});




}
/// @nodoc
class _$VideoTimelineCopyWithImpl<$Res>
    implements $VideoTimelineCopyWith<$Res> {
  _$VideoTimelineCopyWithImpl(this._self, this._then);

  final VideoTimeline _self;
  final $Res Function(VideoTimeline) _then;

/// Create a copy of VideoTimeline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trimStartMs = null,Object? trimEndMs = freezed,Object? muted = null,}) {
  return _then(VideoTimeline(
trimStartMs: null == trimStartMs ? _self.trimStartMs : trimStartMs // ignore: cast_nullable_to_non_nullable
as int,trimEndMs: freezed == trimEndMs ? _self.trimEndMs : trimEndMs // ignore: cast_nullable_to_non_nullable
as int?,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoTimeline].
extension VideoTimelinePatterns on VideoTimeline {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoTimeline value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoTimeline() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoTimeline value)  $default,){
final _that = this;
switch (_that) {
case _VideoTimeline():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoTimeline value)?  $default,){
final _that = this;
switch (_that) {
case _VideoTimeline() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int trimStartMs,  int? trimEndMs,  bool muted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoTimeline() when $default != null:
return $default(_that.trimStartMs,_that.trimEndMs,_that.muted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int trimStartMs,  int? trimEndMs,  bool muted)  $default,) {final _that = this;
switch (_that) {
case _VideoTimeline():
return $default(_that.trimStartMs,_that.trimEndMs,_that.muted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int trimStartMs,  int? trimEndMs,  bool muted)?  $default,) {final _that = this;
switch (_that) {
case _VideoTimeline() when $default != null:
return $default(_that.trimStartMs,_that.trimEndMs,_that.muted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoTimeline extends VideoTimeline {
  const _VideoTimeline({this.trimStartMs = 0, this.trimEndMs, this.muted = false}): super._();
  factory _VideoTimeline.fromJson(Map<String, dynamic> json) => _$VideoTimelineFromJson(json);

@override@JsonKey() final  int trimStartMs;
/// Null means the end of the clip.
@override final  int? trimEndMs;
@override@JsonKey() final  bool muted;

/// Create a copy of VideoTimeline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoTimelineCopyWith<_VideoTimeline> get copyWith => __$VideoTimelineCopyWithImpl<_VideoTimeline>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoTimelineToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoTimeline&&(identical(other.trimStartMs, trimStartMs) || other.trimStartMs == trimStartMs)&&(identical(other.trimEndMs, trimEndMs) || other.trimEndMs == trimEndMs)&&(identical(other.muted, muted) || other.muted == muted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,trimStartMs,trimEndMs,muted);
}

@override
String toString() {
    return 'VideoTimeline(trimStartMs: $trimStartMs, trimEndMs: $trimEndMs, muted: $muted)';
}


}

/// @nodoc
abstract mixin class _$VideoTimelineCopyWith<$Res> implements $VideoTimelineCopyWith<$Res> {
  factory _$VideoTimelineCopyWith(_VideoTimeline value, $Res Function(_VideoTimeline) _then) = __$VideoTimelineCopyWithImpl;
@override @useResult
$Res call({
 int trimStartMs, int? trimEndMs, bool muted
});




}
/// @nodoc
class __$VideoTimelineCopyWithImpl<$Res>
    implements _$VideoTimelineCopyWith<$Res> {
  __$VideoTimelineCopyWithImpl(this._self, this._then);

  final _VideoTimeline _self;
  final $Res Function(_VideoTimeline) _then;

/// Create a copy of VideoTimeline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trimStartMs = null,Object? trimEndMs = freezed,Object? muted = null,}) {
  return _then(_VideoTimeline(
trimStartMs: null == trimStartMs ? _self.trimStartMs : trimStartMs // ignore: cast_nullable_to_non_nullable
as int,trimEndMs: freezed == trimEndMs ? _self.trimEndMs : trimEndMs // ignore: cast_nullable_to_non_nullable
as int?,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
