// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_history_spot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MissionHistorySpot {

 Coordinate get coordinate; int get sortOrder; bool get isDestination; String get streetViewImagePath; String? get userPhotoPath; DateTime? get achievedAt; String? get name; String? get genre; String? get googleMapsUrl; double? get referenceHeading; PhotoJudgeRank? get judgeRank; double? get distanceErrorMeters; double? get headingErrorDegrees; Coordinate? get guessPosition; double? get capturedHeading;/// 撮影したときのズームの倍率 (古い履歴では null)
 double? get zoomLevel;/// スポット ID (旧データでは null)
 SpotId? get spotId;/// 協力プレイの発見者の uid
 String? get discovererUid;/// 協力プレイの発見者のニックネーム (発見時点)
 String? get discovererNickname;/// 協力プレイの発見者のサムネのパス (取得できなければ null)
 String? get discovererThumbPath;/// 協力プレイの発見者の採点 (共有されていなければ null)
 PhotoJudgement? get discovererJudgement;/// クリア済みか (協力プレイの途中終了では未クリアのスポットがある)
 bool get isCleared;
/// Create a copy of MissionHistorySpot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionHistorySpotCopyWith<MissionHistorySpot> get copyWith => _$MissionHistorySpotCopyWithImpl<MissionHistorySpot>(this as MissionHistorySpot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionHistorySpot&&(identical(other.coordinate, coordinate) || other.coordinate == coordinate)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isDestination, isDestination) || other.isDestination == isDestination)&&(identical(other.streetViewImagePath, streetViewImagePath) || other.streetViewImagePath == streetViewImagePath)&&(identical(other.userPhotoPath, userPhotoPath) || other.userPhotoPath == userPhotoPath)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt)&&(identical(other.name, name) || other.name == name)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.googleMapsUrl, googleMapsUrl) || other.googleMapsUrl == googleMapsUrl)&&(identical(other.referenceHeading, referenceHeading) || other.referenceHeading == referenceHeading)&&(identical(other.judgeRank, judgeRank) || other.judgeRank == judgeRank)&&(identical(other.distanceErrorMeters, distanceErrorMeters) || other.distanceErrorMeters == distanceErrorMeters)&&(identical(other.headingErrorDegrees, headingErrorDegrees) || other.headingErrorDegrees == headingErrorDegrees)&&(identical(other.guessPosition, guessPosition) || other.guessPosition == guessPosition)&&(identical(other.capturedHeading, capturedHeading) || other.capturedHeading == capturedHeading)&&(identical(other.zoomLevel, zoomLevel) || other.zoomLevel == zoomLevel)&&(identical(other.spotId, spotId) || other.spotId == spotId)&&(identical(other.discovererUid, discovererUid) || other.discovererUid == discovererUid)&&(identical(other.discovererNickname, discovererNickname) || other.discovererNickname == discovererNickname)&&(identical(other.discovererThumbPath, discovererThumbPath) || other.discovererThumbPath == discovererThumbPath)&&(identical(other.discovererJudgement, discovererJudgement) || other.discovererJudgement == discovererJudgement)&&(identical(other.isCleared, isCleared) || other.isCleared == isCleared));
}


@override
int get hashCode => Object.hashAll([runtimeType,coordinate,sortOrder,isDestination,streetViewImagePath,userPhotoPath,achievedAt,name,genre,googleMapsUrl,referenceHeading,judgeRank,distanceErrorMeters,headingErrorDegrees,guessPosition,capturedHeading,zoomLevel,spotId,discovererUid,discovererNickname,discovererThumbPath,discovererJudgement,isCleared]);

