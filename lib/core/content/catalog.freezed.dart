// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PresetCollection {

 String get id; String get name; String? get description; int get order; bool get isPremium;
/// Create a copy of PresetCollection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresetCollectionCopyWith<PresetCollection> get copyWith => _$PresetCollectionCopyWithImpl<PresetCollection>(this as PresetCollection, _$identity);

  /// Serializes this PresetCollection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PresetCollection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresetCollection&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.isPremium, _this.isPremium) || other.isPremium == _this.isPremium));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PresetCollection;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.order,_this.isPremium);
}

@override
String toString() {
  final _this = this as PresetCollection;
  return 'PresetCollection(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, order: ${_this.order}, isPremium: ${_this.isPremium})';
}


}

/// @nodoc
abstract mixin class $PresetCollectionCopyWith<$Res>  {
  factory $PresetCollectionCopyWith(PresetCollection value, $Res Function(PresetCollection) _then) = _$PresetCollectionCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, int order, bool isPremium
});




}
/// @nodoc
class _$PresetCollectionCopyWithImpl<$Res>
    implements $PresetCollectionCopyWith<$Res> {
  _$PresetCollectionCopyWithImpl(this._self, this._then);

  final PresetCollection _self;
  final $Res Function(PresetCollection) _then;

/// Create a copy of PresetCollection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? order = null,Object? isPremium = null,}) {
  return _then(PresetCollection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PresetCollection].
extension PresetCollectionPatterns on PresetCollection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresetCollection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresetCollection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresetCollection value)  $default,){
final _that = this;
switch (_that) {
case _PresetCollection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresetCollection value)?  $default,){
final _that = this;
switch (_that) {
case _PresetCollection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  int order,  bool isPremium)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresetCollection() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.order,_that.isPremium);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  int order,  bool isPremium)  $default,) {final _that = this;
switch (_that) {
case _PresetCollection():
return $default(_that.id,_that.name,_that.description,_that.order,_that.isPremium);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  int order,  bool isPremium)?  $default,) {final _that = this;
switch (_that) {
case _PresetCollection() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.order,_that.isPremium);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PresetCollection implements PresetCollection {
  const _PresetCollection({required this.id, required this.name, this.description, this.order = 0, this.isPremium = false});
  factory _PresetCollection.fromJson(Map<String, dynamic> json) => _$PresetCollectionFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  int order;
@override@JsonKey() final  bool isPremium;

/// Create a copy of PresetCollection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresetCollectionCopyWith<_PresetCollection> get copyWith => __$PresetCollectionCopyWithImpl<_PresetCollection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresetCollectionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresetCollection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,order,isPremium);
}

@override
String toString() {
    return 'PresetCollection(id: $id, name: $name, description: $description, order: $order, isPremium: $isPremium)';
}


}

