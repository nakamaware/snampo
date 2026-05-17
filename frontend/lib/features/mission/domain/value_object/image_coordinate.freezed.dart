// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_coordinate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImageCoordinate {

/// 座標
@CoordinateConverter() Coordinate get coordinate;/// Base64エンコードされた画像データ
 String get imageBase64;/// 正解画像の基準方角
 double? get referenceHeading;/// 表示名
 String? get name;/// ジャンル
 String? get genre;/// Google Maps の詳細URL
 String? get googleMapsUrl;
/// Create a copy of ImageCoordinate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageCoordinateCopyWith<ImageCoordinate> get copyWith => _$ImageCoordinateCopyWithImpl<ImageCoordinate>(this as ImageCoordinate, _$identity);

  /// Serializes this ImageCoordinate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageCoordinate&&(identical(other.coordinate, coordinate) || other.coordinate == coordinate)&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64)&&(identical(other.referenceHeading, referenceHeading) || other.referenceHeading == referenceHeading)&&(identical(other.name, name) || other.name == name)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.googleMapsUrl, googleMapsUrl) || other.googleMapsUrl == googleMapsUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coordinate,imageBase64,referenceHeading,name,genre,googleMapsUrl);

@override
String toString() {
  return 'ImageCoordinate(coordinate: $coordinate, imageBase64: $imageBase64, referenceHeading: $referenceHeading, name: $name, genre: $genre, googleMapsUrl: $googleMapsUrl)';
}


}

