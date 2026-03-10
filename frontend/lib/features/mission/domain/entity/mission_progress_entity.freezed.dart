// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_progress_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckpointProgress {

@NullableCoordinateConverter() Coordinate? get guessPosition; String? get userPhotoPath; DateTime? get achievedAt;
/// Create a copy of CheckpointProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckpointProgressCopyWith<CheckpointProgress> get copyWith => _$CheckpointProgressCopyWithImpl<CheckpointProgress>(this as CheckpointProgress, _$identity);

  /// Serializes this CheckpointProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckpointProgress&&(identical(other.guessPosition, guessPosition) || other.guessPosition == guessPosition)&&(identical(other.userPhotoPath, userPhotoPath) || other.userPhotoPath == userPhotoPath)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guessPosition,userPhotoPath,achievedAt);

@override
String toString() {
  return 'CheckpointProgress(guessPosition: $guessPosition, userPhotoPath: $userPhotoPath, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class $CheckpointProgressCopyWith<$Res>  {
  factory $CheckpointProgressCopyWith(CheckpointProgress value, $Res Function(CheckpointProgress) _then) = _$CheckpointProgressCopyWithImpl;
@useResult
$Res call({
@NullableCoordinateConverter() Coordinate? guessPosition, String? userPhotoPath, DateTime? achievedAt
});


$CoordinateCopyWith<$Res>? get guessPosition;

}
/// @nodoc
class _$CheckpointProgressCopyWithImpl<$Res>
    implements $CheckpointProgressCopyWith<$Res> {
  _$CheckpointProgressCopyWithImpl(this._self, this._then);

  final CheckpointProgress _self;
  final $Res Function(CheckpointProgress) _then;

/// Create a copy of CheckpointProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? guessPosition = freezed,Object? userPhotoPath = freezed,Object? achievedAt = freezed,}) {
  return _then(_self.copyWith(
guessPosition: freezed == guessPosition ? _self.guessPosition : guessPosition // ignore: cast_nullable_to_non_nullable
as Coordinate?,userPhotoPath: freezed == userPhotoPath ? _self.userPhotoPath : userPhotoPath // ignore: cast_nullable_to_non_nullable
as String?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of CheckpointProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoordinateCopyWith<$Res>? get guessPosition {
    if (_self.guessPosition == null) {
    return null;
  }

  return $CoordinateCopyWith<$Res>(_self.guessPosition!, (value) {
    return _then(_self.copyWith(guessPosition: value));
  });
}
}


/// Adds pattern-matching-related methods to [CheckpointProgress].
extension CheckpointProgressPatterns on CheckpointProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckpointProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckpointProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckpointProgress value)  $default,){
final _that = this;
switch (_that) {
case _CheckpointProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckpointProgress value)?  $default,){
final _that = this;
switch (_that) {
case _CheckpointProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@NullableCoordinateConverter()  Coordinate? guessPosition,  String? userPhotoPath,  DateTime? achievedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckpointProgress() when $default != null:
return $default(_that.guessPosition,_that.userPhotoPath,_that.achievedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@NullableCoordinateConverter()  Coordinate? guessPosition,  String? userPhotoPath,  DateTime? achievedAt)  $default,) {final _that = this;
switch (_that) {
case _CheckpointProgress():
return $default(_that.guessPosition,_that.userPhotoPath,_that.achievedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@NullableCoordinateConverter()  Coordinate? guessPosition,  String? userPhotoPath,  DateTime? achievedAt)?  $default,) {final _that = this;
switch (_that) {
case _CheckpointProgress() when $default != null:
return $default(_that.guessPosition,_that.userPhotoPath,_that.achievedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckpointProgress implements CheckpointProgress {
  const _CheckpointProgress({@NullableCoordinateConverter() this.guessPosition, this.userPhotoPath, this.achievedAt});
  factory _CheckpointProgress.fromJson(Map<String, dynamic> json) => _$CheckpointProgressFromJson(json);

@override@NullableCoordinateConverter() final  Coordinate? guessPosition;
@override final  String? userPhotoPath;
@override final  DateTime? achievedAt;

/// Create a copy of CheckpointProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckpointProgressCopyWith<_CheckpointProgress> get copyWith => __$CheckpointProgressCopyWithImpl<_CheckpointProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckpointProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckpointProgress&&(identical(other.guessPosition, guessPosition) || other.guessPosition == guessPosition)&&(identical(other.userPhotoPath, userPhotoPath) || other.userPhotoPath == userPhotoPath)&&(identical(other.achievedAt, achievedAt) || other.achievedAt == achievedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,guessPosition,userPhotoPath,achievedAt);

@override
String toString() {
  return 'CheckpointProgress(guessPosition: $guessPosition, userPhotoPath: $userPhotoPath, achievedAt: $achievedAt)';
}


}

/// @nodoc
abstract mixin class _$CheckpointProgressCopyWith<$Res> implements $CheckpointProgressCopyWith<$Res> {
  factory _$CheckpointProgressCopyWith(_CheckpointProgress value, $Res Function(_CheckpointProgress) _then) = __$CheckpointProgressCopyWithImpl;
@override @useResult
$Res call({
@NullableCoordinateConverter() Coordinate? guessPosition, String? userPhotoPath, DateTime? achievedAt
});


@override $CoordinateCopyWith<$Res>? get guessPosition;

}
/// @nodoc
class __$CheckpointProgressCopyWithImpl<$Res>
    implements _$CheckpointProgressCopyWith<$Res> {
  __$CheckpointProgressCopyWithImpl(this._self, this._then);

  final _CheckpointProgress _self;
  final $Res Function(_CheckpointProgress) _then;

/// Create a copy of CheckpointProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? guessPosition = freezed,Object? userPhotoPath = freezed,Object? achievedAt = freezed,}) {
  return _then(_CheckpointProgress(
guessPosition: freezed == guessPosition ? _self.guessPosition : guessPosition // ignore: cast_nullable_to_non_nullable
as Coordinate?,userPhotoPath: freezed == userPhotoPath ? _self.userPhotoPath : userPhotoPath // ignore: cast_nullable_to_non_nullable
as String?,achievedAt: freezed == achievedAt ? _self.achievedAt : achievedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of CheckpointProgress
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoordinateCopyWith<$Res>? get guessPosition {
    if (_self.guessPosition == null) {
    return null;
  }

  return $CoordinateCopyWith<$Res>(_self.guessPosition!, (value) {
    return _then(_self.copyWith(guessPosition: value));
  });
}
}


/// @nodoc
mixin _$MissionProgressEntity {

 DateTime get startedAt; List<CheckpointProgress?> get checkpoints;
/// Create a copy of MissionProgressEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionProgressEntityCopyWith<MissionProgressEntity> get copyWith => _$MissionProgressEntityCopyWithImpl<MissionProgressEntity>(this as MissionProgressEntity, _$identity);

  /// Serializes this MissionProgressEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionProgressEntity&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other.checkpoints, checkpoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startedAt,const DeepCollectionEquality().hash(checkpoints));

@override
String toString() {
  return 'MissionProgressEntity(startedAt: $startedAt, checkpoints: $checkpoints)';
}


}

/// @nodoc
abstract mixin class $MissionProgressEntityCopyWith<$Res>  {
  factory $MissionProgressEntityCopyWith(MissionProgressEntity value, $Res Function(MissionProgressEntity) _then) = _$MissionProgressEntityCopyWithImpl;
@useResult
$Res call({
 DateTime startedAt, List<CheckpointProgress?> checkpoints
});




}
/// @nodoc
class _$MissionProgressEntityCopyWithImpl<$Res>
    implements $MissionProgressEntityCopyWith<$Res> {
  _$MissionProgressEntityCopyWithImpl(this._self, this._then);

  final MissionProgressEntity _self;
  final $Res Function(MissionProgressEntity) _then;

/// Create a copy of MissionProgressEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startedAt = null,Object? checkpoints = null,}) {
  return _then(_self.copyWith(
startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,checkpoints: null == checkpoints ? _self.checkpoints : checkpoints // ignore: cast_nullable_to_non_nullable
as List<CheckpointProgress?>,
  ));
}

}


/// Adds pattern-matching-related methods to [MissionProgressEntity].
extension MissionProgressEntityPatterns on MissionProgressEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MissionProgressEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MissionProgressEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MissionProgressEntity value)  $default,){
final _that = this;
switch (_that) {
case _MissionProgressEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MissionProgressEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MissionProgressEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime startedAt,  List<CheckpointProgress?> checkpoints)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MissionProgressEntity() when $default != null:
return $default(_that.startedAt,_that.checkpoints);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime startedAt,  List<CheckpointProgress?> checkpoints)  $default,) {final _that = this;
switch (_that) {
case _MissionProgressEntity():
return $default(_that.startedAt,_that.checkpoints);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime startedAt,  List<CheckpointProgress?> checkpoints)?  $default,) {final _that = this;
switch (_that) {
case _MissionProgressEntity() when $default != null:
return $default(_that.startedAt,_that.checkpoints);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MissionProgressEntity extends MissionProgressEntity {
  const _MissionProgressEntity({required this.startedAt, final  List<CheckpointProgress?> checkpoints = const []}): _checkpoints = checkpoints,super._();
  factory _MissionProgressEntity.fromJson(Map<String, dynamic> json) => _$MissionProgressEntityFromJson(json);

@override final  DateTime startedAt;
 final  List<CheckpointProgress?> _checkpoints;
@override@JsonKey() List<CheckpointProgress?> get checkpoints {
  if (_checkpoints is EqualUnmodifiableListView) return _checkpoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_checkpoints);
}


/// Create a copy of MissionProgressEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MissionProgressEntityCopyWith<_MissionProgressEntity> get copyWith => __$MissionProgressEntityCopyWithImpl<_MissionProgressEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MissionProgressEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MissionProgressEntity&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&const DeepCollectionEquality().equals(other._checkpoints, _checkpoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startedAt,const DeepCollectionEquality().hash(_checkpoints));

@override
String toString() {
  return 'MissionProgressEntity(startedAt: $startedAt, checkpoints: $checkpoints)';
}


}

/// @nodoc
abstract mixin class _$MissionProgressEntityCopyWith<$Res> implements $MissionProgressEntityCopyWith<$Res> {
  factory _$MissionProgressEntityCopyWith(_MissionProgressEntity value, $Res Function(_MissionProgressEntity) _then) = __$MissionProgressEntityCopyWithImpl;
@override @useResult
$Res call({
 DateTime startedAt, List<CheckpointProgress?> checkpoints
});




}
/// @nodoc
class __$MissionProgressEntityCopyWithImpl<$Res>
    implements _$MissionProgressEntityCopyWith<$Res> {
  __$MissionProgressEntityCopyWithImpl(this._self, this._then);

  final _MissionProgressEntity _self;
  final $Res Function(_MissionProgressEntity) _then;

/// Create a copy of MissionProgressEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startedAt = null,Object? checkpoints = null,}) {
  return _then(_MissionProgressEntity(
startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,checkpoints: null == checkpoints ? _self._checkpoints : checkpoints // ignore: cast_nullable_to_non_nullable
as List<CheckpointProgress?>,
  ));
}


}

// dart format on