/// @nodoc
abstract mixin class _$PresetCollectionCopyWith<$Res> implements $PresetCollectionCopyWith<$Res> {
  factory _$PresetCollectionCopyWith(_PresetCollection value, $Res Function(_PresetCollection) _then) = __$PresetCollectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, int order, bool isPremium
});




}
/// @nodoc
class __$PresetCollectionCopyWithImpl<$Res>
    implements _$PresetCollectionCopyWith<$Res> {
  __$PresetCollectionCopyWithImpl(this._self, this._then);

  final _PresetCollection _self;
  final $Res Function(_PresetCollection) _then;

/// Create a copy of PresetCollection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? order = null,Object? isPremium = null,}) {
  return _then(_PresetCollection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ContentAsset {

 String get id; ContentAssetType get type; String get name;/// Asset path (bundled) or URL (remote, M8). Empty for generated content.
 String get file; String? get collectionId; String? get thumbnail; bool get isPremium; int get version;/// Type-specific settings: overlays `{generator, blend, opacity}`,
/// frames `{style, color, margin}`.
 Map<String, Object?> get params;
/// Create a copy of ContentAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentAssetCopyWith<ContentAsset> get copyWith => _$ContentAssetCopyWithImpl<ContentAsset>(this as ContentAsset, _$identity);

  /// Serializes this ContentAsset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ContentAsset;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentAsset&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.file, _this.file) || other.file == _this.file)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.thumbnail, _this.thumbnail) || other.thumbnail == _this.thumbnail)&&(identical(other.isPremium, _this.isPremium) || other.isPremium == _this.isPremium)&&(identical(other.version, _this.version) || other.version == _this.version)&&const DeepCollectionEquality().equals(other.params, _this.params));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ContentAsset;
  return Object.hash(runtimeType,_this.id,_this.type,_this.name,_this.file,_this.collectionId,_this.thumbnail,_this.isPremium,_this.version,const DeepCollectionEquality().hash(_this.params));
}

@override
String toString() {
  final _this = this as ContentAsset;
  return 'ContentAsset(id: ${_this.id}, type: ${_this.type}, name: ${_this.name}, file: ${_this.file}, collectionId: ${_this.collectionId}, thumbnail: ${_this.thumbnail}, isPremium: ${_this.isPremium}, version: ${_this.version}, params: ${_this.params})';
}


}

/// @nodoc
abstract mixin class $ContentAssetCopyWith<$Res>  {
  factory $ContentAssetCopyWith(ContentAsset value, $Res Function(ContentAsset) _then) = _$ContentAssetCopyWithImpl;
@useResult
$Res call({
 String id, ContentAssetType type, String name, String file, String? collectionId, String? thumbnail, bool isPremium, int version, Map<String, Object?> params
});




}
/// @nodoc
class _$ContentAssetCopyWithImpl<$Res>
    implements $ContentAssetCopyWith<$Res> {
  _$ContentAssetCopyWithImpl(this._self, this._then);

  final ContentAsset _self;
  final $Res Function(ContentAsset) _then;

/// Create a copy of ContentAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? file = null,Object? collectionId = freezed,Object? thumbnail = freezed,Object? isPremium = null,Object? version = null,Object? params = null,}) {
  return _then(ContentAsset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContentAssetType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as String,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,params: null == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentAsset].
extension ContentAssetPatterns on ContentAsset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContentAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContentAsset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContentAsset value)  $default,){
final _that = this;
switch (_that) {
case _ContentAsset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContentAsset value)?  $default,){
final _that = this;
switch (_that) {
case _ContentAsset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ContentAssetType type,  String name,  String file,  String? collectionId,  String? thumbnail,  bool isPremium,  int version,  Map<String, Object?> params)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContentAsset() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.file,_that.collectionId,_that.thumbnail,_that.isPremium,_that.version,_that.params);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ContentAssetType type,  String name,  String file,  String? collectionId,  String? thumbnail,  bool isPremium,  int version,  Map<String, Object?> params)  $default,) {final _that = this;
switch (_that) {
case _ContentAsset():
return $default(_that.id,_that.type,_that.name,_that.file,_that.collectionId,_that.thumbnail,_that.isPremium,_that.version,_that.params);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ContentAssetType type,  String name,  String file,  String? collectionId,  String? thumbnail,  bool isPremium,  int version,  Map<String, Object?> params)?  $default,) {final _that = this;
switch (_that) {
case _ContentAsset() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.file,_that.collectionId,_that.thumbnail,_that.isPremium,_that.version,_that.params);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContentAsset implements ContentAsset {
  const _ContentAsset({required this.id, required this.type, required this.name, this.file = '', this.collectionId, this.thumbnail, this.isPremium = false, this.version = 1,  Map<String, Object?> params = const <String, Object?>{}}): _params = params;
  factory _ContentAsset.fromJson(Map<String, dynamic> json) => _$ContentAssetFromJson(json);

@override final  String id;
@override final  ContentAssetType type;
@override final  String name;
/// Asset path (bundled) or URL (remote, M8). Empty for generated content.
@override@JsonKey() final  String file;
@override final  String? collectionId;
@override final  String? thumbnail;
@override@JsonKey() final  bool isPremium;
@override@JsonKey() final  int version;
/// Type-specific settings: overlays `{generator, blend, opacity}`,
/// frames `{style, color, margin}`.
 final  Map<String, Object?> _params;
/// Type-specific settings: overlays `{generator, blend, opacity}`,
/// frames `{style, color, margin}`.
@override@JsonKey() Map<String, Object?> get params {
  if (_params is EqualUnmodifiableMapView) return _params;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_params);
}


/// Create a copy of ContentAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContentAssetCopyWith<_ContentAsset> get copyWith => __$ContentAssetCopyWithImpl<_ContentAsset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContentAssetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContentAsset&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.file, file) || other.file == file)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.version, version) || other.version == version)&&const DeepCollectionEquality().equals(other.params, _params));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,name,file,collectionId,thumbnail,isPremium,version,const DeepCollectionEquality().hash(_params));
}

