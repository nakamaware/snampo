// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_history_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MissionHistoryEntity {

 String get id; DateTime get completedAt; MissionEntity get mission; MissionProgressEntity get progress;
/// Create a copy of MissionHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionHistoryEntityCopyWith<MissionHistoryEntity> get copyWith => _$MissionHistoryEntityCopyWithImpl<MissionHistoryEntity>(this as MissionHistoryEntity, _$identity);

  /// Serializes this MissionHistoryEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionHistoryEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.mission, mission) || other.mission == mission)&&(identical(other.progress, progress) || other.progress == progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,completedAt,mission,progress);

@override
String toString() {
  return 'MissionHistoryEntity(id: $id, completedAt: $completedAt, mission: $mission, progress: $progress)';
}


}

/// @nodoc
abstract mixin class $MissionHistoryEntityCopyWith<$Res>  {
  factory $MissionHistoryEntityCopyWith(MissionHistoryEntity value, $Res Function(MissionHistoryEntity) _then) = _$MissionHistoryEntityCopyWithImpl;
@useResult
$Res call({
 String id, DateTime completedAt, MissionEntity mission, MissionProgressEntity progress
});


$MissionEntityCopyWith<$Res> get mission;$MissionProgressEntityCopyWith<$Res> get progress;

}
/// @nodoc
class _$MissionHistoryEntityCopyWithImpl<$Res>
    implements $MissionHistoryEntityCopyWith<$Res> {
  _$MissionHistoryEntityCopyWithImpl(this._self, this._then);

  final MissionHistoryEntity _self;
  final $Res Function(MissionHistoryEntity) _then;

/// Create a copy of MissionHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? completedAt = null,Object? mission = null,Object? progress = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,mission: null == mission ? _self.mission : mission // ignore: cast_nullable_to_non_nullable
as MissionEntity,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as MissionProgressEntity,
  ));
}
/// Create a copy of MissionHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MissionEntityCopyWith<$Res> get mission {

  return $MissionEntityCopyWith<$Res>(_self.mission, (value) {
    return _then(_self.copyWith(mission: value));
  });
}/// Create a copy of MissionHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MissionProgressEntityCopyWith<$Res> get progress {

  return $MissionProgressEntityCopyWith<$Res>(_self.progress, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}


/// Adds pattern-matching-related methods to [MissionHistoryEntity].
extension MissionHistoryEntityPatterns on MissionHistoryEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MissionHistoryEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MissionHistoryEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MissionHistoryEntity value)  $default,){
final _that = this;
switch (_that) {
case _MissionHistoryEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MissionHistoryEntity value)?  $default,){
final _that = this;
switch (_that) {
case _MissionHistoryEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime completedAt,  MissionEntity mission,  MissionProgressEntity progress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MissionHistoryEntity() when $default != null:
return $default(_that.id,_that.completedAt,_that.mission,_that.progress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime completedAt,  MissionEntity mission,  MissionProgressEntity progress)  $default,) {final _that = this;
switch (_that) {
case _MissionHistoryEntity():
return $default(_that.id,_that.completedAt,_that.mission,_that.progress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime completedAt,  MissionEntity mission,  MissionProgressEntity progress)?  $default,) {final _that = this;
switch (_that) {
case _MissionHistoryEntity() when $default != null:
return $default(_that.id,_that.completedAt,_that.mission,_that.progress);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _MissionHistoryEntity implements MissionHistoryEntity {
  const _MissionHistoryEntity({required this.id, required this.completedAt, required this.mission, required this.progress});
  factory _MissionHistoryEntity.fromJson(Map<String, dynamic> json) => _$MissionHistoryEntityFromJson(json);

@override final  String id;
@override final  DateTime completedAt;
@override final  MissionEntity mission;
@override final  MissionProgressEntity progress;

/// Create a copy of MissionHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MissionHistoryEntityCopyWith<_MissionHistoryEntity> get copyWith => __$MissionHistoryEntityCopyWithImpl<_MissionHistoryEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MissionHistoryEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MissionHistoryEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.mission, mission) || other.mission == mission)&&(identical(other.progress, progress) || other.progress == progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,completedAt,mission,progress);

@override
String toString() {
  return 'MissionHistoryEntity(id: $id, completedAt: $completedAt, mission: $mission, progress: $progress)';
}


}

/// @nodoc
abstract mixin class _$MissionHistoryEntityCopyWith<$Res> implements $MissionHistoryEntityCopyWith<$Res> {
  factory _$MissionHistoryEntityCopyWith(_MissionHistoryEntity value, $Res Function(_MissionHistoryEntity) _then) = __$MissionHistoryEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime completedAt, MissionEntity mission, MissionProgressEntity progress
});


@override $MissionEntityCopyWith<$Res> get mission;@override $MissionProgressEntityCopyWith<$Res> get progress;

}
/// @nodoc
class __$MissionHistoryEntityCopyWithImpl<$Res>
    implements _$MissionHistoryEntityCopyWith<$Res> {
  __$MissionHistoryEntityCopyWithImpl(this._self, this._then);

  final _MissionHistoryEntity _self;
  final $Res Function(_MissionHistoryEntity) _then;

/// Create a copy of MissionHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? completedAt = null,Object? mission = null,Object? progress = null,}) {
  return _then(_MissionHistoryEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,mission: null == mission ? _self.mission : mission // ignore: cast_nullable_to_non_nullable
as MissionEntity,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as MissionProgressEntity,
  ));
}

/// Create a copy of MissionHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MissionEntityCopyWith<$Res> get mission {

  return $MissionEntityCopyWith<$Res>(_self.mission, (value) {
    return _then(_self.copyWith(mission: value));
  });
}/// Create a copy of MissionHistoryEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MissionProgressEntityCopyWith<$Res> get progress {

  return $MissionProgressEntityCopyWith<$Res>(_self.progress, (value) {
    return _then(_self.copyWith(progress: value));
  });
}
}

// dart format on
