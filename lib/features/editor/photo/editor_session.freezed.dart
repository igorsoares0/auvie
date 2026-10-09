// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditorSession {

 Project get project; EditHistory<EditState> get history; EditorTool get tool; AdjustmentFamily get family;/// Index into [family]'s adjustments.
 int get parameter;/// Collection id, or [savedCategory].
 String? get category;
/// Create a copy of EditorSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditorSessionCopyWith<EditorSession> get copyWith => _$EditorSessionCopyWithImpl<EditorSession>(this as EditorSession, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EditorSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditorSession&&(identical(other.project, _this.project) || other.project == _this.project)&&(identical(other.history, _this.history) || other.history == _this.history)&&(identical(other.tool, _this.tool) || other.tool == _this.tool)&&(identical(other.family, _this.family) || other.family == _this.family)&&(identical(other.parameter, _this.parameter) || other.parameter == _this.parameter)&&(identical(other.category, _this.category) || other.category == _this.category));
}


@override
int get hashCode {
  final _this = this as EditorSession;
  return Object.hash(runtimeType,_this.project,_this.history,_this.tool,_this.family,_this.parameter,_this.category);
}

@override
String toString() {
  final _this = this as EditorSession;
  return 'EditorSession(project: ${_this.project}, history: ${_this.history}, tool: ${_this.tool}, family: ${_this.family}, parameter: ${_this.parameter}, category: ${_this.category})';
}


}

/// @nodoc
abstract mixin class $EditorSessionCopyWith<$Res>  {
  factory $EditorSessionCopyWith(EditorSession value, $Res Function(EditorSession) _then) = _$EditorSessionCopyWithImpl;
@useResult
$Res call({
 Project project, EditHistory<EditState> history, EditorTool tool, AdjustmentFamily family, int parameter, String? category
});


$ProjectCopyWith<$Res> get project;

}
/// @nodoc
class _$EditorSessionCopyWithImpl<$Res>
    implements $EditorSessionCopyWith<$Res> {
  _$EditorSessionCopyWithImpl(this._self, this._then);

  final EditorSession _self;
  final $Res Function(EditorSession) _then;

/// Create a copy of EditorSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? project = null,Object? history = null,Object? tool = null,Object? family = null,Object? parameter = null,Object? category = freezed,}) {
  return _then(EditorSession(
project: null == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as Project,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as EditHistory<EditState>,tool: null == tool ? _self.tool : tool // ignore: cast_nullable_to_non_nullable
as EditorTool,family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as AdjustmentFamily,parameter: null == parameter ? _self.parameter : parameter // ignore: cast_nullable_to_non_nullable
as int,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of EditorSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCopyWith<$Res> get project {
  
  return $ProjectCopyWith<$Res>(_self.project, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}


/// Adds pattern-matching-related methods to [EditorSession].
extension EditorSessionPatterns on EditorSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditorSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditorSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditorSession value)  $default,){
final _that = this;
switch (_that) {
case _EditorSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditorSession value)?  $default,){
final _that = this;
switch (_that) {
case _EditorSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Project project,  EditHistory<EditState> history,  EditorTool tool,  AdjustmentFamily family,  int parameter,  String? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditorSession() when $default != null:
return $default(_that.project,_that.history,_that.tool,_that.family,_that.parameter,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Project project,  EditHistory<EditState> history,  EditorTool tool,  AdjustmentFamily family,  int parameter,  String? category)  $default,) {final _that = this;
switch (_that) {
case _EditorSession():
return $default(_that.project,_that.history,_that.tool,_that.family,_that.parameter,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Project project,  EditHistory<EditState> history,  EditorTool tool,  AdjustmentFamily family,  int parameter,  String? category)?  $default,) {final _that = this;
switch (_that) {
case _EditorSession() when $default != null:
return $default(_that.project,_that.history,_that.tool,_that.family,_that.parameter,_that.category);case _:
  return null;

}
}

}

/// @nodoc


class _EditorSession extends EditorSession {
  const _EditorSession({required this.project, required this.history, this.tool = EditorTool.film, this.family = AdjustmentFamily.light, this.parameter = 0, this.category}): super._();
  

@override final  Project project;
@override final  EditHistory<EditState> history;
@override@JsonKey() final  EditorTool tool;
@override@JsonKey() final  AdjustmentFamily family;
/// Index into [family]'s adjustments.
@override@JsonKey() final  int parameter;
/// Collection id, or [savedCategory].
@override final  String? category;

/// Create a copy of EditorSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditorSessionCopyWith<_EditorSession> get copyWith => __$EditorSessionCopyWithImpl<_EditorSession>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditorSession&&(identical(other.project, project) || other.project == project)&&(identical(other.history, history) || other.history == history)&&(identical(other.tool, tool) || other.tool == tool)&&(identical(other.family, family) || other.family == family)&&(identical(other.parameter, parameter) || other.parameter == parameter)&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode {
    return Object.hash(runtimeType,project,history,tool,family,parameter,category);
}

@override
String toString() {
    return 'EditorSession(project: $project, history: $history, tool: $tool, family: $family, parameter: $parameter, category: $category)';
}


}

/// @nodoc
abstract mixin class _$EditorSessionCopyWith<$Res> implements $EditorSessionCopyWith<$Res> {
  factory _$EditorSessionCopyWith(_EditorSession value, $Res Function(_EditorSession) _then) = __$EditorSessionCopyWithImpl;
@override @useResult
$Res call({
 Project project, EditHistory<EditState> history, EditorTool tool, AdjustmentFamily family, int parameter, String? category
});


@override $ProjectCopyWith<$Res> get project;

}
/// @nodoc
class __$EditorSessionCopyWithImpl<$Res>
    implements _$EditorSessionCopyWith<$Res> {
  __$EditorSessionCopyWithImpl(this._self, this._then);

  final _EditorSession _self;
  final $Res Function(_EditorSession) _then;

/// Create a copy of EditorSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? project = null,Object? history = null,Object? tool = null,Object? family = null,Object? parameter = null,Object? category = freezed,}) {
  return _then(_EditorSession(
project: null == project ? _self.project : project // ignore: cast_nullable_to_non_nullable
as Project,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as EditHistory<EditState>,tool: null == tool ? _self.tool : tool // ignore: cast_nullable_to_non_nullable
as EditorTool,family: null == family ? _self.family : family // ignore: cast_nullable_to_non_nullable
as AdjustmentFamily,parameter: null == parameter ? _self.parameter : parameter // ignore: cast_nullable_to_non_nullable
as int,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of EditorSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectCopyWith<$Res> get project {
  
  return $ProjectCopyWith<$Res>(_self.project, (value) {
    return _then(_self.copyWith(project: value));
  });
}
}

// dart format on
