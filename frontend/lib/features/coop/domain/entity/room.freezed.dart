// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoomSettings {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomSettings);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RoomSettings()';
}


}

/// @nodoc
class $RoomSettingsCopyWith<$Res>  {
$RoomSettingsCopyWith(RoomSettings _, $Res Function(RoomSettings) __);
}


/// Adds pattern-matching-related methods to [RoomSettings].
extension RoomSettingsPatterns on RoomSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RoomSettingsRandom value)?  random,TResult Function( RoomSettingsDestination value)?  destination,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RoomSettingsRandom() when random != null:
return random(_that);case RoomSettingsDestination() when destination != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RoomSettingsRandom value)  random,required TResult Function( RoomSettingsDestination value)  destination,}){
final _that = this;
switch (_that) {
case RoomSettingsRandom():
return random(_that);case RoomSettingsDestination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RoomSettingsRandom value)?  random,TResult? Function( RoomSettingsDestination value)?  destination,}){
final _that = this;
switch (_that) {
case RoomSettingsRandom() when random != null:
return random(_that);case RoomSettingsDestination() when destination != null:
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
case RoomSettingsRandom() when random != null:
return random(_that.radius);case RoomSettingsDestination() when destination != null:
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
case RoomSettingsRandom():
return random(_that.radius);case RoomSettingsDestination():
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
case RoomSettingsRandom() when random != null:
return random(_that.radius);case RoomSettingsDestination() when destination != null:
return destination(_that.destination);case _:
  return null;

}
}

}

/// @nodoc


class RoomSettingsRandom implements RoomSettings {
  const RoomSettingsRandom({required this.radius});


 final  Radius radius;

/// Create a copy of RoomSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomSettingsRandomCopyWith<RoomSettingsRandom> get copyWith => _$RoomSettingsRandomCopyWithImpl<RoomSettingsRandom>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomSettingsRandom&&(identical(other.radius, radius) || other.radius == radius));
}


@override
int get hashCode => Object.hash(runtimeType,radius);

@override
String toString() {
  return 'RoomSettings.random(radius: $radius)';
}


}

/// @nodoc
abstract mixin class $RoomSettingsRandomCopyWith<$Res> implements $RoomSettingsCopyWith<$Res> {
  factory $RoomSettingsRandomCopyWith(RoomSettingsRandom value, $Res Function(RoomSettingsRandom) _then) = _$RoomSettingsRandomCopyWithImpl;
@useResult
$Res call({
 Radius radius
});




}
/// @nodoc
class _$RoomSettingsRandomCopyWithImpl<$Res>
    implements $RoomSettingsRandomCopyWith<$Res> {
  _$RoomSettingsRandomCopyWithImpl(this._self, this._then);

  final RoomSettingsRandom _self;
  final $Res Function(RoomSettingsRandom) _then;

/// Create a copy of RoomSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? radius = null,}) {
  return _then(RoomSettingsRandom(
radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as Radius,
  ));
}


}

/// @nodoc


class RoomSettingsDestination implements RoomSettings {
  const RoomSettingsDestination({required this.destination});


 final  Coordinate destination;

/// Create a copy of RoomSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomSettingsDestinationCopyWith<RoomSettingsDestination> get copyWith => _$RoomSettingsDestinationCopyWithImpl<RoomSettingsDestination>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoomSettingsDestination&&(identical(other.destination, destination) || other.destination == destination));
}


@override
int get hashCode => Object.hash(runtimeType,destination);

@override
String toString() {
  return 'RoomSettings.destination(destination: $destination)';
}


}

/// @nodoc
abstract mixin class $RoomSettingsDestinationCopyWith<$Res> implements $RoomSettingsCopyWith<$Res> {
  factory $RoomSettingsDestinationCopyWith(RoomSettingsDestination value, $Res Function(RoomSettingsDestination) _then) = _$RoomSettingsDestinationCopyWithImpl;
@useResult
$Res call({
 Coordinate destination
});




}
/// @nodoc
class _$RoomSettingsDestinationCopyWithImpl<$Res>
    implements $RoomSettingsDestinationCopyWith<$Res> {
  _$RoomSettingsDestinationCopyWithImpl(this._self, this._then);

  final RoomSettingsDestination _self;
  final $Res Function(RoomSettingsDestination) _then;

/// Create a copy of RoomSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? destination = null,}) {
  return _then(RoomSettingsDestination(
destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as Coordinate,
  ));
}


}

