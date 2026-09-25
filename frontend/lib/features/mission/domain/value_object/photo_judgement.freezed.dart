// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_judgement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PhotoJudgement {

/// 採点ランク
@JsonKey(fromJson: _rankFromJson, toJson: _rankToJson) PhotoJudgeRank get rank;/// 位置誤差 (メートル)
 double get distanceErrorMeters;/// 方角誤差 (度。向きを取れなければ null)
 double? get headingErrorDegrees;/// 撮影した位置
@NullableCoordinateConverter() Coordinate? get guessPosition;/// 撮影したときの向き (度)
 double? get capturedHeading;/// 撮影したときのズームの倍率 (共有されていなければ null)
 double? get zoomLevel;
/// Create a copy of PhotoJudgement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PhotoJudgementCopyWith<PhotoJudgement> get copyWith => _$PhotoJudgementCopyWithImpl<PhotoJudgement>(this as PhotoJudgement, _$identity);

  /// Serializes this PhotoJudgement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoJudgement&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.distanceErrorMeters, distanceErrorMeters) || other.distanceErrorMeters == distanceErrorMeters)&&(identical(other.headingErrorDegrees, headingErrorDegrees) || other.headingErrorDegrees == headingErrorDegrees)&&(identical(other.guessPosition, guessPosition) || other.guessPosition == guessPosition)&&(identical(other.capturedHeading, capturedHeading) || other.capturedHeading == capturedHeading)&&(identical(other.zoomLevel, zoomLevel) || other.zoomLevel == zoomLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,distanceErrorMeters,headingErrorDegrees,guessPosition,capturedHeading,zoomLevel);

@override
String toString() {
  return 'PhotoJudgement(rank: $rank, distanceErrorMeters: $distanceErrorMeters, headingErrorDegrees: $headingErrorDegrees, guessPosition: $guessPosition, capturedHeading: $capturedHeading, zoomLevel: $zoomLevel)';
}


}