/// @nodoc
abstract mixin class $ImageCoordinateCopyWith<$Res>  {
  factory $ImageCoordinateCopyWith(ImageCoordinate value, $Res Function(ImageCoordinate) _then) = _$ImageCoordinateCopyWithImpl;
@useResult
$Res call({
@CoordinateConverter() Coordinate coordinate, String imageBase64, double? referenceHeading, String? name, String? genre, String? googleMapsUrl
});


$CoordinateCopyWith<$Res> get coordinate;

}
/// @nodoc
class _$ImageCoordinateCopyWithImpl<$Res>
    implements $ImageCoordinateCopyWith<$Res> {
  _$ImageCoordinateCopyWithImpl(this._self, this._then);

  final ImageCoordinate _self;
  final $Res Function(ImageCoordinate) _then;

/// Create a copy of ImageCoordinate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coordinate = null,Object? imageBase64 = null,Object? referenceHeading = freezed,Object? name = freezed,Object? genre = freezed,Object? googleMapsUrl = freezed,}) {
  return _then(_self.copyWith(
coordinate: null == coordinate ? _self.coordinate : coordinate // ignore: cast_nullable_to_non_nullable
as Coordinate,imageBase64: null == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String,referenceHeading: freezed == referenceHeading ? _self.referenceHeading : referenceHeading // ignore: cast_nullable_to_non_nullable
as double?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,googleMapsUrl: freezed == googleMapsUrl ? _self.googleMapsUrl : googleMapsUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ImageCoordinate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoordinateCopyWith<$Res> get coordinate {

  return $CoordinateCopyWith<$Res>(_self.coordinate, (value) {
    return _then(_self.copyWith(coordinate: value));
  });
}
}


/// Adds pattern-matching-related methods to [ImageCoordinate].
extension ImageCoordinatePatterns on ImageCoordinate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageCoordinate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageCoordinate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageCoordinate value)  $default,){
final _that = this;
switch (_that) {
case _ImageCoordinate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageCoordinate value)?  $default,){
final _that = this;
switch (_that) {
case _ImageCoordinate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@CoordinateConverter()  Coordinate coordinate,  String imageBase64,  double? referenceHeading,  String? name,  String? genre,  String? googleMapsUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageCoordinate() when $default != null:
return $default(_that.coordinate,_that.imageBase64,_that.referenceHeading,_that.name,_that.genre,_that.googleMapsUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@CoordinateConverter()  Coordinate coordinate,  String imageBase64,  double? referenceHeading,  String? name,  String? genre,  String? googleMapsUrl)  $default,) {final _that = this;
switch (_that) {
case _ImageCoordinate():
return $default(_that.coordinate,_that.imageBase64,_that.referenceHeading,_that.name,_that.genre,_that.googleMapsUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@CoordinateConverter()  Coordinate coordinate,  String imageBase64,  double? referenceHeading,  String? name,  String? genre,  String? googleMapsUrl)?  $default,) {final _that = this;
switch (_that) {
case _ImageCoordinate() when $default != null:
return $default(_that.coordinate,_that.imageBase64,_that.referenceHeading,_that.name,_that.genre,_that.googleMapsUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageCoordinate implements ImageCoordinate {
  const _ImageCoordinate({@CoordinateConverter() required this.coordinate, required this.imageBase64, this.referenceHeading, this.name, this.genre, this.googleMapsUrl});
  factory _ImageCoordinate.fromJson(Map<String, dynamic> json) => _$ImageCoordinateFromJson(json);

/// 座標
@override@CoordinateConverter() final  Coordinate coordinate;
/// Base64エンコードされた画像データ
@override final  String imageBase64;
/// 正解画像の基準方角
@override final  double? referenceHeading;
/// 表示名
@override final  String? name;
/// ジャンル
@override final  String? genre;
/// Google Maps の詳細URL
@override final  String? googleMapsUrl;

/// Create a copy of ImageCoordinate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageCoordinateCopyWith<_ImageCoordinate> get copyWith => __$ImageCoordinateCopyWithImpl<_ImageCoordinate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageCoordinateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageCoordinate&&(identical(other.coordinate, coordinate) || other.coordinate == coordinate)&&(identical(other.imageBase64, imageBase64) || other.imageBase64 == imageBase64)&&(identical(other.referenceHeading, referenceHeading) || other.referenceHeading == referenceHeading)&&(identical(other.name, name) || other.name == name)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.googleMapsUrl, googleMapsUrl) || other.googleMapsUrl == googleMapsUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coordinate,imageBase64,referenceHeading,name,genre,googleMapsUrl);

@override
String toString() {
  return 'ImageCoordinate(coordinate: $coordinate, imageBase64: $imageBase64, referenceHeading: $referenceHeading, name: $name, genre: $genre, googleMapsUrl: $googleMapsUrl)';
}


}

/// @nodoc
abstract mixin class _$ImageCoordinateCopyWith<$Res> implements $ImageCoordinateCopyWith<$Res> {
  factory _$ImageCoordinateCopyWith(_ImageCoordinate value, $Res Function(_ImageCoordinate) _then) = __$ImageCoordinateCopyWithImpl;
@override @useResult
$Res call({
@CoordinateConverter() Coordinate coordinate, String imageBase64, double? referenceHeading, String? name, String? genre, String? googleMapsUrl
});


@override $CoordinateCopyWith<$Res> get coordinate;

}
/// @nodoc
class __$ImageCoordinateCopyWithImpl<$Res>
    implements _$ImageCoordinateCopyWith<$Res> {
  __$ImageCoordinateCopyWithImpl(this._self, this._then);

  final _ImageCoordinate _self;
  final $Res Function(_ImageCoordinate) _then;

/// Create a copy of ImageCoordinate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coordinate = null,Object? imageBase64 = null,Object? referenceHeading = freezed,Object? name = freezed,Object? genre = freezed,Object? googleMapsUrl = freezed,}) {
  return _then(_ImageCoordinate(
coordinate: null == coordinate ? _self.coordinate : coordinate // ignore: cast_nullable_to_non_nullable
as Coordinate,imageBase64: null == imageBase64 ? _self.imageBase64 : imageBase64 // ignore: cast_nullable_to_non_nullable
as String,referenceHeading: freezed == referenceHeading ? _self.referenceHeading : referenceHeading // ignore: cast_nullable_to_non_nullable
as double?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,googleMapsUrl: freezed == googleMapsUrl ? _self.googleMapsUrl : googleMapsUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ImageCoordinate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoordinateCopyWith<$Res> get coordinate {

  return $CoordinateCopyWith<$Res>(_self.coordinate, (value) {
    return _then(_self.copyWith(coordinate: value));
  });
}
}

// dart format on