/// @nodoc
mixin _$Room {

 RoomCode get code;/// ホストの Auth uid
 String get hostId; RoomStatus get status; RoomSettings get settings; DateTime get createdAt;/// 遊べる期限 (作成から 12 時間)。これを過ぎると書き込みをすべて拒否する
 DateTime get expiresAt;/// データの保持期限 (作成から 7 日)。TTL で削除する
 DateTime get deleteAt;/// Storage のバンドルのパス。playing で必須
 String? get missionRef;/// バンドル内のスポットの並び順
 List<SpotId> get spotIds;/// generating が失敗したときの理由
 String? get generationError; FinishReason? get finishReason; DateTime? get startedAt; DateTime? get finishedAt;
/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoomCopyWith<Room> get copyWith => _$RoomCopyWithImpl<Room>(this as Room, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Room&&(identical(other.code, code) || other.code == code)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.status, status) || other.status == status)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.deleteAt, deleteAt) || other.deleteAt == deleteAt)&&(identical(other.missionRef, missionRef) || other.missionRef == missionRef)&&const DeepCollectionEquality().equals(other.spotIds, spotIds)&&(identical(other.generationError, generationError) || other.generationError == generationError)&&(identical(other.finishReason, finishReason) || other.finishReason == finishReason)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt));
}


@override
int get hashCode => Object.hash(runtimeType,code,hostId,status,settings,createdAt,expiresAt,deleteAt,missionRef,const DeepCollectionEquality().hash(spotIds),generationError,finishReason,startedAt,finishedAt);

@override
String toString() {
  return 'Room(code: $code, hostId: $hostId, status: $status, settings: $settings, createdAt: $createdAt, expiresAt: $expiresAt, deleteAt: $deleteAt, missionRef: $missionRef, spotIds: $spotIds, generationError: $generationError, finishReason: $finishReason, startedAt: $startedAt, finishedAt: $finishedAt)';
}


}

/// @nodoc
abstract mixin class $RoomCopyWith<$Res>  {
  factory $RoomCopyWith(Room value, $Res Function(Room) _then) = _$RoomCopyWithImpl;
@useResult
$Res call({
 RoomCode code, String hostId, RoomStatus status, RoomSettings settings, DateTime createdAt, DateTime expiresAt, DateTime deleteAt, String? missionRef, List<SpotId> spotIds, String? generationError, FinishReason? finishReason, DateTime? startedAt, DateTime? finishedAt
});


$RoomSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$RoomCopyWithImpl<$Res>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._self, this._then);

  final Room _self;
  final $Res Function(Room) _then;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? hostId = null,Object? status = null,Object? settings = null,Object? createdAt = null,Object? expiresAt = null,Object? deleteAt = null,Object? missionRef = freezed,Object? spotIds = null,Object? generationError = freezed,Object? finishReason = freezed,Object? startedAt = freezed,Object? finishedAt = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as RoomCode,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RoomStatus,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as RoomSettings,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,deleteAt: null == deleteAt ? _self.deleteAt : deleteAt // ignore: cast_nullable_to_non_nullable
