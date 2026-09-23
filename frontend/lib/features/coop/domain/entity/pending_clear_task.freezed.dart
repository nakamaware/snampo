// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pending_clear_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PendingClearTask {

@RoomCodeConverter() RoomCode get roomCode;@SpotIdConverter() SpotId get spotId;/// 発見時点の自分のニックネーム (クリアを作り直すときに使う)
 String get nickname;/// 端末に保存したサムネのパス
 String get localThumbPath;/// 遊べる期限。再送するのはここまで
 DateTime get expiresAt;/// クリアを作成済みか (true ならサムネの再送だけが残っている)
 bool get clearCreated;
/// Create a copy of PendingClearTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingClearTaskCopyWith<PendingClearTask> get copyWith => _$PendingClearTaskCopyWithImpl<PendingClearTask>(this as PendingClearTask, _$identity);

  /// Serializes this PendingClearTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingClearTask&&(identical(other.roomCode, roomCode) || other.roomCode == roomCode)&&(identical(other.spotId, spotId) || other.spotId == spotId)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.localThumbPath, localThumbPath) || other.localThumbPath == localThumbPath)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.clearCreated, clearCreated) || other.clearCreated == clearCreated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roomCode,spotId,nickname,localThumbPath,expiresAt,clearCreated);

@override
String toString() {
  return 'PendingClearTask(roomCode: $roomCode, spotId: $spotId, nickname: $nickname, localThumbPath: $localThumbPath, expiresAt: $expiresAt, clearCreated: $clearCreated)';
}


}

