// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ToneStrip {

@HexColorConverter() int get highlight;@HexColorConverter() int get mid;@HexColorConverter() int get shadow;
/// Create a copy of ToneStrip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToneStripCopyWith<ToneStrip> get copyWith => _$ToneStripCopyWithImpl<ToneStrip>(this as ToneStrip, _$identity);

  /// Serializes this ToneStrip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ToneStrip;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ToneStrip&&(identical(other.highlight, _this.highlight) || other.highlight == _this.highlight)&&(identical(other.mid, _this.mid) || other.mid == _this.mid)&&(identical(other.shadow, _this.shadow) || other.shadow == _this.shadow));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ToneStrip;
  return Object.hash(runtimeType,_this.highlight,_this.mid,_this.shadow);
}

@override
String toString() {
  final _this = this as ToneStrip;
  return 'ToneStrip(highlight: ${_this.highlight}, mid: ${_this.mid}, shadow: ${_this.shadow})';
}


}

/// @nodoc
abstract mixin class $ToneStripCopyWith<$Res>  {
  factory $ToneStripCopyWith(ToneStrip value, $Res Function(ToneStrip) _then) = _$ToneStripCopyWithImpl;
@useResult
$Res call({
@HexColorConverter() int highlight,@HexColorConverter() int mid,@HexColorConverter() int shadow
});




}
/// @nodoc
class _$ToneStripCopyWithImpl<$Res>
    implements $ToneStripCopyWith<$Res> {
  _$ToneStripCopyWithImpl(this._self, this._then);

  final ToneStrip _self;
  final $Res Function(ToneStrip) _then;

/// Create a copy of ToneStrip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? highlight = null,Object? mid = null,Object? shadow = null,}) {
  return _then(ToneStrip(
highlight: null == highlight ? _self.highlight : highlight // ignore: cast_nullable_to_non_nullable
as int,mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,shadow: null == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ToneStrip].
extension ToneStripPatterns on ToneStrip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ToneStrip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ToneStrip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ToneStrip value)  $default,){
final _that = this;
switch (_that) {
case _ToneStrip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ToneStrip value)?  $default,){
final _that = this;
switch (_that) {
case _ToneStrip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HexColorConverter()  int highlight, @HexColorConverter()  int mid, @HexColorConverter()  int shadow)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ToneStrip() when $default != null:
return $default(_that.highlight,_that.mid,_that.shadow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HexColorConverter()  int highlight, @HexColorConverter()  int mid, @HexColorConverter()  int shadow)  $default,) {final _that = this;
switch (_that) {
case _ToneStrip():
return $default(_that.highlight,_that.mid,_that.shadow);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HexColorConverter()  int highlight, @HexColorConverter()  int mid, @HexColorConverter()  int shadow)?  $default,) {final _that = this;
switch (_that) {
case _ToneStrip() when $default != null:
return $default(_that.highlight,_that.mid,_that.shadow);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ToneStrip implements ToneStrip {
  const _ToneStrip({@HexColorConverter() required this.highlight, @HexColorConverter() required this.mid, @HexColorConverter() required this.shadow});
  factory _ToneStrip.fromJson(Map<String, dynamic> json) => _$ToneStripFromJson(json);

@override@HexColorConverter() final  int highlight;
@override@HexColorConverter() final  int mid;
@override@HexColorConverter() final  int shadow;

/// Create a copy of ToneStrip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToneStripCopyWith<_ToneStrip> get copyWith => __$ToneStripCopyWithImpl<_ToneStrip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ToneStripToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToneStrip&&(identical(other.highlight, highlight) || other.highlight == highlight)&&(identical(other.mid, mid) || other.mid == mid)&&(identical(other.shadow, shadow) || other.shadow == shadow));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,highlight,mid,shadow);
}

@override
String toString() {
    return 'ToneStrip(highlight: $highlight, mid: $mid, shadow: $shadow)';
}


}

/// @nodoc
abstract mixin class _$ToneStripCopyWith<$Res> implements $ToneStripCopyWith<$Res> {
  factory _$ToneStripCopyWith(_ToneStrip value, $Res Function(_ToneStrip) _then) = __$ToneStripCopyWithImpl;
@override @useResult
$Res call({
@HexColorConverter() int highlight,@HexColorConverter() int mid,@HexColorConverter() int shadow
});




}
/// @nodoc
class __$ToneStripCopyWithImpl<$Res>
    implements _$ToneStripCopyWith<$Res> {
  __$ToneStripCopyWithImpl(this._self, this._then);

  final _ToneStrip _self;
  final $Res Function(_ToneStrip) _then;

/// Create a copy of ToneStrip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? highlight = null,Object? mid = null,Object? shadow = null,}) {
  return _then(_ToneStrip(
highlight: null == highlight ? _self.highlight : highlight // ignore: cast_nullable_to_non_nullable
as int,mid: null == mid ? _self.mid : mid // ignore: cast_nullable_to_non_nullable
as int,shadow: null == shadow ? _self.shadow : shadow // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Preset {

 String get id; String get name; String get collectionId; int get version; bool get isPremium; Adjustments get settings; ToneCurves? get curves; ToneStrip? get tone;/// Film stock line under the name, e.g. "Colour neg." and ISO.
 String? get stock; int? get iso; String? get description;
/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresetCopyWith<Preset> get copyWith => _$PresetCopyWithImpl<Preset>(this as Preset, _$identity);

  /// Serializes this Preset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Preset;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Preset&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.version, _this.version) || other.version == _this.version)&&(identical(other.isPremium, _this.isPremium) || other.isPremium == _this.isPremium)&&(identical(other.settings, _this.settings) || other.settings == _this.settings)&&(identical(other.curves, _this.curves) || other.curves == _this.curves)&&(identical(other.tone, _this.tone) || other.tone == _this.tone)&&(identical(other.stock, _this.stock) || other.stock == _this.stock)&&(identical(other.iso, _this.iso) || other.iso == _this.iso)&&(identical(other.description, _this.description) || other.description == _this.description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Preset;
  return Object.hash(runtimeType,_this.id,_this.name,_this.collectionId,_this.version,_this.isPremium,_this.settings,_this.curves,_this.tone,_this.stock,_this.iso,_this.description);
}

@override
String toString() {
  final _this = this as Preset;
  return 'Preset(id: ${_this.id}, name: ${_this.name}, collectionId: ${_this.collectionId}, version: ${_this.version}, isPremium: ${_this.isPremium}, settings: ${_this.settings}, curves: ${_this.curves}, tone: ${_this.tone}, stock: ${_this.stock}, iso: ${_this.iso}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $PresetCopyWith<$Res>  {
  factory $PresetCopyWith(Preset value, $Res Function(Preset) _then) = _$PresetCopyWithImpl;
@useResult
$Res call({
 String id, String name, String collectionId, int version, bool isPremium, Adjustments settings, ToneCurves? curves, ToneStrip? tone, String? stock, int? iso, String? description
});


$ToneCurvesCopyWith<$Res>? get curves;$ToneStripCopyWith<$Res>? get tone;

}
/// @nodoc
class _$PresetCopyWithImpl<$Res>
    implements $PresetCopyWith<$Res> {
  _$PresetCopyWithImpl(this._self, this._then);

  final Preset _self;
  final $Res Function(Preset) _then;

/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? collectionId = null,Object? version = null,Object? isPremium = null,Object? settings = null,Object? curves = freezed,Object? tone = freezed,Object? stock = freezed,Object? iso = freezed,Object? description = freezed,}) {
  return _then(Preset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Adjustments,curves: freezed == curves ? _self.curves : curves // ignore: cast_nullable_to_non_nullable
as ToneCurves?,tone: freezed == tone ? _self.tone : tone // ignore: cast_nullable_to_non_nullable
as ToneStrip?,stock: freezed == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as String?,iso: freezed == iso ? _self.iso : iso // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurvesCopyWith<$Res>? get curves {
    if (_self.curves == null) {
    return null;
  }

  return $ToneCurvesCopyWith<$Res>(_self.curves!, (value) {
    return _then(_self.copyWith(curves: value));
  });
}/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneStripCopyWith<$Res>? get tone {
    if (_self.tone == null) {
    return null;
  }

  return $ToneStripCopyWith<$Res>(_self.tone!, (value) {
    return _then(_self.copyWith(tone: value));
  });
}
}


/// Adds pattern-matching-related methods to [Preset].
extension PresetPatterns on Preset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Preset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Preset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Preset value)  $default,){
final _that = this;
switch (_that) {
case _Preset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Preset value)?  $default,){
final _that = this;
switch (_that) {
case _Preset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String collectionId,  int version,  bool isPremium,  Adjustments settings,  ToneCurves? curves,  ToneStrip? tone,  String? stock,  int? iso,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Preset() when $default != null:
return $default(_that.id,_that.name,_that.collectionId,_that.version,_that.isPremium,_that.settings,_that.curves,_that.tone,_that.stock,_that.iso,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String collectionId,  int version,  bool isPremium,  Adjustments settings,  ToneCurves? curves,  ToneStrip? tone,  String? stock,  int? iso,  String? description)  $default,) {final _that = this;
switch (_that) {
case _Preset():
return $default(_that.id,_that.name,_that.collectionId,_that.version,_that.isPremium,_that.settings,_that.curves,_that.tone,_that.stock,_that.iso,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String collectionId,  int version,  bool isPremium,  Adjustments settings,  ToneCurves? curves,  ToneStrip? tone,  String? stock,  int? iso,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _Preset() when $default != null:
return $default(_that.id,_that.name,_that.collectionId,_that.version,_that.isPremium,_that.settings,_that.curves,_that.tone,_that.stock,_that.iso,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Preset implements Preset {
  const _Preset({required this.id, required this.name, required this.collectionId, this.version = 1, this.isPremium = false, this.settings = const Adjustments(), this.curves, this.tone, this.stock, this.iso, this.description});
  factory _Preset.fromJson(Map<String, dynamic> json) => _$PresetFromJson(json);

@override final  String id;
@override final  String name;
@override final  String collectionId;
@override@JsonKey() final  int version;
@override@JsonKey() final  bool isPremium;
@override@JsonKey() final  Adjustments settings;
@override final  ToneCurves? curves;
@override final  ToneStrip? tone;
/// Film stock line under the name, e.g. "Colour neg." and ISO.
@override final  String? stock;
@override final  int? iso;
@override final  String? description;

/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresetCopyWith<_Preset> get copyWith => __$PresetCopyWithImpl<_Preset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Preset&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.version, version) || other.version == version)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.curves, curves) || other.curves == curves)&&(identical(other.tone, tone) || other.tone == tone)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.iso, iso) || other.iso == iso)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,collectionId,version,isPremium,settings,curves,tone,stock,iso,description);
}

