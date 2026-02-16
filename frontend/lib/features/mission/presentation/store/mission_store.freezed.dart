// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MissionStoreParams {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionStoreParams);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MissionStoreParams()';
}


}

/// @nodoc
class $MissionStoreParamsCopyWith<$Res>  {
$MissionStoreParamsCopyWith(MissionStoreParams _, $Res Function(MissionStoreParams) __);
}


/// Adds pattern-matching-related methods to [MissionStoreParams].
extension MissionStoreParamsPatterns on MissionStoreParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MissionStoreParamsRandom value)?  random,TResult Function( MissionStoreParamsDestination value)?  destination,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MissionStoreParamsRandom() when random != null:
return random(_that);case MissionStoreParamsDestination() when destination != null:
return destination(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MissionStoreParamsRandom value)  random,required TResult Function( MissionStoreParamsDestination value)  destination,}){
final _that = this;
switch (_that) {
case MissionStoreParamsRandom():
return random(_that);case MissionStoreParamsDestination():
return destination(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MissionStoreParamsRandom value)?  random,TResult? Function( MissionStoreParamsDestination value)?  destination,}){
final _that = this;
switch (_that) {
case MissionStoreParamsRandom() when random != null:
return random(_that);case MissionStoreParamsDestination() when destination != null:
return destination(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Radius radius)?  random,TResult Function( Coordinate destination)?  destination,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MissionStoreParamsRandom() when random != null:
return random(_that.radius);case MissionStoreParamsDestination() when destination != null:
return destination(_that.destination);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Radius radius)  random,required TResult Function( Coordinate destination)  destination,}) {final _that = this;
switch (_that) {
case MissionStoreParamsRandom():
return random(_that.radius);case MissionStoreParamsDestination():
return destination(_that.destination);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Radius radius)?  random,TResult? Function( Coordinate destination)?  destination,}) {final _that = this;
switch (_that) {
case MissionStoreParamsRandom() when random != null:
return random(_that.radius);case MissionStoreParamsDestination() when destination != null:
return destination(_that.destination);case _:
  return null;

}
}

}

/// @nodoc


class MissionStoreParamsRandom implements MissionStoreParams {
  const MissionStoreParamsRandom({required this.radius});


 final  Radius radius;

/// Create a copy of MissionStoreParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionStoreParamsRandomCopyWith<MissionStoreParamsRandom> get copyWith => _$MissionStoreParamsRandomCopyWithImpl<MissionStoreParamsRandom>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionStoreParamsRandom&&(identical(other.radius, radius) || other.radius == radius));
}


@override
int get hashCode => Object.hash(runtimeType,radius);

@override
String toString() {
  return 'MissionStoreParams.random(radius: $radius)';
}


}

/// @nodoc
abstract mixin class $MissionStoreParamsRandomCopyWith<$Res> implements $MissionStoreParamsCopyWith<$Res> {
  factory $MissionStoreParamsRandomCopyWith(MissionStoreParamsRandom value, $Res Function(MissionStoreParamsRandom) _then) = _$MissionStoreParamsRandomCopyWithImpl;
@useResult
$Res call({
 Radius radius
});


$RadiusCopyWith<$Res> get radius;

}
/// @nodoc
class _$MissionStoreParamsRandomCopyWithImpl<$Res>
    implements $MissionStoreParamsRandomCopyWith<$Res> {
  _$MissionStoreParamsRandomCopyWithImpl(this._self, this._then);

  final MissionStoreParamsRandom _self;
  final $Res Function(MissionStoreParamsRandom) _then;

/// Create a copy of MissionStoreParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? radius = null,}) {
  return _then(MissionStoreParamsRandom(
radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as Radius,
  ));
}

/// Create a copy of MissionStoreParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RadiusCopyWith<$Res> get radius {

  return $RadiusCopyWith<$Res>(_self.radius, (value) {
    return _then(_self.copyWith(radius: value));
  });
}
}

/// @nodoc


class MissionStoreParamsDestination implements MissionStoreParams {
  const MissionStoreParamsDestination({required this.destination});


 final  Coordinate destination;

/// Create a copy of MissionStoreParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionStoreParamsDestinationCopyWith<MissionStoreParamsDestination> get copyWith => _$MissionStoreParamsDestinationCopyWithImpl<MissionStoreParamsDestination>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionStoreParamsDestination&&(identical(other.destination, destination) || other.destination == destination));
}


@override
int get hashCode => Object.hash(runtimeType,destination);

@override
String toString() {
  return 'MissionStoreParams.destination(destination: $destination)';
}


}

/// @nodoc
abstract mixin class $MissionStoreParamsDestinationCopyWith<$Res> implements $MissionStoreParamsCopyWith<$Res> {
  factory $MissionStoreParamsDestinationCopyWith(MissionStoreParamsDestination value, $Res Function(MissionStoreParamsDestination) _then) = _$MissionStoreParamsDestinationCopyWithImpl;
@useResult
$Res call({
 Coordinate destination
});


$CoordinateCopyWith<$Res> get destination;

}
/// @nodoc
class _$MissionStoreParamsDestinationCopyWithImpl<$Res>
    implements $MissionStoreParamsDestinationCopyWith<$Res> {
  _$MissionStoreParamsDestinationCopyWithImpl(this._self, this._then);

  final MissionStoreParamsDestination _self;
  final $Res Function(MissionStoreParamsDestination) _then;

/// Create a copy of MissionStoreParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? destination = null,}) {
  return _then(MissionStoreParamsDestination(
destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as Coordinate,
  ));
}

/// Create a copy of MissionStoreParams
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoordinateCopyWith<$Res> get destination {

  return $CoordinateCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}

// dart format on