@override
String toString() {
    return 'ContentAsset(id: $id, type: $type, name: $name, file: $file, collectionId: $collectionId, thumbnail: $thumbnail, isPremium: $isPremium, version: $version, params: $params)';
}


}

/// @nodoc
abstract mixin class _$ContentAssetCopyWith<$Res> implements $ContentAssetCopyWith<$Res> {
  factory _$ContentAssetCopyWith(_ContentAsset value, $Res Function(_ContentAsset) _then) = __$ContentAssetCopyWithImpl;
@override @useResult
$Res call({
 String id, ContentAssetType type, String name, String file, String? collectionId, String? thumbnail, bool isPremium, int version, Map<String, Object?> params
});




}
/// @nodoc
class __$ContentAssetCopyWithImpl<$Res>
    implements _$ContentAssetCopyWith<$Res> {
  __$ContentAssetCopyWithImpl(this._self, this._then);

  final _ContentAsset _self;
  final $Res Function(_ContentAsset) _then;

/// Create a copy of ContentAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? file = null,Object? collectionId = freezed,Object? thumbnail = freezed,Object? isPremium = null,Object? version = null,Object? params = null,}) {
  return _then(_ContentAsset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ContentAssetType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,file: null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as String,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,params: null == params ? _self._params : params // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}


/// @nodoc
mixin _$Catalog {

 int get catalogVersion; List<PresetCollection> get collections; List<Preset> get presets; List<ContentAsset> get assets;
/// Create a copy of Catalog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogCopyWith<Catalog> get copyWith => _$CatalogCopyWithImpl<Catalog>(this as Catalog, _$identity);

  /// Serializes this Catalog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Catalog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Catalog&&(identical(other.catalogVersion, _this.catalogVersion) || other.catalogVersion == _this.catalogVersion)&&const DeepCollectionEquality().equals(other.collections, _this.collections)&&const DeepCollectionEquality().equals(other.presets, _this.presets)&&const DeepCollectionEquality().equals(other.assets, _this.assets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Catalog;
  return Object.hash(runtimeType,_this.catalogVersion,const DeepCollectionEquality().hash(_this.collections),const DeepCollectionEquality().hash(_this.presets),const DeepCollectionEquality().hash(_this.assets));
}

@override
String toString() {
  final _this = this as Catalog;
  return 'Catalog(catalogVersion: ${_this.catalogVersion}, collections: ${_this.collections}, presets: ${_this.presets}, assets: ${_this.assets})';
}


}

/// @nodoc
abstract mixin class $CatalogCopyWith<$Res>  {
  factory $CatalogCopyWith(Catalog value, $Res Function(Catalog) _then) = _$CatalogCopyWithImpl;
@useResult
$Res call({
 int catalogVersion, List<PresetCollection> collections, List<Preset> presets, List<ContentAsset> assets
});




}
/// @nodoc
class _$CatalogCopyWithImpl<$Res>
    implements $CatalogCopyWith<$Res> {
  _$CatalogCopyWithImpl(this._self, this._then);

  final Catalog _self;
  final $Res Function(Catalog) _then;

/// Create a copy of Catalog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? catalogVersion = null,Object? collections = null,Object? presets = null,Object? assets = null,}) {
  return _then(Catalog(
catalogVersion: null == catalogVersion ? _self.catalogVersion : catalogVersion // ignore: cast_nullable_to_non_nullable
as int,collections: null == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as List<PresetCollection>,presets: null == presets ? _self.presets : presets // ignore: cast_nullable_to_non_nullable
as List<Preset>,assets: null == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as List<ContentAsset>,
  ));
}

}