@override
String toString() {
  return 'MissionHistorySpot(coordinate: $coordinate, sortOrder: $sortOrder, isDestination: $isDestination, streetViewImagePath: $streetViewImagePath, userPhotoPath: $userPhotoPath, achievedAt: $achievedAt, name: $name, genre: $genre, googleMapsUrl: $googleMapsUrl, referenceHeading: $referenceHeading, judgeRank: $judgeRank, distanceErrorMeters: $distanceErrorMeters, headingErrorDegrees: $headingErrorDegrees, guessPosition: $guessPosition, capturedHeading: $capturedHeading, zoomLevel: $zoomLevel, spotId: $spotId, discovererUid: $discovererUid, discovererNickname: $discovererNickname, discovererThumbPath: $discovererThumbPath, discovererJudgement: $discovererJudgement, isCleared: $isCleared)';
}


}

/// @nodoc
abstract mixin class $MissionHistorySpotCopyWith<$Res>  {
  factory $MissionHistorySpotCopyWith(MissionHistorySpot value, $Res Function(MissionHistorySpot) _then) = _$MissionHistorySpotCopyWithImpl;
@useResult
$Res call({
 Coordinate coordinate, int sortOrder, bool isDestination, String streetViewImagePath, String? userPhotoPath, DateTime? achievedAt, String? name, String? genre, String? googleMapsUrl, double? referenceHeading, PhotoJudgeRank? judgeRank, double? distanceErrorMeters, double? headingErrorDegrees, Coordinate? guessPosition, double? capturedHeading, double? zoomLevel, SpotId? spotId, String? discovererUid, String? discovererNickname, String? discovererThumbPath, PhotoJudgement? discovererJudgement, bool isCleared
});


$PhotoJudgementCopyWith<$Res>? get discovererJudgement;

}
/// @nodoc
class _$MissionHistorySpotCopyWithImpl<$Res>
    implements $MissionHistorySpotCopyWith<$Res> {
  _$MissionHistorySpotCopyWithImpl(this._self, this._then);

  final MissionHistorySpot _self;
  final $Res Function(MissionHistorySpot) _then;

/// Create a copy of MissionHistorySpot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coordinate = null,Object? sortOrder = null,Object? isDestination = null,Object? streetViewImagePath = null,Object? userPhotoPath = freezed,Object? achievedAt = freezed,Object? name = freezed,Object? genre = freezed,Object? googleMapsUrl = freezed,Object? referenceHeading = freezed,Object? judgeRank = freezed,Object? distanceErrorMeters = freezed,Object? headingErrorDegrees = freezed,Object? guessPosition = freezed,Object? capturedHeading = freezed,Object? zoomLevel = freezed,Object? spotId = freezed,Object? discovererUid = freezed,Object? discovererNickname = freezed,Object? discovererThumbPath = freezed,Object? discovererJudgement = freezed,Object? isCleared = null,}) {
  return _then(_self.copyWith(
coordinate: null == coordinate ? _self.coordinate : coordinate // ignore: cast_nullable_to_non_nullable
as Coordinate,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isDestination: null == isDestination ? _self.isDestination : isDestination // ignore: cast_nullable_to_non_nullable
as bool,streetViewImagePath: null == streetViewImagePath ? _self.streetViewImagePath : streetViewImagePath // ignore: cast_nullable_to_non_nullable
as String,userPhotoPath: freezed == userPhotoPath ? _self.userPhotoPath : userPhotoPath // ignore: cast_nullable_to_non_nullable
as String?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,googleMapsUrl: freezed == googleMapsUrl ? _self.googleMapsUrl : googleMapsUrl // ignore: cast_nullable_to_non_nullable
as String?,referenceHeading: freezed == referenceHeading ? _self.referenceHeading : referenceHeading // ignore: cast_nullable_to_non_nullable
as double?,judgeRank: freezed == judgeRank ? _self.judgeRank : judgeRank // ignore: cast_nullable_to_non_nullable
as PhotoJudgeRank?,distanceErrorMeters: freezed == distanceErrorMeters ? _self.distanceErrorMeters : distanceErrorMeters // ignore: cast_nullable_to_non_nullable
as double?,headingErrorDegrees: freezed == headingErrorDegrees ? _self.headingErrorDegrees : headingErrorDegrees // ignore: cast_nullable_to_non_nullable
as double?,guessPosition: freezed == guessPosition ? _self.guessPosition : guessPosition // ignore: cast_nullable_to_non_nullable
as Coordinate?,capturedHeading: freezed == capturedHeading ? _self.capturedHeading : capturedHeading // ignore: cast_nullable_to_non_nullable
as double?,zoomLevel: freezed == zoomLevel ? _self.zoomLevel : zoomLevel // ignore: cast_nullable_to_non_nullable
as double?,spotId: freezed == spotId ? _self.spotId : spotId // ignore: cast_nullable_to_non_nullable
as SpotId?,discovererUid: freezed == discovererUid ? _self.discovererUid : discovererUid // ignore: cast_nullable_to_non_nullable
as String?,discovererNickname: freezed == discovererNickname ? _self.discovererNickname : discovererNickname // ignore: cast_nullable_to_non_nullable
as String?,discovererThumbPath: freezed == discovererThumbPath ? _self.discovererThumbPath : discovererThumbPath // ignore: cast_nullable_to_non_nullable
as String?,discovererJudgement: freezed == discovererJudgement ? _self.discovererJudgement : discovererJudgement // ignore: cast_nullable_to_non_nullable
as PhotoJudgement?,isCleared: null == isCleared ? _self.isCleared : isCleared // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of MissionHistorySpot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoJudgementCopyWith<$Res>? get discovererJudgement {
    if (_self.discovererJudgement == null) {
    return null;
  }

  return $PhotoJudgementCopyWith<$Res>(_self.discovererJudgement!, (value) {
    return _then(_self.copyWith(discovererJudgement: value));
  });
}
}


/// Adds pattern-matching-related methods to [MissionHistorySpot].
extension MissionHistorySpotPatterns on MissionHistorySpot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MissionHistorySpot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MissionHistorySpot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MissionHistorySpot value)  $default,){
final _that = this;
switch (_that) {
case _MissionHistorySpot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MissionHistorySpot value)?  $default,){
final _that = this;
switch (_that) {
case _MissionHistorySpot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Coordinate coordinate,  int sortOrder,  bool isDestination,  String streetViewImagePath,  String? userPhotoPath,  DateTime? achievedAt,  String? name,  String? genre,  String? googleMapsUrl,  double? referenceHeading,  PhotoJudgeRank? judgeRank,  double? distanceErrorMeters,  double? headingErrorDegrees,  Coordinate? guessPosition,  double? capturedHeading,  double? zoomLevel,  SpotId? spotId,  String? discovererUid,  String? discovererNickname,  String? discovererThumbPath,  PhotoJudgement? discovererJudgement,  bool isCleared)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MissionHistorySpot() when $default != null:
return $default(_that.coordinate,_that.sortOrder,_that.isDestination,_that.streetViewImagePath,_that.userPhotoPath,_that.achievedAt,_that.name,_that.genre,_that.googleMapsUrl,_that.referenceHeading,_that.judgeRank,_that.distanceErrorMeters,_that.headingErrorDegrees,_that.guessPosition,_that.capturedHeading,_that.zoomLevel,_that.spotId,_that.discovererUid,_that.discovererNickname,_that.discovererThumbPath,_that.discovererJudgement,_that.isCleared);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Coordinate coordinate,  int sortOrder,  bool isDestination,  String streetViewImagePath,  String? userPhotoPath,  DateTime? achievedAt,  String? name,  String? genre,  String? googleMapsUrl,  double? referenceHeading,  PhotoJudgeRank? judgeRank,  double? distanceErrorMeters,  double? headingErrorDegrees,  Coordinate? guessPosition,  double? capturedHeading,  double? zoomLevel,  SpotId? spotId,  String? discovererUid,  String? discovererNickname,  String? discovererThumbPath,  PhotoJudgement? discovererJudgement,  bool isCleared)  $default,) {final _that = this;
switch (_that) {
case _MissionHistorySpot():
return $default(_that.coordinate,_that.sortOrder,_that.isDestination,_that.streetViewImagePath,_that.userPhotoPath,_that.achievedAt,_that.name,_that.genre,_that.googleMapsUrl,_that.referenceHeading,_that.judgeRank,_that.distanceErrorMeters,_that.headingErrorDegrees,_that.guessPosition,_that.capturedHeading,_that.zoomLevel,_that.spotId,_that.discovererUid,_that.discovererNickname,_that.discovererThumbPath,_that.discovererJudgement,_that.isCleared);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Coordinate coordinate,  int sortOrder,  bool isDestination,  String streetViewImagePath,  String? userPhotoPath,  DateTime? achievedAt,  String? name,  String? genre,  String? googleMapsUrl,  double? referenceHeading,  PhotoJudgeRank? judgeRank,  double? distanceErrorMeters,  double? headingErrorDegrees,  Coordinate? guessPosition,  double? capturedHeading,  double? zoomLevel,  SpotId? spotId,  String? discovererUid,  String? discovererNickname,  String? discovererThumbPath,  PhotoJudgement? discovererJudgement,  bool isCleared)?  $default,) {final _that = this;
switch (_that) {
case _MissionHistorySpot() when $default != null:
return $default(_that.coordinate,_that.sortOrder,_that.isDestination,_that.streetViewImagePath,_that.userPhotoPath,_that.achievedAt,_that.name,_that.genre,_that.googleMapsUrl,_that.referenceHeading,_that.judgeRank,_that.distanceErrorMeters,_that.headingErrorDegrees,_that.guessPosition,_that.capturedHeading,_that.zoomLevel,_that.spotId,_that.discovererUid,_that.discovererNickname,_that.discovererThumbPath,_that.discovererJudgement,_that.isCleared);case _:
  return null;

}
}

}