@override
String toString() {
    return 'Preset(id: $id, name: $name, collectionId: $collectionId, version: $version, isPremium: $isPremium, settings: $settings, curves: $curves, tone: $tone, stock: $stock, iso: $iso, description: $description)';
}


}

/// @nodoc
abstract mixin class _$PresetCopyWith<$Res> implements $PresetCopyWith<$Res> {
  factory _$PresetCopyWith(_Preset value, $Res Function(_Preset) _then) = __$PresetCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String collectionId, int version, bool isPremium, Adjustments settings, ToneCurves? curves, ToneStrip? tone, String? stock, int? iso, String? description
});


@override $ToneCurvesCopyWith<$Res>? get curves;@override $ToneStripCopyWith<$Res>? get tone;

}
/// @nodoc
class __$PresetCopyWithImpl<$Res>
    implements _$PresetCopyWith<$Res> {
  __$PresetCopyWithImpl(this._self, this._then);

  final _Preset _self;
  final $Res Function(_Preset) _then;

/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? collectionId = null,Object? version = null,Object? isPremium = null,Object? settings = null,Object? curves = freezed,Object? tone = freezed,Object? stock = freezed,Object? iso = freezed,Object? description = freezed,}) {
  return _then(_Preset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Adjustments,curves: freezed == curves ? _self.curves : curves // ignore: cast_nullable_to_non_nullable
as ToneCurves?,tone: freezed == tone ? _self.tone : tone // ignore: cast_nullable_to_non_nullable
as ToneStrip?,stock: freezed == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as String?,iso: freezed == iso ? _self.iso : iso // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneCurvesCopyWith<$Res>? get curves {
    if (_self.curves == null) {
    return null;
  }

  return $ToneCurvesCopyWith<$Res>(_self.curves!, (value) {
    return _then(_self.copyWith(curves: value));
  });
}/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ToneStripCopyWith<$Res>? get tone {
    if (_self.tone == null) {
    return null;
  }

  return $ToneStripCopyWith<$Res>(_self.tone!, (value) {
    return _then(_self.copyWith(tone: value));
  });
}
}