as DateTime,missionRef: freezed == missionRef ? _self.missionRef : missionRef // ignore: cast_nullable_to_non_nullable
as String?,spotIds: null == spotIds ? _self.spotIds : spotIds // ignore: cast_nullable_to_non_nullable
as List<SpotId>,generationError: freezed == generationError ? _self.generationError : generationError // ignore: cast_nullable_to_non_nullable
as String?,finishReason: freezed == finishReason ? _self.finishReason : finishReason // ignore: cast_nullable_to_non_nullable
as FinishReason?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoomSettingsCopyWith<$Res> get settings {

  return $RoomSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [Room].
extension RoomPatterns on Room {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Room value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Room() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Room value)  $default,){
final _that = this;
switch (_that) {
case _Room():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Room value)?  $default,){
final _that = this;
switch (_that) {
case _Room() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RoomCode code,  String hostId,  RoomStatus status,  RoomSettings settings,  DateTime createdAt,  DateTime expiresAt,  DateTime deleteAt,  String? missionRef,  List<SpotId> spotIds,  String? generationError,  FinishReason? finishReason,  DateTime? startedAt,  DateTime? finishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Room() when $default != null:
return $default(_that.code,_that.hostId,_that.status,_that.settings,_that.createdAt,_that.expiresAt,_that.deleteAt,_that.missionRef,_that.spotIds,_that.generationError,_that.finishReason,_that.startedAt,_that.finishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RoomCode code,  String hostId,  RoomStatus status,  RoomSettings settings,  DateTime createdAt,  DateTime expiresAt,  DateTime deleteAt,  String? missionRef,  List<SpotId> spotIds,  String? generationError,  FinishReason? finishReason,  DateTime? startedAt,  DateTime? finishedAt)  $default,) {final _that = this;
switch (_that) {
case _Room():
return $default(_that.code,_that.hostId,_that.status,_that.settings,_that.createdAt,_that.expiresAt,_that.deleteAt,_that.missionRef,_that.spotIds,_that.generationError,_that.finishReason,_that.startedAt,_that.finishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RoomCode code,  String hostId,  RoomStatus status,  RoomSettings settings,  DateTime createdAt,  DateTime expiresAt,  DateTime deleteAt,  String? missionRef,  List<SpotId> spotIds,  String? generationError,  FinishReason? finishReason,  DateTime? startedAt,  DateTime? finishedAt)?  $default,) {final _that = this;
switch (_that) {
case _Room() when $default != null:
return $default(_that.code,_that.hostId,_that.status,_that.settings,_that.createdAt,_that.expiresAt,_that.deleteAt,_that.missionRef,_that.spotIds,_that.generationError,_that.finishReason,_that.startedAt,_that.finishedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Room extends Room {
  const _Room({required this.code, required this.hostId, required this.status, required this.settings, required this.createdAt, required this.expiresAt, required this.deleteAt, this.missionRef, final  List<SpotId> spotIds = const [], this.generationError, this.finishReason, this.startedAt, this.finishedAt}): _spotIds = spotIds,super._();


@override final  RoomCode code;
/// ホストの Auth uid
@override final  String hostId;
@override final  RoomStatus status;
@override final  RoomSettings settings;
@override final  DateTime createdAt;
/// 遊べる期限 (作成から 12 時間)。これを過ぎると書き込みをすべて拒否する
@override final  DateTime expiresAt;
/// データの保持期限 (作成から 7 日)。TTL で削除する
@override final  DateTime deleteAt;
/// Storage のバンドルのパス。playing で必須
@override final  String? missionRef;
/// バンドル内のスポットの並び順
 final  List<SpotId> _spotIds;
/// バンドル内のスポットの並び順
@override@JsonKey() List<SpotId> get spotIds {
  if (_spotIds is EqualUnmodifiableListView) return _spotIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spotIds);
}

/// generating が失敗したときの理由
@override final  String? generationError;
@override final  FinishReason? finishReason;
@override final  DateTime? startedAt;
@override final  DateTime? finishedAt;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoomCopyWith<_Room> get copyWith => __$RoomCopyWithImpl<_Room>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Room&&(identical(other.code, code) || other.code == code)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.status, status) || other.status == status)&&(identical(other.settings, settings) || other.settings == settings)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.deleteAt, deleteAt) || other.deleteAt == deleteAt)&&(identical(other.missionRef, missionRef) || other.missionRef == missionRef)&&const DeepCollectionEquality().equals(other._spotIds, _spotIds)&&(identical(other.generationError, generationError) || other.generationError == generationError)&&(identical(other.finishReason, finishReason) || other.finishReason == finishReason)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt));
}


@override
int get hashCode => Object.hash(runtimeType,code,hostId,status,settings,createdAt,expiresAt,deleteAt,missionRef,const DeepCollectionEquality().hash(_spotIds),generationError,finishReason,startedAt,finishedAt);

@override
String toString() {
  return 'Room(code: $code, hostId: $hostId, status: $status, settings: $settings, createdAt: $createdAt, expiresAt: $expiresAt, deleteAt: $deleteAt, missionRef: $missionRef, spotIds: $spotIds, generationError: $generationError, finishReason: $finishReason, startedAt: $startedAt, finishedAt: $finishedAt)';
}


}

/// @nodoc
abstract mixin class _$RoomCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$RoomCopyWith(_Room value, $Res Function(_Room) _then) = __$RoomCopyWithImpl;
@override @useResult
$Res call({
 RoomCode code, String hostId, RoomStatus status, RoomSettings settings, DateTime createdAt, DateTime expiresAt, DateTime deleteAt, String? missionRef, List<SpotId> spotIds, String? generationError, FinishReason? finishReason, DateTime? startedAt, DateTime? finishedAt
});


@override $RoomSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class __$RoomCopyWithImpl<$Res>
    implements _$RoomCopyWith<$Res> {
  __$RoomCopyWithImpl(this._self, this._then);

  final _Room _self;
  final $Res Function(_Room) _then;

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? hostId = null,Object? status = null,Object? settings = null,Object? createdAt = null,Object? expiresAt = null,Object? deleteAt = null,Object? missionRef = freezed,Object? spotIds = null,Object? generationError = freezed,Object? finishReason = freezed,Object? startedAt = freezed,Object? finishedAt = freezed,}) {
  return _then(_Room(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as RoomCode,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RoomStatus,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as RoomSettings,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,deleteAt: null == deleteAt ? _self.deleteAt : deleteAt // ignore: cast_nullable_to_non_nullable
as DateTime,missionRef: freezed == missionRef ? _self.missionRef : missionRef // ignore: cast_nullable_to_non_nullable
as String?,spotIds: null == spotIds ? _self._spotIds : spotIds // ignore: cast_nullable_to_non_nullable
as List<SpotId>,generationError: freezed == generationError ? _self.generationError : generationError // ignore: cast_nullable_to_non_nullable
as String?,finishReason: freezed == finishReason ? _self.finishReason : finishReason // ignore: cast_nullable_to_non_nullable
as FinishReason?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Room
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RoomSettingsCopyWith<$Res> get settings {

  return $RoomSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}

// dart format on
