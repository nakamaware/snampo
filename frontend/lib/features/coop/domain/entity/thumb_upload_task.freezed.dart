// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'thumb_upload_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ThumbUploadTask {

 String get roomCode; String get spotId;/// 端末に保存したサムネのパス
 String get localPath;/// 遊べる期限。再送するのはここまで
 DateTime get expiresAt;
/// Create a copy of ThumbUploadTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThumbUploadTaskCopyWith<ThumbUploadTask> get copyWith => _$ThumbUploadTaskCopyWithImpl<ThumbUploadTask>(this as ThumbUploadTask, _$identity);

  /// Serializes this ThumbUploadTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThumbUploadTask&&(identical(other.roomCode, roomCode) || other.roomCode == roomCode)&&(identical(other.spotId, spotId) || other.spotId == spotId)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roomCode,spotId,localPath,expiresAt);

@override
String toString() {
  return 'ThumbUploadTask(roomCode: $roomCode, spotId: $spotId, localPath: $localPath, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $ThumbUploadTaskCopyWith<$Res>  {
  factory $ThumbUploadTaskCopyWith(ThumbUploadTask value, $Res Function(ThumbUploadTask) _then) = _$ThumbUploadTaskCopyWithImpl;
@useResult
$Res call({
 String roomCode, String spotId, String localPath, DateTime expiresAt
});




}
/// @nodoc
class _$ThumbUploadTaskCopyWithImpl<$Res>
    implements $ThumbUploadTaskCopyWith<$Res> {
  _$ThumbUploadTaskCopyWithImpl(this._self, this._then);

  final ThumbUploadTask _self;
  final $Res Function(ThumbUploadTask) _then;

/// Create a copy of ThumbUploadTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roomCode = null,Object? spotId = null,Object? localPath = null,Object? expiresAt = null,}) {
  return _then(_self.copyWith(
roomCode: null == roomCode ? _self.roomCode : roomCode // ignore: cast_nullable_to_non_nullable
as String,spotId: null == spotId ? _self.spotId : spotId // ignore: cast_nullable_to_non_nullable
as String,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ThumbUploadTask].
extension ThumbUploadTaskPatterns on ThumbUploadTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThumbUploadTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThumbUploadTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThumbUploadTask value)  $default,){
final _that = this;
switch (_that) {
case _ThumbUploadTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThumbUploadTask value)?  $default,){
final _that = this;
switch (_that) {
case _ThumbUploadTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String roomCode,  String spotId,  String localPath,  DateTime expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThumbUploadTask() when $default != null:
return $default(_that.roomCode,_that.spotId,_that.localPath,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String roomCode,  String spotId,  String localPath,  DateTime expiresAt)  $default,) {final _that = this;
switch (_that) {
case _ThumbUploadTask():
return $default(_that.roomCode,_that.spotId,_that.localPath,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String roomCode,  String spotId,  String localPath,  DateTime expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _ThumbUploadTask() when $default != null:
return $default(_that.roomCode,_that.spotId,_that.localPath,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThumbUploadTask implements ThumbUploadTask {
  const _ThumbUploadTask({required this.roomCode, required this.spotId, required this.localPath, required this.expiresAt});
  factory _ThumbUploadTask.fromJson(Map<String, dynamic> json) => _$ThumbUploadTaskFromJson(json);

@override final  String roomCode;
@override final  String spotId;
/// 端末に保存したサムネのパス
@override final  String localPath;
/// 遊べる期限。再送するのはここまで
@override final  DateTime expiresAt;

/// Create a copy of ThumbUploadTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThumbUploadTaskCopyWith<_ThumbUploadTask> get copyWith => __$ThumbUploadTaskCopyWithImpl<_ThumbUploadTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThumbUploadTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThumbUploadTask&&(identical(other.roomCode, roomCode) || other.roomCode == roomCode)&&(identical(other.spotId, spotId) || other.spotId == spotId)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,roomCode,spotId,localPath,expiresAt);

@override
String toString() {
  return 'ThumbUploadTask(roomCode: $roomCode, spotId: $spotId, localPath: $localPath, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$ThumbUploadTaskCopyWith<$Res> implements $ThumbUploadTaskCopyWith<$Res> {
  factory _$ThumbUploadTaskCopyWith(_ThumbUploadTask value, $Res Function(_ThumbUploadTask) _then) = __$ThumbUploadTaskCopyWithImpl;
@override @useResult
$Res call({
 String roomCode, String spotId, String localPath, DateTime expiresAt
});




}
/// @nodoc
class __$ThumbUploadTaskCopyWithImpl<$Res>
    implements _$ThumbUploadTaskCopyWith<$Res> {
  __$ThumbUploadTaskCopyWithImpl(this._self, this._then);

  final _ThumbUploadTask _self;
  final $Res Function(_ThumbUploadTask) _then;

/// Create a copy of ThumbUploadTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roomCode = null,Object? spotId = null,Object? localPath = null,Object? expiresAt = null,}) {
  return _then(_ThumbUploadTask(
roomCode: null == roomCode ? _self.roomCode : roomCode // ignore: cast_nullable_to_non_nullable
as String,spotId: null == spotId ? _self.spotId : spotId // ignore: cast_nullable_to_non_nullable
as String,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ThumbUploadQueue {

@JsonKey(toJson: _tasksToJson) List<ThumbUploadTask> get tasks;
/// Create a copy of ThumbUploadQueue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThumbUploadQueueCopyWith<ThumbUploadQueue> get copyWith => _$ThumbUploadQueueCopyWithImpl<ThumbUploadQueue>(this as ThumbUploadQueue, _$identity);

  /// Serializes this ThumbUploadQueue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThumbUploadQueue&&const DeepCollectionEquality().equals(other.tasks, tasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(tasks));

@override
String toString() {
  return 'ThumbUploadQueue(tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class $ThumbUploadQueueCopyWith<$Res>  {
  factory $ThumbUploadQueueCopyWith(ThumbUploadQueue value, $Res Function(ThumbUploadQueue) _then) = _$ThumbUploadQueueCopyWithImpl;
@useResult
$Res call({
@JsonKey(toJson: _tasksToJson) List<ThumbUploadTask> tasks
});




}
/// @nodoc
class _$ThumbUploadQueueCopyWithImpl<$Res>
    implements $ThumbUploadQueueCopyWith<$Res> {
  _$ThumbUploadQueueCopyWithImpl(this._self, this._then);

  final ThumbUploadQueue _self;
  final $Res Function(ThumbUploadQueue) _then;

/// Create a copy of ThumbUploadQueue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tasks = null,}) {
  return _then(_self.copyWith(
tasks: null == tasks ? _self.tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<ThumbUploadTask>,
  ));
}

}


/// Adds pattern-matching-related methods to [ThumbUploadQueue].
extension ThumbUploadQueuePatterns on ThumbUploadQueue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThumbUploadQueue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThumbUploadQueue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThumbUploadQueue value)  $default,){
final _that = this;
switch (_that) {
case _ThumbUploadQueue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThumbUploadQueue value)?  $default,){
final _that = this;
switch (_that) {
case _ThumbUploadQueue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(toJson: _tasksToJson)  List<ThumbUploadTask> tasks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThumbUploadQueue() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(toJson: _tasksToJson)  List<ThumbUploadTask> tasks)  $default,) {final _that = this;
switch (_that) {
case _ThumbUploadQueue():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(toJson: _tasksToJson)  List<ThumbUploadTask> tasks)?  $default,) {final _that = this;
switch (_that) {
case _ThumbUploadQueue() when $default != null:
return $default(_that.tasks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThumbUploadQueue extends ThumbUploadQueue {
  const _ThumbUploadQueue({@JsonKey(toJson: _tasksToJson) final  List<ThumbUploadTask> tasks = const []}): _tasks = tasks,super._();
  factory _ThumbUploadQueue.fromJson(Map<String, dynamic> json) => _$ThumbUploadQueueFromJson(json);

 final  List<ThumbUploadTask> _tasks;
@override@JsonKey(toJson: _tasksToJson) List<ThumbUploadTask> get tasks {
  if (_tasks is EqualUnmodifiableListView) return _tasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tasks);
}


/// Create a copy of ThumbUploadQueue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThumbUploadQueueCopyWith<_ThumbUploadQueue> get copyWith => __$ThumbUploadQueueCopyWithImpl<_ThumbUploadQueue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThumbUploadQueueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThumbUploadQueue&&const DeepCollectionEquality().equals(other._tasks, _tasks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_tasks));

@override
String toString() {
  return 'ThumbUploadQueue(tasks: $tasks)';
}


}

/// @nodoc
abstract mixin class _$ThumbUploadQueueCopyWith<$Res> implements $ThumbUploadQueueCopyWith<$Res> {
  factory _$ThumbUploadQueueCopyWith(_ThumbUploadQueue value, $Res Function(_ThumbUploadQueue) _then) = __$ThumbUploadQueueCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(toJson: _tasksToJson) List<ThumbUploadTask> tasks
});




}
/// @nodoc
class __$ThumbUploadQueueCopyWithImpl<$Res>
    implements _$ThumbUploadQueueCopyWith<$Res> {
  __$ThumbUploadQueueCopyWithImpl(this._self, this._then);

  final _ThumbUploadQueue _self;
  final $Res Function(_ThumbUploadQueue) _then;

/// Create a copy of ThumbUploadQueue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tasks = null,}) {
  return _then(_ThumbUploadQueue(
tasks: null == tasks ? _self._tasks : tasks // ignore: cast_nullable_to_non_nullable
as List<ThumbUploadTask>,
  ));
}


}

// dart format on