/// @nodoc
abstract mixin class $PendingClearTaskCopyWith<$Res>  {
  factory $PendingClearTaskCopyWith(PendingClearTask value, $Res Function(PendingClearTask) _then) = _$PendingClearTaskCopyWithImpl;
@useResult
$Res call({
@RoomCodeConverter() RoomCode roomCode,@SpotIdConverter() SpotId spotId, String nickname, String localThumbPath, DateTime expiresAt, bool clearCreated
});




}
/// @nodoc
class _$PendingClearTaskCopyWithImpl<$Res>
    implements $PendingClearTaskCopyWith<$Res> {
  _$PendingClearTaskCopyWithImpl(this._self, this._then);

  final PendingClearTask _self;
  final $Res Function(PendingClearTask) _then;

/// Create a copy of PendingClearTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roomCode = null,Object? spotId = null,Object? nickname = null,Object? localThumbPath = null,Object? expiresAt = null,Object? clearCreated = null,}) {
  return _then(_self.copyWith(
roomCode: null == roomCode ? _self.roomCode : roomCode // ignore: cast_nullable_to_non_nullable
as RoomCode,spotId: null == spotId ? _self.spotId : spotId // ignore: cast_nullable_to_non_nullable
as SpotId,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,localThumbPath: null == localThumbPath ? _self.localThumbPath : localThumbPath // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,clearCreated: null == clearCreated ? _self.clearCreated : clearCreated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingClearTask].
extension PendingClearTaskPatterns on PendingClearTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingClearTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingClearTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingClearTask value)  $default,){
final _that = this;
switch (_that) {
case _PendingClearTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingClearTask value)?  $default,){
final _that = this;
switch (_that) {
case _PendingClearTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@RoomCodeConverter()  RoomCode roomCode, @SpotIdConverter()  SpotId spotId,  String nickname,  String localThumbPath,  DateTime expiresAt,  bool clearCreated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingClearTask() when $default != null:
return $default(_that.roomCode,_that.spotId,_that.nickname,_that.localThumbPath,_that.expiresAt,_that.clearCreated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@RoomCodeConverter()  RoomCode roomCode, @SpotIdConverter()  SpotId spotId,  String nickname,  String localThumbPath,  DateTime expiresAt,  bool clearCreated)  $default,) {final _that = this;
switch (_that) {
case _PendingClearTask():
return $default(_that.roomCode,_that.spotId,_that.nickname,_that.localThumbPath,_that.expiresAt,_that.clearCreated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@RoomCodeConverter()  RoomCode roomCode, @SpotIdConverter()  SpotId spotId,  String nickname,  String localThumbPath,  DateTime expiresAt,  bool clearCreated)?  $default,) {final _that = this;
switch (_that) {
case _PendingClearTask() when $default != null:
return $default(_that.roomCode,_that.spotId,_that.nickname,_that.localThumbPath,_that.expiresAt,_that.clearCreated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingClearTask implements PendingClearTask {
  const _PendingClearTask({@RoomCodeConverter() required this.roomCode, @SpotIdConverter() required this.spotId, required this.nickname, required this.localThumbPath, required this.expiresAt, this.clearCreated = false});
  factory _PendingClearTask.fromJson(Map<String, dynamic> json) => _$PendingClearTaskFromJson(json);

@override@RoomCodeConverter() final  RoomCode roomCode;
@override@SpotIdConverter() final  SpotId spotId;
/// 発見時点の自分のニックネーム (クリアを作り直すときに使う)
@override final  String nickname;
/// 端末に保存したサムネのパス
@override final  String localThumbPath;
/// 遊べる期限。再送するのはここまで
@override final  DateTime expiresAt;
/// クリアを作成済みか (true ならサムネの再送だけが残っている)
@override@JsonKey() final  bool clearCreated;

/// Create a copy of PendingClearTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingClearTaskCopyWith<_PendingClearTask> get copyWith => __$PendingClearTaskCopyWithImpl<_PendingClearTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingClearTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingClearTask&&(identical(other.roomCode, roomCode) || other.roomCode == roomCode)&&(identical(other.spotId, spotId) || other.spotId == spotId)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.localThumbPath, localThumbPath) || other.localThumbPath == localThumbPath)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.clearCreated, clearCreated) || other.clearCreated == clearCreated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roomCode,spotId,nickname,localThumbPath,expiresAt,clearCreated);

@override
String toString() {
  return 'PendingClearTask(roomCode: $roomCode, spotId: $spotId, nickname: $nickname, localThumbPath: $localThumbPath, expiresAt: $expiresAt, clearCreated: $clearCreated)';
}


}

/// @nodoc
abstract mixin class _$PendingClearTaskCopyWith<$Res> implements $PendingClearTaskCopyWith<$Res> {
  factory _$PendingClearTaskCopyWith(_PendingClearTask value, $Res Function(_PendingClearTask) _then) = __$PendingClearTaskCopyWithImpl;
@override @useResult
$Res call({
@RoomCodeConverter() RoomCode roomCode,@SpotIdConverter() SpotId spotId, String nickname, String localThumbPath, DateTime expiresAt, bool clearCreated
});




}
/// @nodoc
class __$PendingClearTaskCopyWithImpl<$Res>
    implements _$PendingClearTaskCopyWith<$Res> {
  __$PendingClearTaskCopyWithImpl(this._self, this._then);

  final _PendingClearTask _self;
  final $Res Function(_PendingClearTask) _then;

/// Create a copy of PendingClearTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roomCode = null,Object? spotId = null,Object? nickname = null,Object? localThumbPath = null,Object? expiresAt = null,Object? clearCreated = null,}) {
  return _then(_PendingClearTask(
roomCode: null == roomCode ? _self.roomCode : roomCode // ignore: cast_nullable_to_non_nullable
as RoomCode,spotId: null == spotId ? _self.spotId : spotId // ignore: cast_nullable_to_non_nullable
as SpotId,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,localThumbPath: null == localThumbPath ? _self.localThumbPath : localThumbPath // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,clearCreated: null == clearCreated ? _self.clearCreated : clearCreated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$PendingClearQueue {

@JsonKey(toJson: _tasksToJson) List<PendingClearTask> get tasks;
/// Create a copy of PendingClearQueue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingClearQueueCopyWith<PendingClearQueue> get copyWith => _$PendingClearQueueCopyWithImpl<PendingClearQueue>(this as PendingClearQueue, _$identity);

  /// Serializes this PendingClearQueue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingClearQueue&&const DeepCollectionEquality().equals(other.tasks, tasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tasks));

@override
String toString() {
  return 'PendingClearQueue(tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class $PendingClearQueueCopyWith<$Res>  {
  factory $PendingClearQueueCopyWith(PendingClearQueue value, $Res Function(PendingClearQueue) _then) = _$PendingClearQueueCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _tasksToJson) List<PendingClearTask> tasks
});




}
/// @nodoc
class _$PendingClearQueueCopyWithImpl<$Res>
    implements $PendingClearQueueCopyWith<$Res> {
  _$PendingClearQueueCopyWithImpl(this._self, this._then);

  final PendingClearQueue _self;
  final $Res Function(PendingClearQueue) _then;

/// Create a copy of PendingClearQueue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tasks = null,}) {
  return _then(_self.copyWith(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<PendingClearTask>,
  ));
}

}


/// Adds pattern-matching-related methods to [PendingClearQueue].
extension PendingClearQueuePatterns on PendingClearQueue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PendingClearQueue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PendingClearQueue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PendingClearQueue value)  $default,){
final _that = this;
switch (_that) {
case _PendingClearQueue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PendingClearQueue value)?  $default,){
final _that = this;
switch (_that) {
case _PendingClearQueue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(toJson: _tasksToJson)  List<PendingClearTask> tasks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PendingClearQueue() when $default != null:
return $default(_that.tasks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(toJson: _tasksToJson)  List<PendingClearTask> tasks)  $default,) {final _that = this;
switch (_that) {
case _PendingClearQueue():
return $default(_that.tasks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(toJson: _tasksToJson)  List<PendingClearTask> tasks)?  $default,) {final _that = this;
switch (_that) {
case _PendingClearQueue() when $default != null:
return $default(_that.tasks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PendingClearQueue extends PendingClearQueue {
  const _PendingClearQueue({@JsonKey(toJson: _tasksToJson) final  List<PendingClearTask> tasks = const []}): _tasks = tasks,super._();
  factory _PendingClearQueue.fromJson(Map<String, dynamic> json) => _$PendingClearQueueFromJson(json);

 final  List<PendingClearTask> _tasks;
@override@JsonKey(toJson: _tasksToJson) List<PendingClearTask> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}


/// Create a copy of PendingClearQueue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PendingClearQueueCopyWith<_PendingClearQueue> get copyWith => __$PendingClearQueueCopyWithImpl<_PendingClearQueue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingClearQueueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PendingClearQueue&&const DeepCollectionEquality().equals(other._tasks, _tasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tasks));

@override
String toString() {
  return 'PendingClearQueue(tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class _$PendingClearQueueCopyWith<$Res> implements $PendingClearQueueCopyWith<$Res> {
  factory _$PendingClearQueueCopyWith(_PendingClearQueue value, $Res Function(_PendingClearQueue) _then) = __$PendingClearQueueCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(toJson: _tasksToJson) List<PendingClearTask> tasks
});




}
/// @nodoc
class __$PendingClearQueueCopyWithImpl<$Res>
    implements _$PendingClearQueueCopyWith<$Res> {
  __$PendingClearQueueCopyWithImpl(this._self, this._then);

  final _PendingClearQueue _self;
  final $Res Function(_PendingClearQueue) _then;

/// Create a copy of PendingClearQueue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tasks = null,}) {
  return _then(_PendingClearQueue(
tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<PendingClearTask>,
  ));
}


}

// dart format on