/// @nodoc


class _MissionHistorySpot implements MissionHistorySpot {
  const _MissionHistorySpot({required this.coordinate, required this.sortOrder, required this.isDestination, required this.streetViewImagePath, this.userPhotoPath, this.achievedAt, this.name, this.genre, this.googleMapsUrl, this.referenceHeading, this.judgeRank, this.distanceErrorMeters, this.headingErrorDegrees, this.guessPosition, this.capturedHeading, this.zoomLevel, this.spotId, this.discovererUid, this.discovererNickname, this.discovererThumbPath, this.discovererJudgement, this.isCleared = true});


@override final  Coordinate coordinate;
@override final  int sortOrder;
@override final  bool isDestination;
@override final  String streetViewImagePath;
@override final  String? userPhotoPath;
@override final  DateTime? achievedAt;
@override final  String? name;
@override final  String? genre;
@override final  String? googleMapsUrl;
@override final  double? referenceHeading;
@override final  PhotoJudgeRank? judgeRank;
@override final  double? distanceErrorMeters;
@override final  double? headingErrorDegrees;
@override final  Coordinate? guessPosition;
@override final  double? capturedHeading;
/// 撮影したときのズームの倍率 (古い履歴では null)
@override final  double? zoomLevel;
/// スポット ID (旧データでは null)
@override final  SpotId? spotId;
/// 協力プレイの発見者の uid
@override final  String? discovererUid;
/// 協力プレイの発見者のニックネーム (発見時点)
@override final  String? discovererNickname;
/// 協力プレイの発見者のサムネのパス (取得できなければ null)
@override final  String? discovererThumbPath;
/// 協力プレイの発見者の採点 (共有されていなければ null)
@override final  PhotoJudgement? discovererJudgement;
/// クリア済みか (協力プレイの途中終了では未クリアのスポットがある)
@override@JsonKey() final  bool isCleared;

/// Create a copy of MissionHistorySpot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MissionHistorySpotCopyWith<_MissionHistorySpot> get copyWith => __$MissionHistorySpotCopyWithImpl<_MissionHistorySpot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MissionHistorySpot&&(identical(other.coordinate, coordinate) || other.coordinate == coordinate)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isDestination, isDestination) || other.isDestination == isDestination)&&(identical(other.streetViewImagePath, streetViewImagePath) || other.streetViewImagePath == streetViewImagePath)&&(identical(other.userPhotoPath, userPhotoPath) || other.userPhotoPath == userPhotoPath)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt)&&(identical(other.name, name) || other.name == name)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.googleMapsUrl, googleMapsUrl) || other.googleMapsUrl == googleMapsUrl)&&(identical(other.referenceHeading, referenceHeading) || other.referenceHeading == referenceHeading)&&(identical(other.judgeRank, judgeRank) || other.judgeRank == judgeRank)&&(identical(other.distanceErrorMeters, distanceErrorMeters) || other.distanceErrorMeters == distanceErrorMeters)&&(identical(other.headingErrorDegrees, headingErrorDegrees) || other.headingErrorDegrees == headingErrorDegrees)&&(identical(other.guessPosition, guessPosition) || other.guessPosition == guessPosition)&&(identical(other.capturedHeading, capturedHeading) || other.capturedHeading == capturedHeading)&&(identical(other.zoomLevel, zoomLevel) || other.zoomLevel == zoomLevel)&&(identical(other.spotId, spotId) || other.spotId == spotId)&&(identical(other.discovererUid, discovererUid) || other.discovererUid == discovererUid)&&(identical(other.discovererNickname, discovererNickname) || other.discovererNickname == discovererNickname)&&(identical(other.discovererThumbPath, discovererThumbPath) || other.discovererThumbPath == discovererThumbPath)&&(identical(other.discovererJudgement, discovererJudgement) || other.discovererJudgement == discovererJudgement)&&(identical(other.isCleared, isCleared) || other.isCleared == isCleared));
}