/// @nodoc
abstract mixin class $PhotoJudgementCopyWith<$Res>  {
  factory $PhotoJudgementCopyWith(PhotoJudgement value, $Res Function(PhotoJudgement) _then) = _$PhotoJudgementCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _rankFromJson, toJson: _rankToJson) PhotoJudgeRank rank, double distanceErrorMeters, double? headingErrorDegrees,@NullableCoordinateConverter() Coordinate? guessPosition, double? capturedHeading, double? zoomLevel
});




}
/// @nodoc
class _$PhotoJudgementCopyWithImpl<$Res>
    implements $PhotoJudgementCopyWith<$Res> {
  _$PhotoJudgementCopyWithImpl(this._self, this._then);

  final PhotoJudgement _self;
  final $Res Function(PhotoJudgement) _then;

/// Create a copy of PhotoJudgement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? distanceErrorMeters = null,Object? headingErrorDegrees = freezed,Object? guessPosition = freezed,Object? capturedHeading = freezed,Object? zoomLevel = freezed,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as PhotoJudgeRank,distanceErrorMeters: null == distanceErrorMeters ? _self.distanceErrorMeters : distanceErrorMeters // ignore: cast_nullable_to_non_nullable
as double,headingErrorDegrees: freezed == headingErrorDegrees ? _self.headingErrorDegrees : headingErrorDegrees // ignore: cast_nullable_to_non_nullable
as double?,guessPosition: freezed == guessPosition ? _self.guessPosition : guessPosition // ignore: cast_nullable_to_non_nullable
as Coordinate?,capturedHeading: freezed == capturedHeading ? _self.capturedHeading : capturedHeading // ignore: cast_nullable_to_non_nullable
as double?,zoomLevel: freezed == zoomLevel ? _self.zoomLevel : zoomLevel // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PhotoJudgement].
extension PhotoJudgementPatterns on PhotoJudgement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PhotoJudgement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PhotoJudgement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PhotoJudgement value)  $default,){
final _that = this;
switch (_that) {
case _PhotoJudgement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PhotoJudgement value)?  $default,){
final _that = this;
switch (_that) {
case _PhotoJudgement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _rankFromJson, toJson: _rankToJson)  PhotoJudgeRank rank,  double distanceErrorMeters,  double? headingErrorDegrees, @NullableCoordinateConverter()  Coordinate? guessPosition,  double? capturedHeading,  double? zoomLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PhotoJudgement() when $default != null:
return $default(_that.rank,_that.distanceErrorMeters,_that.headingErrorDegrees,_that.guessPosition,_that.capturedHeading,_that.zoomLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _rankFromJson, toJson: _rankToJson)  PhotoJudgeRank rank,  double distanceErrorMeters,  double? headingErrorDegrees, @NullableCoordinateConverter()  Coordinate? guessPosition,  double? capturedHeading,  double? zoomLevel)  $default,) {final _that = this;
switch (_that) {
case _PhotoJudgement():
return $default(_that.rank,_that.distanceErrorMeters,_that.headingErrorDegrees,_that.guessPosition,_that.capturedHeading,_that.zoomLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _rankFromJson, toJson: _rankToJson)  PhotoJudgeRank rank,  double distanceErrorMeters,  double? headingErrorDegrees, @NullableCoordinateConverter()  Coordinate? guessPosition,  double? capturedHeading,  double? zoomLevel)?  $default,) {final _that = this;
switch (_that) {
case _PhotoJudgement() when $default != null:
return $default(_that.rank,_that.distanceErrorMeters,_that.headingErrorDegrees,_that.guessPosition,_that.capturedHeading,_that.zoomLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PhotoJudgement implements PhotoJudgement {
  const _PhotoJudgement({@JsonKey(fromJson: _rankFromJson, toJson: _rankToJson) required this.rank, required this.distanceErrorMeters, this.headingErrorDegrees, @NullableCoordinateConverter() this.guessPosition, this.capturedHeading, this.zoomLevel});
  factory _PhotoJudgement.fromJson(Map<String, dynamic> json) => _$PhotoJudgementFromJson(json);

/// 採点ランク
@override@JsonKey(fromJson: _rankFromJson, toJson: _rankToJson) final  PhotoJudgeRank rank;
/// 位置誤差 (メートル)
@override final  double distanceErrorMeters;
/// 方角誤差 (度。向きを取れなければ null)
@override final  double? headingErrorDegrees;
/// 撮影した位置
@override@NullableCoordinateConverter() final  Coordinate? guessPosition;
/// 撮影したときの向き (度)
@override final  double? capturedHeading;
/// 撮影したときのズームの倍率 (共有されていなければ null)
@override final  double? zoomLevel;

/// Create a copy of PhotoJudgement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PhotoJudgementCopyWith<_PhotoJudgement> get copyWith => __$PhotoJudgementCopyWithImpl<_PhotoJudgement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PhotoJudgementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PhotoJudgement&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.distanceErrorMeters, distanceErrorMeters) || other.distanceErrorMeters == distanceErrorMeters)&&(identical(other.headingErrorDegrees, headingErrorDegrees) || other.headingErrorDegrees == headingErrorDegrees)&&(identical(other.guessPosition, guessPosition) || other.guessPosition == guessPosition)&&(identical(other.capturedHeading, capturedHeading) || other.capturedHeading == capturedHeading)&&(identical(other.zoomLevel, zoomLevel) || other.zoomLevel == zoomLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,distanceErrorMeters,headingErrorDegrees,guessPosition,capturedHeading,zoomLevel);

@override
String toString() {
  return 'PhotoJudgement(rank: $rank, distanceErrorMeters: $distanceErrorMeters, headingErrorDegrees: $headingErrorDegrees, guessPosition: $guessPosition, capturedHeading: $capturedHeading, zoomLevel: $zoomLevel)';
}


}

/// @nodoc
abstract mixin class _$PhotoJudgementCopyWith<$Res> implements $PhotoJudgementCopyWith<$Res> {
  factory _$PhotoJudgementCopyWith(_PhotoJudgement value, $Res Function(_PhotoJudgement) _then) = __$PhotoJudgementCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _rankFromJson, toJson: _rankToJson) PhotoJudgeRank rank, double distanceErrorMeters, double? headingErrorDegrees,@NullableCoordinateConverter() Coordinate? guessPosition, double? capturedHeading, double? zoomLevel
});




}
/// @nodoc
class __$PhotoJudgementCopyWithImpl<$Res>
    implements _$PhotoJudgementCopyWith<$Res> {
  __$PhotoJudgementCopyWithImpl(this._self, this._then);

  final _PhotoJudgement _self;
  final $Res Function(_PhotoJudgement) _then;

/// Create a copy of PhotoJudgement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? distanceErrorMeters = null,Object? headingErrorDegrees = freezed,Object? guessPosition = freezed,Object? capturedHeading = freezed,Object? zoomLevel = freezed,}) {
  return _then(_PhotoJudgement(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as PhotoJudgeRank,distanceErrorMeters: null == distanceErrorMeters ? _self.distanceErrorMeters : distanceErrorMeters // ignore: cast_nullable_to_non_nullable
as double,headingErrorDegrees: freezed == headingErrorDegrees ? _self.headingErrorDegrees : headingErrorDegrees // ignore: cast_nullable_to_non_nullable
as double?,guessPosition: freezed == guessPosition ? _self.guessPosition : guessPosition // ignore: cast_nullable_to_non_nullable
as Coordinate?,capturedHeading: freezed == capturedHeading ? _self.capturedHeading : capturedHeading // ignore: cast_nullable_to_non_nullable
as double?,zoomLevel: freezed == zoomLevel ? _self.zoomLevel : zoomLevel // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
