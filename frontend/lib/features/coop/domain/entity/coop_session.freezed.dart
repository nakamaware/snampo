// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coop_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoopSession {

 String get roomCode;/// 入室したときの Auth uid (uid が変わった場合は戻れない)
 String get uid;
/// Create a copy of CoopSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoopSessionCopyWith<CoopSession> get copyWith => _$CoopSessionCopyWithImpl<CoopSession>(this as CoopSession, _$identity);

  /// Serializes this CoopSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoopSession&&(identical(other.roomCode, roomCode) || other.roomCode == roomCode)&&(identical(other.uid, uid) || other.uid == uid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roomCode,uid);

@override
String toString() {
  return 'CoopSession(roomCode: $roomCode, uid: $uid)';
}


}

/// @nodoc
abstract mixin class $CoopSessionCopyWith<$Res>  {
  factory $CoopSessionCopyWith(CoopSession value, $Res Function(CoopSession) _then) = _$CoopSessionCopyWithImpl;
@useResult
$Res call({
 String roomCode, String uid
});




}
/// @nodoc
class _$CoopSessionCopyWithImpl<$Res>
    implements $CoopSessionCopyWith<$Res> {
  _$CoopSessionCopyWithImpl(this._self, this._then);

  final CoopSession _self;
  final $Res Function(CoopSession) _then;

/// Create a copy of CoopSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roomCode = null,Object? uid = null,}) {
  return _then(_self.copyWith(
roomCode: null == roomCode ? _self.roomCode : roomCode // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoopSession].
extension CoopSessionPatterns on CoopSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoopSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoopSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoopSession value)  $default,){
final _that = this;
switch (_that) {
case _CoopSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoopSession value)?  $default,){
final _that = this;
switch (_that) {
case _CoopSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String roomCode,  String uid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoopSession() when $default != null:
return $default(_that.roomCode,_that.uid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String roomCode,  String uid)  $default,) {final _that = this;
switch (_that) {
case _CoopSession():
return $default(_that.roomCode,_that.uid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String roomCode,  String uid)?  $default,) {final _that = this;
switch (_that) {
case _CoopSession() when $default != null:
return $default(_that.roomCode,_that.uid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoopSession implements CoopSession {
  const _CoopSession({required this.roomCode, required this.uid});
  factory _CoopSession.fromJson(Map<String, dynamic> json) => _$CoopSessionFromJson(json);

@override final  String roomCode;
/// 入室したときの Auth uid (uid が変わった場合は戻れない)
@override final  String uid;

/// Create a copy of CoopSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoopSessionCopyWith<_CoopSession> get copyWith => __$CoopSessionCopyWithImpl<_CoopSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoopSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoopSession&&(identical(other.roomCode, roomCode) || other.roomCode == roomCode)&&(identical(other.uid, uid) || other.uid == uid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roomCode,uid);

@override
String toString() {
  return 'CoopSession(roomCode: $roomCode, uid: $uid)';
}


}

/// @nodoc
abstract mixin class _$CoopSessionCopyWith<$Res> implements $CoopSessionCopyWith<$Res> {
  factory _$CoopSessionCopyWith(_CoopSession value, $Res Function(_CoopSession) _then) = __$CoopSessionCopyWithImpl;
@override @useResult
$Res call({
 String roomCode, String uid
});




}
/// @nodoc
class __$CoopSessionCopyWithImpl<$Res>
    implements _$CoopSessionCopyWith<$Res> {
  __$CoopSessionCopyWithImpl(this._self, this._then);

  final _CoopSession _self;
  final $Res Function(_CoopSession) _then;

/// Create a copy of CoopSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roomCode = null,Object? uid = null,}) {
  return _then(_CoopSession(
roomCode: null == roomCode ? _self.roomCode : roomCode // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