@override
int get hashCode => Object.hashAll([runtimeType,coordinate,sortOrder,isDestination,streetViewImagePath,userPhotoPath,achievedAt,name,genre,googleMapsUrl,referenceHeading,judgeRank,distanceErrorMeters,headingErrorDegrees,guessPosition,capturedHeading,zoomLevel,spotId,discovererUid,discovererNickname,discovererThumbPath,discovererJudgement,isCleared]);

@override
String toString() {
  return 'MissionHistorySpot(coordinate: $coordinate, sortOrder: $sortOrder, isDestination: $isDestination, streetViewImagePath: $streetViewImagePath, userPhotoPath: $userPhotoPath, achievedAt: $achievedAt, name: $name, genre: $genre, googleMapsUrl: $googleMapsUrl, referenceHeading: $referenceHeading, judgeRank: $judgeRank, distanceErrorMeters: $distanceErrorMeters, headingErrorDegrees: $headingErrorDegrees, guessPosition: $guessPosition, capturedHeading: $capturedHeading, zoomLevel: $zoomLevel, spotId: $spotId, discovererUid: $discovererUid, discovererNickname: $discovererNickname, discovererThumbPath: $discovererThumbPath, discovererJudgement: $discovererJudgement, isCleared: $isCleared)';
}


}

