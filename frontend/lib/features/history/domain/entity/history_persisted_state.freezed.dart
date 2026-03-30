// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_persisted_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HistoryPersistedState {

 List<MissionHistoryEntity> get records;
/// Create a copy of HistoryPersistedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryPersistedStateCopyWith<HistoryPersistedState> get copyWith => _$HistoryPersistedStateCopyWithImpl<HistoryPersistedState>(this as HistoryPersistedState, _$identity);

  /// Serializes this HistoryPersistedState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryPersistedState&&const DeepCollectionEquality().equals(other.records, records));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(records));

@override
String toString() {
  return 'HistoryPersistedState(records: $records)';
}


}

/// @nodoc
abstract mixin class $HistoryPersistedStateCopyWith<$Res>  {
  factory $HistoryPersistedStateCopyWith(HistoryPersistedState value, $Res Function(HistoryPersistedState) _then) = _$HistoryPersistedStateCopyWithImpl;
@useResult
$Res call({
 List<MissionHistoryEntity> records
});




}
/// @nodoc
class _$HistoryPersistedStateCopyWithImpl<$Res>
    implements $HistoryPersistedStateCopyWith<$Res> {
  _$HistoryPersistedStateCopyWithImpl(this._self, this._then);

  final HistoryPersistedState _self;
  final $Res Function(HistoryPersistedState) _then;

/// Create a copy of HistoryPersistedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? records = null,}) {
  return _then(_self.copyWith(
records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as List<MissionHistoryEntity>,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoryPersistedState].
extension HistoryPersistedStatePatterns on HistoryPersistedState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryPersistedState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryPersistedState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryPersistedState value)  $default,){
final _that = this;
switch (_that) {
case _HistoryPersistedState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryPersistedState value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryPersistedState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MissionHistoryEntity> records)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryPersistedState() when $default != null:
return $default(_that.records);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MissionHistoryEntity> records)  $default,) {final _that = this;
switch (_that) {
case _HistoryPersistedState():
return $default(_that.records);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MissionHistoryEntity> records)?  $default,) {final _that = this;
switch (_that) {
case _HistoryPersistedState() when $default != null:
return $default(_that.records);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _HistoryPersistedState implements HistoryPersistedState {
  const _HistoryPersistedState({final  List<MissionHistoryEntity> records = const <MissionHistoryEntity>[]}): _records = records;
  factory _HistoryPersistedState.fromJson(Map<String, dynamic> json) => _$HistoryPersistedStateFromJson(json);

 final  List<MissionHistoryEntity> _records;
@override@JsonKey() List<MissionHistoryEntity> get records {
  if (_records is EqualUnmodifiableListView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_records);
}


/// Create a copy of HistoryPersistedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryPersistedStateCopyWith<_HistoryPersistedState> get copyWith => __$HistoryPersistedStateCopyWithImpl<_HistoryPersistedState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryPersistedStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryPersistedState&&const DeepCollectionEquality().equals(other._records, _records));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_records));

@override
String toString() {
  return 'HistoryPersistedState(records: $records)';
}


}

/// @nodoc
abstract mixin class _$HistoryPersistedStateCopyWith<$Res> implements $HistoryPersistedStateCopyWith<$Res> {
  factory _$HistoryPersistedStateCopyWith(_HistoryPersistedState value, $Res Function(_HistoryPersistedState) _then) = __$HistoryPersistedStateCopyWithImpl;
@override @useResult
$Res call({
 List<MissionHistoryEntity> records
});




}
/// @nodoc
class __$HistoryPersistedStateCopyWithImpl<$Res>
    implements _$HistoryPersistedStateCopyWith<$Res> {
  __$HistoryPersistedStateCopyWithImpl(this._self, this._then);

  final _HistoryPersistedState _self;
  final $Res Function(_HistoryPersistedState) _then;

/// Create a copy of HistoryPersistedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? records = null,}) {
  return _then(_HistoryPersistedState(
records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as List<MissionHistoryEntity>,
  ));
}


}

// dart format on
