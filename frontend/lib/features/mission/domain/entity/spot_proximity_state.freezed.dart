// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spot_proximity_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpotProximityState {

/// 監視対象のスポットインデックス
 int get spotIndex;/// 監視ステータス
 SpotProximityStatus get status;/// これまでに記録した最短距離（メートル）
 double? get minDistanceMeters;/// 直近の距離サンプル（移動平均計算用、最大5件）
 List<double> get recentDistances;/// 離脱が開始された時刻
 DateTime? get departedAt;
/// Create a copy of SpotProximityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotProximityStateCopyWith<SpotProximityState> get copyWith => _$SpotProximityStateCopyWithImpl<SpotProximityState>(this as SpotProximityState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpotProximityState&&(identical(other.spotIndex, spotIndex) || other.spotIndex == spotIndex)&&(identical(other.status, status) || other.status == status)&&(identical(other.minDistanceMeters, minDistanceMeters) || other.minDistanceMeters == minDistanceMeters)&&const DeepCollectionEquality().equals(other.recentDistances, recentDistances)&&(identical(other.departedAt, departedAt) || other.departedAt == departedAt));
}


@override
int get hashCode => Object.hash(runtimeType,spotIndex,status,minDistanceMeters,const DeepCollectionEquality().hash(recentDistances),departedAt);

@override
String toString() {
  return 'SpotProximityState(spotIndex: $spotIndex, status: $status, minDistanceMeters: $minDistanceMeters, recentDistances: $recentDistances, departedAt: $departedAt)';
}


}

/// @nodoc
abstract mixin class $SpotProximityStateCopyWith<$Res>  {
  factory $SpotProximityStateCopyWith(SpotProximityState value, $Res Function(SpotProximityState) _then) = _$SpotProximityStateCopyWithImpl;
@useResult
$Res call({
 int spotIndex, SpotProximityStatus status, double? minDistanceMeters, List<double> recentDistances, DateTime? departedAt
});




}
/// @nodoc
class _$SpotProximityStateCopyWithImpl<$Res>
    implements $SpotProximityStateCopyWith<$Res> {
  _$SpotProximityStateCopyWithImpl(this._self, this._then);

  final SpotProximityState _self;
  final $Res Function(SpotProximityState) _then;

/// Create a copy of SpotProximityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? spotIndex = null,Object? status = null,Object? minDistanceMeters = freezed,Object? recentDistances = null,Object? departedAt = freezed,}) {
  return _then(_self.copyWith(
spotIndex: null == spotIndex ? _self.spotIndex : spotIndex // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SpotProximityStatus,minDistanceMeters: freezed == minDistanceMeters ? _self.minDistanceMeters : minDistanceMeters // ignore: cast_nullable_to_non_nullable
as double?,recentDistances: null == recentDistances ? _self.recentDistances : recentDistances // ignore: cast_nullable_to_non_nullable
as List<double>,departedAt: freezed == departedAt ? _self.departedAt : departedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SpotProximityState].
extension SpotProximityStatePatterns on SpotProximityState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpotProximityState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpotProximityState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpotProximityState value)  $default,){
final _that = this;
switch (_that) {
case _SpotProximityState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpotProximityState value)?  $default,){
final _that = this;
switch (_that) {
case _SpotProximityState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int spotIndex,  SpotProximityStatus status,  double? minDistanceMeters,  List<double> recentDistances,  DateTime? departedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpotProximityState() when $default != null:
return $default(_that.spotIndex,_that.status,_that.minDistanceMeters,_that.recentDistances,_that.departedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int spotIndex,  SpotProximityStatus status,  double? minDistanceMeters,  List<double> recentDistances,  DateTime? departedAt)  $default,) {final _that = this;
switch (_that) {
case _SpotProximityState():
return $default(_that.spotIndex,_that.status,_that.minDistanceMeters,_that.recentDistances,_that.departedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int spotIndex,  SpotProximityStatus status,  double? minDistanceMeters,  List<double> recentDistances,  DateTime? departedAt)?  $default,) {final _that = this;
switch (_that) {
case _SpotProximityState() when $default != null:
return $default(_that.spotIndex,_that.status,_that.minDistanceMeters,_that.recentDistances,_that.departedAt);case _:
  return null;

}
}

}

/// @nodoc


class _SpotProximityState implements SpotProximityState {
  const _SpotProximityState({required this.spotIndex, required this.status, this.minDistanceMeters, final  List<double> recentDistances = const [], this.departedAt}): _recentDistances = recentDistances;
  

/// 監視対象のスポットインデックス
@override final  int spotIndex;
/// 監視ステータス
@override final  SpotProximityStatus status;
/// これまでに記録した最短距離（メートル）
@override final  double? minDistanceMeters;
/// 直近の距離サンプル（移動平均計算用、最大5件）
 final  List<double> _recentDistances;
/// 直近の距離サンプル（移動平均計算用、最大5件）
@override@JsonKey() List<double> get recentDistances {
  if (_recentDistances is EqualUnmodifiableListView) return _recentDistances;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentDistances);
}

/// 離脱が開始された時刻
@override final  DateTime? departedAt;

/// Create a copy of SpotProximityState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotProximityStateCopyWith<_SpotProximityState> get copyWith => __$SpotProximityStateCopyWithImpl<_SpotProximityState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpotProximityState&&(identical(other.spotIndex, spotIndex) || other.spotIndex == spotIndex)&&(identical(other.status, status) || other.status == status)&&(identical(other.minDistanceMeters, minDistanceMeters) || other.minDistanceMeters == minDistanceMeters)&&const DeepCollectionEquality().equals(other._recentDistances, _recentDistances)&&(identical(other.departedAt, departedAt) || other.departedAt == departedAt));
}


@override
int get hashCode => Object.hash(runtimeType,spotIndex,status,minDistanceMeters,const DeepCollectionEquality().hash(_recentDistances),departedAt);

@override
String toString() {
  return 'SpotProximityState(spotIndex: $spotIndex, status: $status, minDistanceMeters: $minDistanceMeters, recentDistances: $recentDistances, departedAt: $departedAt)';
}


}

/// @nodoc
abstract mixin class _$SpotProximityStateCopyWith<$Res> implements $SpotProximityStateCopyWith<$Res> {
  factory _$SpotProximityStateCopyWith(_SpotProximityState value, $Res Function(_SpotProximityState) _then) = __$SpotProximityStateCopyWithImpl;
@override @useResult
$Res call({
 int spotIndex, SpotProximityStatus status, double? minDistanceMeters, List<double> recentDistances, DateTime? departedAt
});




}
/// @nodoc
class __$SpotProximityStateCopyWithImpl<$Res>
    implements _$SpotProximityStateCopyWith<$Res> {
  __$SpotProximityStateCopyWithImpl(this._self, this._then);

  final _SpotProximityState _self;
  final $Res Function(_SpotProximityState) _then;

/// Create a copy of SpotProximityState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? spotIndex = null,Object? status = null,Object? minDistanceMeters = freezed,Object? recentDistances = null,Object? departedAt = freezed,}) {
  return _then(_SpotProximityState(
spotIndex: null == spotIndex ? _self.spotIndex : spotIndex // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SpotProximityStatus,minDistanceMeters: freezed == minDistanceMeters ? _self.minDistanceMeters : minDistanceMeters // ignore: cast_nullable_to_non_nullable
as double?,recentDistances: null == recentDistances ? _self._recentDistances : recentDistances // ignore: cast_nullable_to_non_nullable
as List<double>,departedAt: freezed == departedAt ? _self.departedAt : departedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
