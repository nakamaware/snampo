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

@CoordinateConverter() Coordinate get coordinate; int get sortOrder; bool get isDestination; String get streetViewImagePath; String? get userPhotoPath; DateTime? get achievedAt;
/// Create a copy of MissionHistorySpot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionHistorySpotCopyWith<MissionHistorySpot> get copyWith => _$MissionHistorySpotCopyWithImpl<MissionHistorySpot>(this as MissionHistorySpot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionHistorySpot&&(identical(other.coordinate, coordinate) || other.coordinate == coordinate)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isDestination, isDestination) || other.isDestination == isDestination)&&(identical(other.streetViewImagePath, streetViewImagePath) || other.streetViewImagePath == streetViewImagePath)&&(identical(other.userPhotoPath, userPhotoPath) || other.userPhotoPath == userPhotoPath)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}


@override
int get hashCode => Object.hash(runtimeType,coordinate,sortOrder,isDestination,streetViewImagePath,userPhotoPath,achievedAt);

@override
String toString() {
  return 'MissionHistorySpot(coordinate: $coordinate, sortOrder: $sortOrder, isDestination: $isDestination, streetViewImagePath: $streetViewImagePath, userPhotoPath: $userPhotoPath, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class $MissionHistorySpotCopyWith<$Res>  {
  factory $MissionHistorySpotCopyWith(MissionHistorySpot value, $Res Function(MissionHistorySpot) _then) = _$MissionHistorySpotCopyWithImpl;
@useResult
$Res call({
@CoordinateConverter() Coordinate coordinate, int sortOrder, bool isDestination, String streetViewImagePath, String? userPhotoPath, DateTime? achievedAt
});


$CoordinateCopyWith<$Res> get coordinate;

}
/// @nodoc
class _$MissionHistorySpotCopyWithImpl<$Res>
    implements $MissionHistorySpotCopyWith<$Res> {
  _$MissionHistorySpotCopyWithImpl(this._self, this._then);

  final MissionHistorySpot _self;
  final $Res Function(MissionHistorySpot) _then;

/// Create a copy of MissionHistorySpot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coordinate = null,Object? sortOrder = null,Object? isDestination = null,Object? streetViewImagePath = null,Object? userPhotoPath = freezed,Object? achievedAt = freezed,}) {
  return _then(_self.copyWith(
coordinate: null == coordinate ? _self.coordinate : coordinate // ignore: cast_nullable_to_non_nullable
as Coordinate,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isDestination: null == isDestination ? _self.isDestination : isDestination // ignore: cast_nullable_to_non_nullable
as bool,streetViewImagePath: null == streetViewImagePath ? _self.streetViewImagePath : streetViewImagePath // ignore: cast_nullable_to_non_nullable
as String,userPhotoPath: freezed == userPhotoPath ? _self.userPhotoPath : userPhotoPath // ignore: cast_nullable_to_non_nullable
as String?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of MissionHistorySpot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoordinateCopyWith<$Res> get coordinate {

  return $CoordinateCopyWith<$Res>(_self.coordinate, (value) {
    return _then(_self.copyWith(coordinate: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@CoordinateConverter()  Coordinate coordinate,  int sortOrder,  bool isDestination,  String streetViewImagePath,  String? userPhotoPath,  DateTime? achievedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MissionHistorySpot() when $default != null:
return $default(_that.coordinate,_that.sortOrder,_that.isDestination,_that.streetViewImagePath,_that.userPhotoPath,_that.achievedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@CoordinateConverter()  Coordinate coordinate,  int sortOrder,  bool isDestination,  String streetViewImagePath,  String? userPhotoPath,  DateTime? achievedAt)  $default,) {final _that = this;
switch (_that) {
case _MissionHistorySpot():
return $default(_that.coordinate,_that.sortOrder,_that.isDestination,_that.streetViewImagePath,_that.userPhotoPath,_that.achievedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@CoordinateConverter()  Coordinate coordinate,  int sortOrder,  bool isDestination,  String streetViewImagePath,  String? userPhotoPath,  DateTime? achievedAt)?  $default,) {final _that = this;
switch (_that) {
case _MissionHistorySpot() when $default != null:
return $default(_that.coordinate,_that.sortOrder,_that.isDestination,_that.streetViewImagePath,_that.userPhotoPath,_that.achievedAt);case _:
  return null;

}
}

}

/// @nodoc


class _MissionHistorySpot implements MissionHistorySpot {
  const _MissionHistorySpot({@CoordinateConverter() required this.coordinate, required this.sortOrder, required this.isDestination, required this.streetViewImagePath, this.userPhotoPath, this.achievedAt});


@override@CoordinateConverter() final  Coordinate coordinate;
@override final  int sortOrder;
@override final  bool isDestination;
@override final  String streetViewImagePath;
@override final  String? userPhotoPath;
@override final  DateTime? achievedAt;

/// Create a copy of MissionHistorySpot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MissionHistorySpotCopyWith<_MissionHistorySpot> get copyWith => __$MissionHistorySpotCopyWithImpl<_MissionHistorySpot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MissionHistorySpot&&(identical(other.coordinate, coordinate) || other.coordinate == coordinate)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isDestination, isDestination) || other.isDestination == isDestination)&&(identical(other.streetViewImagePath, streetViewImagePath) || other.streetViewImagePath == streetViewImagePath)&&(identical(other.userPhotoPath, userPhotoPath) || other.userPhotoPath == userPhotoPath)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}


@override
int get hashCode => Object.hash(runtimeType,coordinate,sortOrder,isDestination,streetViewImagePath,userPhotoPath,achievedAt);

@override
String toString() {
  return 'MissionHistorySpot(coordinate: $coordinate, sortOrder: $sortOrder, isDestination: $isDestination, streetViewImagePath: $streetViewImagePath, userPhotoPath: $userPhotoPath, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class _$MissionHistorySpotCopyWith<$Res> implements $MissionHistorySpotCopyWith<$Res> {
  factory _$MissionHistorySpotCopyWith(_MissionHistorySpot value, $Res Function(_MissionHistorySpot) _then) = __$MissionHistorySpotCopyWithImpl;
@override @useResult
$Res call({
@CoordinateConverter() Coordinate coordinate, int sortOrder, bool isDestination, String streetViewImagePath, String? userPhotoPath, DateTime? achievedAt
});


@override $CoordinateCopyWith<$Res> get coordinate;

}
/// @nodoc
class __$MissionHistorySpotCopyWithImpl<$Res>
    implements _$MissionHistorySpotCopyWith<$Res> {
  __$MissionHistorySpotCopyWithImpl(this._self, this._then);

  final _MissionHistorySpot _self;
  final $Res Function(_MissionHistorySpot) _then;

/// Create a copy of MissionHistorySpot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coordinate = null,Object? sortOrder = null,Object? isDestination = null,Object? streetViewImagePath = null,Object? userPhotoPath = freezed,Object? achievedAt = freezed,}) {
  return _then(_MissionHistorySpot(
coordinate: null == coordinate ? _self.coordinate : coordinate // ignore: cast_nullable_to_non_nullable
as Coordinate,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isDestination: null == isDestination ? _self.isDestination : isDestination // ignore: cast_nullable_to_non_nullable
as bool,streetViewImagePath: null == streetViewImagePath ? _self.streetViewImagePath : streetViewImagePath // ignore: cast_nullable_to_non_nullable
as String,userPhotoPath: freezed == userPhotoPath ? _self.userPhotoPath : userPhotoPath // ignore: cast_nullable_to_non_nullable
as String?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of MissionHistorySpot
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
