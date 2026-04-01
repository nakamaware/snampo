// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MissionSettings {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionSettings);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MissionSettings()';
}


}

/// @nodoc
class $MissionSettingsCopyWith<$Res>  {
$MissionSettingsCopyWith(MissionSettings _, $Res Function(MissionSettings) __);
}


/// Adds pattern-matching-related methods to [MissionSettings].
extension MissionSettingsPatterns on MissionSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MissionSettingsRandom value)?  random,TResult Function( MissionSettingsDestination value)?  destination,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MissionSettingsRandom() when random != null:
return random(_that);case MissionSettingsDestination() when destination != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MissionSettingsRandom value)  random,required TResult Function( MissionSettingsDestination value)  destination,}){
final _that = this;
switch (_that) {
case MissionSettingsRandom():
return random(_that);case MissionSettingsDestination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MissionSettingsRandom value)?  random,TResult? Function( MissionSettingsDestination value)?  destination,}){
final _that = this;
switch (_that) {
case MissionSettingsRandom() when random != null:
return random(_that);case MissionSettingsDestination() when destination != null:
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
case MissionSettingsRandom() when random != null:
return random(_that.radius);case MissionSettingsDestination() when destination != null:
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
case MissionSettingsRandom():
return random(_that.radius);case MissionSettingsDestination():
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
case MissionSettingsRandom() when random != null:
return random(_that.radius);case MissionSettingsDestination() when destination != null:
return destination(_that.destination);case _:
  return null;

}
}

}

/// @nodoc


class MissionSettingsRandom implements MissionSettings {
  const MissionSettingsRandom({required this.radius});


 final  Radius radius;

/// Create a copy of MissionSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionSettingsRandomCopyWith<MissionSettingsRandom> get copyWith => _$MissionSettingsRandomCopyWithImpl<MissionSettingsRandom>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionSettingsRandom&&(identical(other.radius, radius) || other.radius == radius));
}


@override
int get hashCode => Object.hash(runtimeType,radius);

@override
String toString() {
  return 'MissionSettings.random(radius: $radius)';
}


}

/// @nodoc
abstract mixin class $MissionSettingsRandomCopyWith<$Res> implements $MissionSettingsCopyWith<$Res> {
  factory $MissionSettingsRandomCopyWith(MissionSettingsRandom value, $Res Function(MissionSettingsRandom) _then) = _$MissionSettingsRandomCopyWithImpl;
@useResult
$Res call({
 Radius radius
});


$RadiusCopyWith<$Res> get radius;

}
/// @nodoc
class _$MissionSettingsRandomCopyWithImpl<$Res>
    implements $MissionSettingsRandomCopyWith<$Res> {
  _$MissionSettingsRandomCopyWithImpl(this._self, this._then);

  final MissionSettingsRandom _self;
  final $Res Function(MissionSettingsRandom) _then;

/// Create a copy of MissionSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? radius = null,}) {
  return _then(MissionSettingsRandom(
radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as Radius,
  ));
}

/// Create a copy of MissionSettings
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


class MissionSettingsDestination implements MissionSettings {
  const MissionSettingsDestination({required this.destination});


 final  Coordinate destination;

/// Create a copy of MissionSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionSettingsDestinationCopyWith<MissionSettingsDestination> get copyWith => _$MissionSettingsDestinationCopyWithImpl<MissionSettingsDestination>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionSettingsDestination&&(identical(other.destination, destination) || other.destination == destination));
}


@override
int get hashCode => Object.hash(runtimeType,destination);

@override
String toString() {
  return 'MissionSettings.destination(destination: $destination)';
}


}

/// @nodoc
abstract mixin class $MissionSettingsDestinationCopyWith<$Res> implements $MissionSettingsCopyWith<$Res> {
  factory $MissionSettingsDestinationCopyWith(MissionSettingsDestination value, $Res Function(MissionSettingsDestination) _then) = _$MissionSettingsDestinationCopyWithImpl;
@useResult
$Res call({
 Coordinate destination
});


$CoordinateCopyWith<$Res> get destination;

}
/// @nodoc
class _$MissionSettingsDestinationCopyWithImpl<$Res>
    implements $MissionSettingsDestinationCopyWith<$Res> {
  _$MissionSettingsDestinationCopyWithImpl(this._self, this._then);

  final MissionSettingsDestination _self;
  final $Res Function(MissionSettingsDestination) _then;

/// Create a copy of MissionSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? destination = null,}) {
  return _then(MissionSettingsDestination(
destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as Coordinate,
  ));
}

/// Create a copy of MissionSettings
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
