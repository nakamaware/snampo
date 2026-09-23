// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coop_history_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CoopHistoryMember {

/// Auth の uid (将来の account link と「過去に一緒に遊んだ人」のために保存する)
 String get uid; String get nickname;
/// Create a copy of CoopHistoryMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoopHistoryMemberCopyWith<CoopHistoryMember> get copyWith => _$CoopHistoryMemberCopyWithImpl<CoopHistoryMember>(this as CoopHistoryMember, _$identity);

  /// Serializes this CoopHistoryMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoopHistoryMember&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.nickname, nickname) || other.nickname == nickname));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,nickname);

@override
String toString() {
  return 'CoopHistoryMember(uid: $uid, nickname: $nickname)';
}


}

/// @nodoc
abstract mixin class $CoopHistoryMemberCopyWith<$Res>  {
  factory $CoopHistoryMemberCopyWith(CoopHistoryMember value, $Res Function(CoopHistoryMember) _then) = _$CoopHistoryMemberCopyWithImpl;
@useResult
$Res call({
 String uid, String nickname
});




}
/// @nodoc
class _$CoopHistoryMemberCopyWithImpl<$Res>
    implements $CoopHistoryMemberCopyWith<$Res> {
  _$CoopHistoryMemberCopyWithImpl(this._self, this._then);

  final CoopHistoryMember _self;
  final $Res Function(CoopHistoryMember) _then;

/// Create a copy of CoopHistoryMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? nickname = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoopHistoryMember].
extension CoopHistoryMemberPatterns on CoopHistoryMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoopHistoryMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoopHistoryMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoopHistoryMember value)  $default,){
final _that = this;
switch (_that) {
case _CoopHistoryMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoopHistoryMember value)?  $default,){
final _that = this;
switch (_that) {
case _CoopHistoryMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String nickname)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoopHistoryMember() when $default != null:
return $default(_that.uid,_that.nickname);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String nickname)  $default,) {final _that = this;
switch (_that) {
case _CoopHistoryMember():
return $default(_that.uid,_that.nickname);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String nickname)?  $default,) {final _that = this;
switch (_that) {
case _CoopHistoryMember() when $default != null:
return $default(_that.uid,_that.nickname);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoopHistoryMember implements CoopHistoryMember {
  const _CoopHistoryMember({required this.uid, required this.nickname});
  factory _CoopHistoryMember.fromJson(Map<String, dynamic> json) => _$CoopHistoryMemberFromJson(json);

/// Auth の uid (将来の account link と「過去に一緒に遊んだ人」のために保存する)
@override final  String uid;
@override final  String nickname;

/// Create a copy of CoopHistoryMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoopHistoryMemberCopyWith<_CoopHistoryMember> get copyWith => __$CoopHistoryMemberCopyWithImpl<_CoopHistoryMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoopHistoryMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoopHistoryMember&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.nickname, nickname) || other.nickname == nickname));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,nickname);

@override
String toString() {
  return 'CoopHistoryMember(uid: $uid, nickname: $nickname)';
}


}

/// @nodoc
abstract mixin class _$CoopHistoryMemberCopyWith<$Res> implements $CoopHistoryMemberCopyWith<$Res> {
  factory _$CoopHistoryMemberCopyWith(_CoopHistoryMember value, $Res Function(_CoopHistoryMember) _then) = __$CoopHistoryMemberCopyWithImpl;
@override @useResult
$Res call({
 String uid, String nickname
});




}
/// @nodoc
class __$CoopHistoryMemberCopyWithImpl<$Res>
    implements _$CoopHistoryMemberCopyWith<$Res> {
  __$CoopHistoryMemberCopyWithImpl(this._self, this._then);

  final _CoopHistoryMember _self;
  final $Res Function(_CoopHistoryMember) _then;

/// Create a copy of CoopHistoryMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? nickname = null,}) {
  return _then(_CoopHistoryMember(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CoopHistoryInfo {

 String get roomCode; CoopSyncState get syncState;/// 自分がホストだったか
 bool get isHost;/// メンバー一覧 (入室順)
 List<CoopHistoryMember> get members;/// 遊べる期限
 DateTime get expiresAt;/// データの保持期限 (これを過ぎるとサーバのデータは消えている)
 DateTime get deleteAt;
/// Create a copy of CoopHistoryInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoopHistoryInfoCopyWith<CoopHistoryInfo> get copyWith => _$CoopHistoryInfoCopyWithImpl<CoopHistoryInfo>(this as CoopHistoryInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoopHistoryInfo&&(identical(other.roomCode, roomCode) || other.roomCode == roomCode)&&(identical(other.syncState, syncState) || other.syncState == syncState)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.deleteAt, deleteAt) || other.deleteAt == deleteAt));
}


@override
int get hashCode => Object.hash(runtimeType,roomCode,syncState,isHost,const DeepCollectionEquality().hash(members),expiresAt,deleteAt);

@override
String toString() {
  return 'CoopHistoryInfo(roomCode: $roomCode, syncState: $syncState, isHost: $isHost, members: $members, expiresAt: $expiresAt, deleteAt: $deleteAt)';
}


}

/// @nodoc
abstract mixin class $CoopHistoryInfoCopyWith<$Res>  {
  factory $CoopHistoryInfoCopyWith(CoopHistoryInfo value, $Res Function(CoopHistoryInfo) _then) = _$CoopHistoryInfoCopyWithImpl;
@useResult
$Res call({
 String roomCode, CoopSyncState syncState, bool isHost, List<CoopHistoryMember> members, DateTime expiresAt, DateTime deleteAt
});




}
/// @nodoc
class _$CoopHistoryInfoCopyWithImpl<$Res>
    implements $CoopHistoryInfoCopyWith<$Res> {
  _$CoopHistoryInfoCopyWithImpl(this._self, this._then);

  final CoopHistoryInfo _self;
  final $Res Function(CoopHistoryInfo) _then;

/// Create a copy of CoopHistoryInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roomCode = null,Object? syncState = null,Object? isHost = null,Object? members = null,Object? expiresAt = null,Object? deleteAt = null,}) {
  return _then(_self.copyWith(
roomCode: null == roomCode ? _self.roomCode : roomCode // ignore: cast_nullable_to_non_nullable
as String,syncState: null == syncState ? _self.syncState : syncState // ignore: cast_nullable_to_non_nullable
as CoopSyncState,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<CoopHistoryMember>,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,deleteAt: null == deleteAt ? _self.deleteAt : deleteAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CoopHistoryInfo].
extension CoopHistoryInfoPatterns on CoopHistoryInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoopHistoryInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoopHistoryInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoopHistoryInfo value)  $default,){
final _that = this;
switch (_that) {
case _CoopHistoryInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoopHistoryInfo value)?  $default,){
final _that = this;
switch (_that) {
case _CoopHistoryInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String roomCode,  CoopSyncState syncState,  bool isHost,  List<CoopHistoryMember> members,  DateTime expiresAt,  DateTime deleteAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoopHistoryInfo() when $default != null:
return $default(_that.roomCode,_that.syncState,_that.isHost,_that.members,_that.expiresAt,_that.deleteAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String roomCode,  CoopSyncState syncState,  bool isHost,  List<CoopHistoryMember> members,  DateTime expiresAt,  DateTime deleteAt)  $default,) {final _that = this;
switch (_that) {
case _CoopHistoryInfo():
return $default(_that.roomCode,_that.syncState,_that.isHost,_that.members,_that.expiresAt,_that.deleteAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String roomCode,  CoopSyncState syncState,  bool isHost,  List<CoopHistoryMember> members,  DateTime expiresAt,  DateTime deleteAt)?  $default,) {final _that = this;
switch (_that) {
case _CoopHistoryInfo() when $default != null:
return $default(_that.roomCode,_that.syncState,_that.isHost,_that.members,_that.expiresAt,_that.deleteAt);case _:
  return null;

}
}

}

/// @nodoc


class _CoopHistoryInfo implements CoopHistoryInfo {
  const _CoopHistoryInfo({required this.roomCode, required this.syncState, required this.isHost, required final  List<CoopHistoryMember> members, required this.expiresAt, required this.deleteAt}): _members = members;


@override final  String roomCode;
@override final  CoopSyncState syncState;
/// 自分がホストだったか
@override final  bool isHost;
/// メンバー一覧 (入室順)
 final  List<CoopHistoryMember> _members;
/// メンバー一覧 (入室順)
@override List<CoopHistoryMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

/// 遊べる期限
@override final  DateTime expiresAt;
/// データの保持期限 (これを過ぎるとサーバのデータは消えている)
@override final  DateTime deleteAt;

/// Create a copy of CoopHistoryInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoopHistoryInfoCopyWith<_CoopHistoryInfo> get copyWith => __$CoopHistoryInfoCopyWithImpl<_CoopHistoryInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoopHistoryInfo&&(identical(other.roomCode, roomCode) || other.roomCode == roomCode)&&(identical(other.syncState, syncState) || other.syncState == syncState)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.deleteAt, deleteAt) || other.deleteAt == deleteAt));
}


@override
int get hashCode => Object.hash(runtimeType,roomCode,syncState,isHost,const DeepCollectionEquality().hash(_members),expiresAt,deleteAt);

@override
String toString() {
  return 'CoopHistoryInfo(roomCode: $roomCode, syncState: $syncState, isHost: $isHost, members: $members, expiresAt: $expiresAt, deleteAt: $deleteAt)';
}


}

/// @nodoc
abstract mixin class _$CoopHistoryInfoCopyWith<$Res> implements $CoopHistoryInfoCopyWith<$Res> {
  factory _$CoopHistoryInfoCopyWith(_CoopHistoryInfo value, $Res Function(_CoopHistoryInfo) _then) = __$CoopHistoryInfoCopyWithImpl;
@override @useResult
$Res call({
 String roomCode, CoopSyncState syncState, bool isHost, List<CoopHistoryMember> members, DateTime expiresAt, DateTime deleteAt
});




}
/// @nodoc
class __$CoopHistoryInfoCopyWithImpl<$Res>
    implements _$CoopHistoryInfoCopyWith<$Res> {
  __$CoopHistoryInfoCopyWithImpl(this._self, this._then);

  final _CoopHistoryInfo _self;
  final $Res Function(_CoopHistoryInfo) _then;

/// Create a copy of CoopHistoryInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roomCode = null,Object? syncState = null,Object? isHost = null,Object? members = null,Object? expiresAt = null,Object? deleteAt = null,}) {
  return _then(_CoopHistoryInfo(
roomCode: null == roomCode ? _self.roomCode : roomCode // ignore: cast_nullable_to_non_nullable
as String,syncState: null == syncState ? _self.syncState : syncState // ignore: cast_nullable_to_non_nullable
as CoopSyncState,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<CoopHistoryMember>,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,deleteAt: null == deleteAt ? _self.deleteAt : deleteAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