/// @nodoc
abstract mixin class _$MissionHistorySpotCopyWith<$Res> implements $MissionHistorySpotCopyWith<$Res> {
  factory _$MissionHistorySpotCopyWith(_MissionHistorySpot value, $Res Function(_MissionHistorySpot) _then) = __$MissionHistorySpotCopyWithImpl;
@override @useResult
$Res call({
 Coordinate coordinate, int sortOrder, bool isDestination, String streetViewImagePath, String? userPhotoPath, DateTime? achievedAt, String? name, String? genre, String? googleMapsUrl, double? referenceHeading, PhotoJudgeRank? judgeRank, double? distanceErrorMeters, double? headingErrorDegrees, Coordinate? guessPosition, double? capturedHeading, double? zoomLevel, SpotId? spotId, String? discovererUid, String? discovererNickname, String? discovererThumbPath, PhotoJudgement? discovererJudgement, bool isCleared
});


@override $PhotoJudgementCopyWith<$Res>? get discovererJudgement;

}
/// @nodoc
class __$MissionHistorySpotCopyWithImpl<$Res>
    implements _$MissionHistorySpotCopyWith<$Res> {
  __$MissionHistorySpotCopyWithImpl(this._self, this._then);

  final _MissionHistorySpot _self;
  final $Res Function(_MissionHistorySpot) _then;

/// Create a copy of MissionHistorySpot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coordinate = null,Object? sortOrder = null,Object? isDestination = null,Object? streetViewImagePath = null,Object? userPhotoPath = freezed,Object? achievedAt = freezed,Object? name = freezed,Object? genre = freezed,Object? googleMapsUrl = freezed,Object? referenceHeading = freezed,Object? judgeRank = freezed,Object? distanceErrorMeters = freezed,Object? headingErrorDegrees = freezed,Object? guessPosition = freezed,Object? capturedHeading = freezed,Object? zoomLevel = freezed,Object? spotId = freezed,Object? discovererUid = freezed,Object? discovererNickname = freezed,Object? discovererThumbPath = freezed,Object? discovererJudgement = freezed,Object? isCleared = null,}) {
  return _then(_MissionHistorySpot(
coordinate: null == coordinate ? _self.coordinate : coordinate // ignore: cast_nullable_to_non_nullable
as Coordinate,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isDestination: null == isDestination ? _self.isDestination : isDestination // ignore: cast_nullable_to_non_nullable
as bool,streetViewImagePath: null == streetViewImagePath ? _self.streetViewImagePath : streetViewImagePath // ignore: cast_nullable_to_non_nullable
as String,userPhotoPath: freezed == userPhotoPath ? _self.userPhotoPath : userPhotoPath // ignore: cast_nullable_to_non_nullable
as String?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,googleMapsUrl: freezed == googleMapsUrl ? _self.googleMapsUrl : googleMapsUrl // ignore: cast_nullable_to_non_nullable
as String?,referenceHeading: freezed == referenceHeading ? _self.referenceHeading : referenceHeading // ignore: cast_nullable_to_non_nullable
as double?,judgeRank: freezed == judgeRank ? _self.judgeRank : judgeRank // ignore: cast_nullable_to_non_nullable
as PhotoJudgeRank?,distanceErrorMeters: freezed == distanceErrorMeters ? _self.distanceErrorMeters : distanceErrorMeters // ignore: cast_nullable_to_non_nullable
as double?,headingErrorDegrees: freezed == headingErrorDegrees ? _self.headingErrorDegrees : headingErrorDegrees // ignore: cast_nullable_to_non_nullable
as double?,guessPosition: freezed == guessPosition ? _self.guessPosition : guessPosition // ignore: cast_nullable_to_non_nullable
as Coordinate?,capturedHeading: freezed == capturedHeading ? _self.capturedHeading : capturedHeading // ignore: cast_nullable_to_non_nullable
as double?,zoomLevel: freezed == zoomLevel ? _self.zoomLevel : zoomLevel // ignore: cast_nullable_to_non_nullable
as double?,spotId: freezed == spotId ? _self.spotId : spotId // ignore: cast_nullable_to_non_nullable
as SpotId?,discovererUid: freezed == discovererUid ? _self.discovererUid : discovererUid // ignore: cast_nullable_to_non_nullable
as String?,discovererNickname: freezed == discovererNickname ? _self.discovererNickname : discovererNickname // ignore: cast_nullable_to_non_nullable
as String?,discovererThumbPath: freezed == discovererThumbPath ? _self.discovererThumbPath : discovererThumbPath // ignore: cast_nullable_to_non_nullable
as String?,discovererJudgement: freezed == discovererJudgement ? _self.discovererJudgement : discovererJudgement // ignore: cast_nullable_to_non_nullable
as PhotoJudgement?,isCleared: null == isCleared ? _self.isCleared : isCleared // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MissionHistorySpot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PhotoJudgementCopyWith<$Res>? get discovererJudgement {
    if (_self.discovererJudgement == null) {
    return null;
  }

  return $PhotoJudgementCopyWith<$Res>(_self.discovererJudgement!, (value) {
    return _then(_self.copyWith(discovererJudgement: value));
  });
}
}

// dart format on