/// Adds pattern-matching-related methods to [Catalog].
extension CatalogPatterns on Catalog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Catalog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Catalog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Catalog value)  $default,){
final _that = this;
switch (_that) {
case _Catalog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Catalog value)?  $default,){
final _that = this;
switch (_that) {
case _Catalog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int catalogVersion,  List<PresetCollection> collections,  List<Preset> presets,  List<ContentAsset> assets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Catalog() when $default != null:
return $default(_that.catalogVersion,_that.collections,_that.presets,_that.assets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int catalogVersion,  List<PresetCollection> collections,  List<Preset> presets,  List<ContentAsset> assets)  $default,) {final _that = this;
switch (_that) {
case _Catalog():
return $default(_that.catalogVersion,_that.collections,_that.presets,_that.assets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int catalogVersion,  List<PresetCollection> collections,  List<Preset> presets,  List<ContentAsset> assets)?  $default,) {final _that = this;
switch (_that) {
case _Catalog() when $default != null:
return $default(_that.catalogVersion,_that.collections,_that.presets,_that.assets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Catalog extends Catalog {
  const _Catalog({required this.catalogVersion,  List<PresetCollection> collections = const <PresetCollection>[],  List<Preset> presets = const <Preset>[],  List<ContentAsset> assets = const <ContentAsset>[]}): _collections = collections,_presets = presets,_assets = assets,super._();
  factory _Catalog.fromJson(Map<String, dynamic> json) => _$CatalogFromJson(json);

@override final  int catalogVersion;
 final  List<PresetCollection> _collections;
@override@JsonKey() List<PresetCollection> get collections {
  if (_collections is EqualUnmodifiableListView) return _collections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_collections);
}

 final  List<Preset> _presets;
@override@JsonKey() List<Preset> get presets {
  if (_presets is EqualUnmodifiableListView) return _presets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_presets);
}

 final  List<ContentAsset> _assets;
@override@JsonKey() List<ContentAsset> get assets {
  if (_assets is EqualUnmodifiableListView) return _assets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assets);
}


/// Create a copy of Catalog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogCopyWith<_Catalog> get copyWith => __$CatalogCopyWithImpl<_Catalog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Catalog&&(identical(other.catalogVersion, catalogVersion) || other.catalogVersion == catalogVersion)&&const DeepCollectionEquality().equals(other.collections, _collections)&&const DeepCollectionEquality().equals(other.presets, _presets)&&const DeepCollectionEquality().equals(other.assets, _assets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,catalogVersion,const DeepCollectionEquality().hash(_collections),const DeepCollectionEquality().hash(_presets),const DeepCollectionEquality().hash(_assets));
}

@override
String toString() {
    return 'Catalog(catalogVersion: $catalogVersion, collections: $collections, presets: $presets, assets: $assets)';
}


}

/// @nodoc
abstract mixin class _$CatalogCopyWith<$Res> implements $CatalogCopyWith<$Res> {
  factory _$CatalogCopyWith(_Catalog value, $Res Function(_Catalog) _then) = __$CatalogCopyWithImpl;
@override @useResult
$Res call({
 int catalogVersion, List<PresetCollection> collections, List<Preset> presets, List<ContentAsset> assets
});




}
/// @nodoc
class __$CatalogCopyWithImpl<$Res>
    implements _$CatalogCopyWith<$Res> {
  __$CatalogCopyWithImpl(this._self, this._then);

  final _Catalog _self;
  final $Res Function(_Catalog) _then;

/// Create a copy of Catalog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? catalogVersion = null,Object? collections = null,Object? presets = null,Object? assets = null,}) {
  return _then(_Catalog(
catalogVersion: null == catalogVersion ? _self.catalogVersion : catalogVersion // ignore: cast_nullable_to_non_nullable
as int,collections: null == collections ? _self._collections : collections // ignore: cast_nullable_to_non_nullable
as List<PresetCollection>,presets: null == presets ? _self._presets : presets // ignore: cast_nullable_to_non_nullable
as List<Preset>,assets: null == assets ? _self._assets : assets // ignore: cast_nullable_to_non_nullable
as List<ContentAsset>,
  ));
}


}

// dart format on
