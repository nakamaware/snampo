// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MissionHistory {

 String get id; DateTime get completedAt; DateTime get startedAt; Coordinate get departure; String get overviewPolyline; List<MissionHistorySpot> get spots; MissionSettings get settings;
/// Create a copy of MissionHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionHistoryCopyWith<MissionHistory> get copyWith => _$MissionHistoryCopyWithImpl<MissionHistory>(this as MissionHistory, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.departure, departure) || other.departure == departure)&&(identical(other.overviewPolyline, overviewPolyline) || other.overviewPolyline == overviewPolyline)&&const DeepCollectionEquality().equals(other.spots, spots)&&(identical(other.settings, settings) || other.settings == settings));
}


@override
int get hashCode => Object.hash(runtimeType,id,completedAt,startedAt,departure,overviewPolyline,const DeepCollectionEquality().hash(spots),settings);

@override
String toString() {
  return 'MissionHistory(id: $id, completedAt: $completedAt, startedAt: $startedAt, departure: $departure, overviewPolyline: $overviewPolyline, spots: $spots, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $MissionHistoryCopyWith<$Res>  {
  factory $MissionHistoryCopyWith(MissionHistory value, $Res Function(MissionHistory) _then) = _$MissionHistoryCopyWithImpl;
@useResult
$Res call({
 String id, DateTime completedAt, DateTime startedAt, Coordinate departure, String overviewPolyline, List<MissionHistorySpot> spots, MissionSettings settings
});


$CoordinateCopyWith<$Res> get departure;$MissionSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class _$MissionHistoryCopyWithImpl<$Res>
    implements $MissionHistoryCopyWith<$Res> {
  _$MissionHistoryCopyWithImpl(this._self, this._then);

  final MissionHistory _self;
  final $Res Function(MissionHistory) _then;

/// Create a copy of MissionHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? completedAt = null,Object? startedAt = null,Object? departure = null,Object? overviewPolyline = null,Object? spots = null,Object? settings = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,departure: null == departure ? _self.departure : departure // ignore: cast_nullable_to_non_nullable
as Coordinate,overviewPolyline: null == overviewPolyline ? _self.overviewPolyline : overviewPolyline // ignore: cast_nullable_to_non_nullable
as String,spots: null == spots ? _self.spots : spots // ignore: cast_nullable_to_non_nullable
as List<MissionHistorySpot>,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as MissionSettings,
  ));
}
/// Create a copy of MissionHistory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoordinateCopyWith<$Res> get departure {

  return $CoordinateCopyWith<$Res>(_self.departure, (value) {
    return _then(_self.copyWith(departure: value));
  });
}/// Create a copy of MissionHistory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MissionSettingsCopyWith<$Res> get settings {

  return $MissionSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}


/// Adds pattern-matching-related methods to [MissionHistory].
extension MissionHistoryPatterns on MissionHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MissionHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MissionHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MissionHistory value)  $default,){
final _that = this;
switch (_that) {
case _MissionHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MissionHistory value)?  $default,){
final _that = this;
switch (_that) {
case _MissionHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime completedAt,  DateTime startedAt,  Coordinate departure,  String overviewPolyline,  List<MissionHistorySpot> spots,  MissionSettings settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MissionHistory() when $default != null:
return $default(_that.id,_that.completedAt,_that.startedAt,_that.departure,_that.overviewPolyline,_that.spots,_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime completedAt,  DateTime startedAt,  Coordinate departure,  String overviewPolyline,  List<MissionHistorySpot> spots,  MissionSettings settings)  $default,) {final _that = this;
switch (_that) {
case _MissionHistory():
return $default(_that.id,_that.completedAt,_that.startedAt,_that.departure,_that.overviewPolyline,_that.spots,_that.settings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime completedAt,  DateTime startedAt,  Coordinate departure,  String overviewPolyline,  List<MissionHistorySpot> spots,  MissionSettings settings)?  $default,) {final _that = this;
switch (_that) {
case _MissionHistory() when $default != null:
return $default(_that.id,_that.completedAt,_that.startedAt,_that.departure,_that.overviewPolyline,_that.spots,_that.settings);case _:
  return null;

}
}

}

/// @nodoc


class _MissionHistory implements MissionHistory {
  const _MissionHistory({required this.id, required this.completedAt, required this.startedAt, required this.departure, required this.overviewPolyline, required final  List<MissionHistorySpot> spots, required this.settings}): _spots = spots;


@override final  String id;
@override final  DateTime completedAt;
@override final  DateTime startedAt;
@override final  Coordinate departure;
@override final  String overviewPolyline;
 final  List<MissionHistorySpot> _spots;
@override List<MissionHistorySpot> get spots {
  if (_spots is EqualUnmodifiableListView) return _spots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spots);
}

@override final  MissionSettings settings;

/// Create a copy of MissionHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MissionHistoryCopyWith<_MissionHistory> get copyWith => __$MissionHistoryCopyWithImpl<_MissionHistory>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MissionHistory&&(identical(other.id, id) || other.id == id)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.departure, departure) || other.departure == departure)&&(identical(other.overviewPolyline, overviewPolyline) || other.overviewPolyline == overviewPolyline)&&const DeepCollectionEquality().equals(other._spots, _spots)&&(identical(other.settings, settings) || other.settings == settings));
}


@override
int get hashCode => Object.hash(runtimeType,id,completedAt,startedAt,departure,overviewPolyline,const DeepCollectionEquality().hash(_spots),settings);

@override
String toString() {
  return 'MissionHistory(id: $id, completedAt: $completedAt, startedAt: $startedAt, departure: $departure, overviewPolyline: $overviewPolyline, spots: $spots, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$MissionHistoryCopyWith<$Res> implements $MissionHistoryCopyWith<$Res> {
  factory _$MissionHistoryCopyWith(_MissionHistory value, $Res Function(_MissionHistory) _then) = __$MissionHistoryCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime completedAt, DateTime startedAt, Coordinate departure, String overviewPolyline, List<MissionHistorySpot> spots, MissionSettings settings
});


@override $CoordinateCopyWith<$Res> get departure;@override $MissionSettingsCopyWith<$Res> get settings;

}
/// @nodoc
class __$MissionHistoryCopyWithImpl<$Res>
    implements _$MissionHistoryCopyWith<$Res> {
  __$MissionHistoryCopyWithImpl(this._self, this._then);

  final _MissionHistory _self;
  final $Res Function(_MissionHistory) _then;

/// Create a copy of MissionHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? completedAt = null,Object? startedAt = null,Object? departure = null,Object? overviewPolyline = null,Object? spots = null,Object? settings = null,}) {
  return _then(_MissionHistory(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,departure: null == departure ? _self.departure : departure // ignore: cast_nullable_to_non_nullable
as Coordinate,overviewPolyline: null == overviewPolyline ? _self.overviewPolyline : overviewPolyline // ignore: cast_nullable_to_non_nullable
as String,spots: null == spots ? _self._spots : spots // ignore: cast_nullable_to_non_nullable
as List<MissionHistorySpot>,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as MissionSettings,
  ));
}

/// Create a copy of MissionHistory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoordinateCopyWith<$Res> get departure {

  return $CoordinateCopyWith<$Res>(_self.departure, (value) {
    return _then(_self.copyWith(departure: value));
  });
}/// Create a copy of MissionHistory
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MissionSettingsCopyWith<$Res> get settings {

  return $MissionSettingsCopyWith<$Res>(_self.settings, (value) {
    return _then(_self.copyWith(settings: value));
  });
}
}

// dart format on