/// @nodoc
mixin _$PresetRef {

 String get presetId; double get intensity;
/// Create a copy of PresetRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresetRefCopyWith<PresetRef> get copyWith => _$PresetRefCopyWithImpl<PresetRef>(this as PresetRef, _$identity);

  /// Serializes this PresetRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PresetRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresetRef&&(identical(other.presetId, _this.presetId) || other.presetId == _this.presetId)&&(identical(other.intensity, _this.intensity) || other.intensity == _this.intensity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PresetRef;
  return Object.hash(runtimeType,_this.presetId,_this.intensity);
}

@override
String toString() {
  final _this = this as PresetRef;
  return 'PresetRef(presetId: ${_this.presetId}, intensity: ${_this.intensity})';
}


}

/// @nodoc
abstract mixin class $PresetRefCopyWith<$Res>  {
  factory $PresetRefCopyWith(PresetRef value, $Res Function(PresetRef) _then) = _$PresetRefCopyWithImpl;
@useResult
$Res call({
 String presetId, double intensity
});




}
/// @nodoc
class _$PresetRefCopyWithImpl<$Res>
    implements $PresetRefCopyWith<$Res> {
  _$PresetRefCopyWithImpl(this._self, this._then);

  final PresetRef _self;
  final $Res Function(PresetRef) _then;

/// Create a copy of PresetRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? presetId = null,Object? intensity = null,}) {
  return _then(PresetRef(
presetId: null == presetId ? _self.presetId : presetId // ignore: cast_nullable_to_non_nullable
as String,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PresetRef].
extension PresetRefPatterns on PresetRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresetRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresetRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresetRef value)  $default,){
final _that = this;
switch (_that) {
case _PresetRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresetRef value)?  $default,){
final _that = this;
switch (_that) {
case _PresetRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String presetId,  double intensity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresetRef() when $default != null:
return $default(_that.presetId,_that.intensity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String presetId,  double intensity)  $default,) {final _that = this;
switch (_that) {
case _PresetRef():
return $default(_that.presetId,_that.intensity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String presetId,  double intensity)?  $default,) {final _that = this;
switch (_that) {
case _PresetRef() when $default != null:
return $default(_that.presetId,_that.intensity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PresetRef implements PresetRef {
  const _PresetRef({required this.presetId, this.intensity = 1});
  factory _PresetRef.fromJson(Map<String, dynamic> json) => _$PresetRefFromJson(json);

@override final  String presetId;
@override@JsonKey() final  double intensity;

/// Create a copy of PresetRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresetRefCopyWith<_PresetRef> get copyWith => __$PresetRefCopyWithImpl<_PresetRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresetRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresetRef&&(identical(other.presetId, presetId) || other.presetId == presetId)&&(identical(other.intensity, intensity) || other.intensity == intensity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,presetId,intensity);
}

@override
String toString() {
    return 'PresetRef(presetId: $presetId, intensity: $intensity)';
}


}

/// @nodoc
abstract mixin class _$PresetRefCopyWith<$Res> implements $PresetRefCopyWith<$Res> {
  factory _$PresetRefCopyWith(_PresetRef value, $Res Function(_PresetRef) _then) = __$PresetRefCopyWithImpl;
@override @useResult
$Res call({
 String presetId, double intensity
});




}
/// @nodoc
class __$PresetRefCopyWithImpl<$Res>
    implements _$PresetRefCopyWith<$Res> {
  __$PresetRefCopyWithImpl(this._self, this._then);

  final _PresetRef _self;
  final $Res Function(_PresetRef) _then;

/// Create a copy of PresetRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? presetId = null,Object? intensity = null,}) {
  return _then(_PresetRef(
presetId: null == presetId ? _self.presetId : presetId // ignore: cast_nullable_to_non_nullable
as String,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
