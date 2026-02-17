// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MissionEntity {

/// 出発地点
@CoordinateConverter() Coordinate get departure;/// 目的地
@JsonKey(toJson: _destinationToJson) ImageCoordinate get destination;/// ルートのポリライン文字列
 String get overviewPolyline;/// ミッションの検索半径
@RadiusConverter() Radius get radius;/// 通過地点のリスト
@JsonKey(toJson: _waypointsToJson) List<ImageCoordinate> get waypoints;
/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionEntityCopyWith<MissionEntity> get copyWith => _$MissionEntityCopyWithImpl<MissionEntity>(this as MissionEntity, _$identity);

  /// Serializes this MissionEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionEntity&&(identical(other.departure, departure) || other.departure == departure)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.overviewPolyline, overviewPolyline) || other.overviewPolyline == overviewPolyline)&&(identical(other.radius, radius) || other.radius == radius)&&const DeepCollectionEquality().equals(other.waypoints, waypoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,departure,destination,overviewPolyline,radius,const DeepCollectionEquality().hash(waypoints));

@override
String toString() {
  return 'MissionEntity(departure: $departure, destination: $destination, overviewPolyline: $overviewPolyline, radius: $radius, waypoints: $waypoints)';
}


}

/// @nodoc
abstract mixin class $MissionEntityCopyWith<$Res>  {
  factory $MissionEntityCopyWith(MissionEntity value, $Res Function(MissionEntity) _then) = _$MissionEntityCopyWithImpl;
@useResult
$Res call({
@CoordinateConverter() Coordinate departure,@JsonKey(toJson: _destinationToJson) ImageCoordinate destination, String overviewPolyline,@RadiusConverter() Radius radius,@JsonKey(toJson: _waypointsToJson) List<ImageCoordinate> waypoints
});


$CoordinateCopyWith<$Res> get departure;$ImageCoordinateCopyWith<$Res> get destination;$RadiusCopyWith<$Res> get radius;

}
/// @nodoc
class _$MissionEntityCopyWithImpl<$Res>
    implements $MissionEntityCopyWith<$Res> {
  _$MissionEntityCopyWithImpl(this._self, this._then);

  final MissionEntity _self;
  final $Res Function(MissionEntity) _then;

/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? departure = null,Object? destination = null,Object? overviewPolyline = null,Object? radius = null,Object? waypoints = null,}) {
  return _then(_self.copyWith(
departure: null == departure ? _self.departure : departure // ignore: cast_nullable_to_non_nullable
as Coordinate,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as ImageCoordinate,overviewPolyline: null == overviewPolyline ? _self.overviewPolyline : overviewPolyline // ignore: cast_nullable_to_non_nullable
as String,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as Radius,waypoints: null == waypoints ? _self.waypoints : waypoints // ignore: cast_nullable_to_non_nullable
as List<ImageCoordinate>,
  ));
}
/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoordinateCopyWith<$Res> get departure {
  
  return $CoordinateCopyWith<$Res>(_self.departure, (value) {
    return _then(_self.copyWith(departure: value));
  });
}/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageCoordinateCopyWith<$Res> get destination {
  
  return $ImageCoordinateCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RadiusCopyWith<$Res> get radius {
  
  return $RadiusCopyWith<$Res>(_self.radius, (value) {
    return _then(_self.copyWith(radius: value));
  });
}
}


/// Adds pattern-matching-related methods to [MissionEntity].
extension MissionEntityPatterns on MissionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MissionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MissionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MissionEntity value)  $default,){
final _that = this;
switch (_that) {
case _MissionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MissionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MissionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@CoordinateConverter()  Coordinate departure, @JsonKey(toJson: _destinationToJson)  ImageCoordinate destination,  String overviewPolyline, @RadiusConverter()  Radius radius, @JsonKey(toJson: _waypointsToJson)  List<ImageCoordinate> waypoints)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MissionEntity() when $default != null:
return $default(_that.departure,_that.destination,_that.overviewPolyline,_that.radius,_that.waypoints);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@CoordinateConverter()  Coordinate departure, @JsonKey(toJson: _destinationToJson)  ImageCoordinate destination,  String overviewPolyline, @RadiusConverter()  Radius radius, @JsonKey(toJson: _waypointsToJson)  List<ImageCoordinate> waypoints)  $default,) {final _that = this;
switch (_that) {
case _MissionEntity():
return $default(_that.departure,_that.destination,_that.overviewPolyline,_that.radius,_that.waypoints);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@CoordinateConverter()  Coordinate departure, @JsonKey(toJson: _destinationToJson)  ImageCoordinate destination,  String overviewPolyline, @RadiusConverter()  Radius radius, @JsonKey(toJson: _waypointsToJson)  List<ImageCoordinate> waypoints)?  $default,) {final _that = this;
switch (_that) {
case _MissionEntity() when $default != null:
return $default(_that.departure,_that.destination,_that.overviewPolyline,_that.radius,_that.waypoints);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MissionEntity extends MissionEntity {
  const _MissionEntity({@CoordinateConverter() required this.departure, @JsonKey(toJson: _destinationToJson) required this.destination, required this.overviewPolyline, @RadiusConverter() required this.radius, @JsonKey(toJson: _waypointsToJson) final  List<ImageCoordinate> waypoints = const []}): _waypoints = waypoints,super._();
  factory _MissionEntity.fromJson(Map<String, dynamic> json) => _$MissionEntityFromJson(json);

/// 出発地点
@override@CoordinateConverter() final  Coordinate departure;
/// 目的地
@override@JsonKey(toJson: _destinationToJson) final  ImageCoordinate destination;
/// ルートのポリライン文字列
@override final  String overviewPolyline;
/// ミッションの検索半径
@override@RadiusConverter() final  Radius radius;
/// 通過地点のリスト
 final  List<ImageCoordinate> _waypoints;
/// 通過地点のリスト
@override@JsonKey(toJson: _waypointsToJson) List<ImageCoordinate> get waypoints {
  if (_waypoints is EqualUnmodifiableListView) return _waypoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waypoints);
}


/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MissionEntityCopyWith<_MissionEntity> get copyWith => __$MissionEntityCopyWithImpl<_MissionEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MissionEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MissionEntity&&(identical(other.departure, departure) || other.departure == departure)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.overviewPolyline, overviewPolyline) || other.overviewPolyline == overviewPolyline)&&(identical(other.radius, radius) || other.radius == radius)&&const DeepCollectionEquality().equals(other._waypoints, _waypoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,departure,destination,overviewPolyline,radius,const DeepCollectionEquality().hash(_waypoints));

@override
String toString() {
  return 'MissionEntity(departure: $departure, destination: $destination, overviewPolyline: $overviewPolyline, radius: $radius, waypoints: $waypoints)';
}


}

/// @nodoc
abstract mixin class _$MissionEntityCopyWith<$Res> implements $MissionEntityCopyWith<$Res> {
  factory _$MissionEntityCopyWith(_MissionEntity value, $Res Function(_MissionEntity) _then) = __$MissionEntityCopyWithImpl;
@override @useResult
$Res call({
@CoordinateConverter() Coordinate departure,@JsonKey(toJson: _destinationToJson) ImageCoordinate destination, String overviewPolyline,@RadiusConverter() Radius radius,@JsonKey(toJson: _waypointsToJson) List<ImageCoordinate> waypoints
});


@override $CoordinateCopyWith<$Res> get departure;@override $ImageCoordinateCopyWith<$Res> get destination;@override $RadiusCopyWith<$Res> get radius;

}
/// @nodoc
class __$MissionEntityCopyWithImpl<$Res>
    implements _$MissionEntityCopyWith<$Res> {
  __$MissionEntityCopyWithImpl(this._self, this._then);

  final _MissionEntity _self;
  final $Res Function(_MissionEntity) _then;

/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? departure = null,Object? destination = null,Object? overviewPolyline = null,Object? radius = null,Object? waypoints = null,}) {
  return _then(_MissionEntity(
departure: null == departure ? _self.departure : departure // ignore: cast_nullable_to_non_nullable
as Coordinate,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as ImageCoordinate,overviewPolyline: null == overviewPolyline ? _self.overviewPolyline : overviewPolyline // ignore: cast_nullable_to_non_nullable
as String,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as Radius,waypoints: null == waypoints ? _self._waypoints : waypoints // ignore: cast_nullable_to_non_nullable
as List<ImageCoordinate>,
  ));
}

/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoordinateCopyWith<$Res> get departure {
  
  return $CoordinateCopyWith<$Res>(_self.departure, (value) {
    return _then(_self.copyWith(departure: value));
  });
}/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageCoordinateCopyWith<$Res> get destination {
  
  return $ImageCoordinateCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}/// Create a copy of MissionEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RadiusCopyWith<$Res> get radius {
  
  return $RadiusCopyWith<$Res>(_self.radius, (value) {
    return _then(_self.copyWith(radius: value));
  });
}
}

// dart format on
