// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coop_mission_store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CoopNotice {

/// 同じ文言でも別のお知らせとして扱うための連番
 int get id; String get message;
/// Create a copy of CoopNotice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoopNoticeCopyWith<CoopNotice> get copyWith => _$CoopNoticeCopyWithImpl<CoopNotice>(this as CoopNotice, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoopNotice&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,id,message);

@override
String toString() {
  return 'CoopNotice(id: $id, message: $message)';
}


}

/// @nodoc
abstract mixin class $CoopNoticeCopyWith<$Res>  {
  factory $CoopNoticeCopyWith(CoopNotice value, $Res Function(CoopNotice) _then) = _$CoopNoticeCopyWithImpl;
@useResult
$Res call({
 int id, String message
});




}
/// @nodoc
class _$CoopNoticeCopyWithImpl<$Res>
    implements $CoopNoticeCopyWith<$Res> {
  _$CoopNoticeCopyWithImpl(this._self, this._then);

  final CoopNotice _self;
  final $Res Function(CoopNotice) _then;

/// Create a copy of CoopNotice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? message = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoopNotice].
extension CoopNoticePatterns on CoopNotice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoopNotice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoopNotice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoopNotice value)  $default,){
final _that = this;
switch (_that) {
case _CoopNotice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoopNotice value)?  $default,){
final _that = this;
switch (_that) {
case _CoopNotice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoopNotice() when $default != null:
return $default(_that.id,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String message)  $default,) {final _that = this;
switch (_that) {
case _CoopNotice():
return $default(_that.id,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String message)?  $default,) {final _that = this;
switch (_that) {
case _CoopNotice() when $default != null:
return $default(_that.id,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _CoopNotice implements CoopNotice {
  const _CoopNotice({required this.id, required this.message});


/// 同じ文言でも別のお知らせとして扱うための連番
@override final  int id;
@override final  String message;

/// Create a copy of CoopNotice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoopNoticeCopyWith<_CoopNotice> get copyWith => __$CoopNoticeCopyWithImpl<_CoopNotice>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoopNotice&&(identical(other.id, id) || other.id == id)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,id,message);

@override
String toString() {
  return 'CoopNotice(id: $id, message: $message)';
}


}

/// @nodoc
abstract mixin class _$CoopNoticeCopyWith<$Res> implements $CoopNoticeCopyWith<$Res> {
  factory _$CoopNoticeCopyWith(_CoopNotice value, $Res Function(_CoopNotice) _then) = __$CoopNoticeCopyWithImpl;
@override @useResult
$Res call({
 int id, String message
});




}
/// @nodoc
class __$CoopNoticeCopyWithImpl<$Res>
    implements _$CoopNoticeCopyWith<$Res> {
  __$CoopNoticeCopyWithImpl(this._self, this._then);

  final _CoopNotice _self;
  final $Res Function(_CoopNotice) _then;

/// Create a copy of CoopNotice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? message = null,}) {
  return _then(_CoopNotice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CoopDiscoveryEvent {

/// 同じスポットでも別のイベントとして扱うための連番
 int get id;/// 発見されたスポットのインデックス
 int get spotIndex;/// 発見者の表示名
 String get discovererName;
/// Create a copy of CoopDiscoveryEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoopDiscoveryEventCopyWith<CoopDiscoveryEvent> get copyWith => _$CoopDiscoveryEventCopyWithImpl<CoopDiscoveryEvent>(this as CoopDiscoveryEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoopDiscoveryEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.spotIndex, spotIndex) || other.spotIndex == spotIndex)&&(identical(other.discovererName, discovererName) || other.discovererName == discovererName));
}


@override
int get hashCode => Object.hash(runtimeType,id,spotIndex,discovererName);

@override
String toString() {
  return 'CoopDiscoveryEvent(id: $id, spotIndex: $spotIndex, discovererName: $discovererName)';
}


}

/// @nodoc
abstract mixin class $CoopDiscoveryEventCopyWith<$Res>  {
  factory $CoopDiscoveryEventCopyWith(CoopDiscoveryEvent value, $Res Function(CoopDiscoveryEvent) _then) = _$CoopDiscoveryEventCopyWithImpl;
@useResult
$Res call({
 int id, int spotIndex, String discovererName
});




}
/// @nodoc
class _$CoopDiscoveryEventCopyWithImpl<$Res>
    implements $CoopDiscoveryEventCopyWith<$Res> {
  _$CoopDiscoveryEventCopyWithImpl(this._self, this._then);

  final CoopDiscoveryEvent _self;
  final $Res Function(CoopDiscoveryEvent) _then;

/// Create a copy of CoopDiscoveryEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? spotIndex = null,Object? discovererName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,spotIndex: null == spotIndex ? _self.spotIndex : spotIndex // ignore: cast_nullable_to_non_nullable
as int,discovererName: null == discovererName ? _self.discovererName : discovererName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoopDiscoveryEvent].
extension CoopDiscoveryEventPatterns on CoopDiscoveryEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoopDiscoveryEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoopDiscoveryEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoopDiscoveryEvent value)  $default,){
final _that = this;
switch (_that) {
case _CoopDiscoveryEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoopDiscoveryEvent value)?  $default,){
final _that = this;
switch (_that) {
case _CoopDiscoveryEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int spotIndex,  String discovererName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoopDiscoveryEvent() when $default != null:
return $default(_that.id,_that.spotIndex,_that.discovererName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int spotIndex,  String discovererName)  $default,) {final _that = this;
switch (_that) {
case _CoopDiscoveryEvent():
return $default(_that.id,_that.spotIndex,_that.discovererName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int spotIndex,  String discovererName)?  $default,) {final _that = this;
switch (_that) {
case _CoopDiscoveryEvent() when $default != null:
return $default(_that.id,_that.spotIndex,_that.discovererName);case _:
  return null;

}
}

}

/// @nodoc


class _CoopDiscoveryEvent implements CoopDiscoveryEvent {
  const _CoopDiscoveryEvent({required this.id, required this.spotIndex, required this.discovererName});


/// 同じスポットでも別のイベントとして扱うための連番
@override final  int id;
/// 発見されたスポットのインデックス
@override final  int spotIndex;
/// 発見者の表示名
@override final  String discovererName;

/// Create a copy of CoopDiscoveryEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoopDiscoveryEventCopyWith<_CoopDiscoveryEvent> get copyWith => __$CoopDiscoveryEventCopyWithImpl<_CoopDiscoveryEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoopDiscoveryEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.spotIndex, spotIndex) || other.spotIndex == spotIndex)&&(identical(other.discovererName, discovererName) || other.discovererName == discovererName));
}


@override
int get hashCode => Object.hash(runtimeType,id,spotIndex,discovererName);

@override
String toString() {
  return 'CoopDiscoveryEvent(id: $id, spotIndex: $spotIndex, discovererName: $discovererName)';
}


}

/// @nodoc
abstract mixin class _$CoopDiscoveryEventCopyWith<$Res> implements $CoopDiscoveryEventCopyWith<$Res> {
  factory _$CoopDiscoveryEventCopyWith(_CoopDiscoveryEvent value, $Res Function(_CoopDiscoveryEvent) _then) = __$CoopDiscoveryEventCopyWithImpl;
@override @useResult
$Res call({
 int id, int spotIndex, String discovererName
});




}
/// @nodoc
class __$CoopDiscoveryEventCopyWithImpl<$Res>
    implements _$CoopDiscoveryEventCopyWith<$Res> {
  __$CoopDiscoveryEventCopyWithImpl(this._self, this._then);

  final _CoopDiscoveryEvent _self;
  final $Res Function(_CoopDiscoveryEvent) _then;

/// Create a copy of CoopDiscoveryEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? spotIndex = null,Object? discovererName = null,}) {
  return _then(_CoopDiscoveryEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,spotIndex: null == spotIndex ? _self.spotIndex : spotIndex // ignore: cast_nullable_to_non_nullable
as int,discovererName: null == discovererName ? _self.discovererName : discovererName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CoopMissionState {

/// ミッションを端末に用意できたか (バンドルの取得と履歴の作成が済んだか)
 bool get isReady;/// ミッションの用意に失敗した理由
 Object? get prepareError;/// サムネを共有中のスポット (「発見を共有中…」の表示用)
 Set<SpotId> get sharingSpotIds;/// 最新のお知らせ
 CoopNotice? get notice;/// 最新の、他の人による発見 (最後のスポットは結果画面へ移るので出さない)
 CoopDiscoveryEvent? get discovery;
/// Create a copy of CoopMissionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoopMissionStateCopyWith<CoopMissionState> get copyWith => _$CoopMissionStateCopyWithImpl<CoopMissionState>(this as CoopMissionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoopMissionState&&(identical(other.isReady, isReady) || other.isReady == isReady)&&const DeepCollectionEquality().equals(other.prepareError, prepareError)&&const DeepCollectionEquality().equals(other.sharingSpotIds, sharingSpotIds)&&(identical(other.notice, notice) || other.notice == notice)&&(identical(other.discovery, discovery) || other.discovery == discovery));
}


@override
int get hashCode => Object.hash(runtimeType,isReady,const DeepCollectionEquality().hash(prepareError),const DeepCollectionEquality().hash(sharingSpotIds),notice,discovery);

@override
String toString() {
  return 'CoopMissionState(isReady: $isReady, prepareError: $prepareError, sharingSpotIds: $sharingSpotIds, notice: $notice, discovery: $discovery)';
}


}

/// @nodoc
abstract mixin class $CoopMissionStateCopyWith<$Res>  {
  factory $CoopMissionStateCopyWith(CoopMissionState value, $Res Function(CoopMissionState) _then) = _$CoopMissionStateCopyWithImpl;
@useResult
$Res call({
 bool isReady, Object? prepareError, Set<SpotId> sharingSpotIds, CoopNotice? notice, CoopDiscoveryEvent? discovery
});


$CoopNoticeCopyWith<$Res>? get notice;$CoopDiscoveryEventCopyWith<$Res>? get discovery;

}
/// @nodoc
class _$CoopMissionStateCopyWithImpl<$Res>
    implements $CoopMissionStateCopyWith<$Res> {
  _$CoopMissionStateCopyWithImpl(this._self, this._then);

  final CoopMissionState _self;
  final $Res Function(CoopMissionState) _then;

/// Create a copy of CoopMissionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isReady = null,Object? prepareError = freezed,Object? sharingSpotIds = null,Object? notice = freezed,Object? discovery = freezed,}) {
  return _then(_self.copyWith(
isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,prepareError: freezed == prepareError ? _self.prepareError : prepareError ,sharingSpotIds: null == sharingSpotIds ? _self.sharingSpotIds : sharingSpotIds // ignore: cast_nullable_to_non_nullable
as Set<SpotId>,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as CoopNotice?,discovery: freezed == discovery ? _self.discovery : discovery // ignore: cast_nullable_to_non_nullable
as CoopDiscoveryEvent?,
  ));
}
/// Create a copy of CoopMissionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoopNoticeCopyWith<$Res>? get notice {
    if (_self.notice == null) {
    return null;
  }

  return $CoopNoticeCopyWith<$Res>(_self.notice!, (value) {
    return _then(_self.copyWith(notice: value));
  });
}/// Create a copy of CoopMissionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoopDiscoveryEventCopyWith<$Res>? get discovery {
    if (_self.discovery == null) {
    return null;
  }

  return $CoopDiscoveryEventCopyWith<$Res>(_self.discovery!, (value) {
    return _then(_self.copyWith(discovery: value));
  });
}
}


/// Adds pattern-matching-related methods to [CoopMissionState].
extension CoopMissionStatePatterns on CoopMissionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoopMissionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoopMissionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoopMissionState value)  $default,){
final _that = this;
switch (_that) {
case _CoopMissionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoopMissionState value)?  $default,){
final _that = this;
switch (_that) {
case _CoopMissionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isReady,  Object? prepareError,  Set<SpotId> sharingSpotIds,  CoopNotice? notice,  CoopDiscoveryEvent? discovery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoopMissionState() when $default != null:
return $default(_that.isReady,_that.prepareError,_that.sharingSpotIds,_that.notice,_that.discovery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isReady,  Object? prepareError,  Set<SpotId> sharingSpotIds,  CoopNotice? notice,  CoopDiscoveryEvent? discovery)  $default,) {final _that = this;
switch (_that) {
case _CoopMissionState():
return $default(_that.isReady,_that.prepareError,_that.sharingSpotIds,_that.notice,_that.discovery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isReady,  Object? prepareError,  Set<SpotId> sharingSpotIds,  CoopNotice? notice,  CoopDiscoveryEvent? discovery)?  $default,) {final _that = this;
switch (_that) {
case _CoopMissionState() when $default != null:
return $default(_that.isReady,_that.prepareError,_that.sharingSpotIds,_that.notice,_that.discovery);case _:
  return null;

}
}

}

/// @nodoc


class _CoopMissionState implements CoopMissionState {
  const _CoopMissionState({this.isReady = false, this.prepareError, final  Set<SpotId> sharingSpotIds = const <SpotId>{}, this.notice, this.discovery}): _sharingSpotIds = sharingSpotIds;


/// ミッションを端末に用意できたか (バンドルの取得と履歴の作成が済んだか)
@override@JsonKey() final  bool isReady;
/// ミッションの用意に失敗した理由
@override final  Object? prepareError;
/// サムネを共有中のスポット (「発見を共有中…」の表示用)
 final  Set<SpotId> _sharingSpotIds;
/// サムネを共有中のスポット (「発見を共有中…」の表示用)
@override@JsonKey() Set<SpotId> get sharingSpotIds {
  if (_sharingSpotIds is EqualUnmodifiableSetView) return _sharingSpotIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_sharingSpotIds);
}

/// 最新のお知らせ
@override final  CoopNotice? notice;
/// 最新の、他の人による発見 (最後のスポットは結果画面へ移るので出さない)
@override final  CoopDiscoveryEvent? discovery;

/// Create a copy of CoopMissionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoopMissionStateCopyWith<_CoopMissionState> get copyWith => __$CoopMissionStateCopyWithImpl<_CoopMissionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoopMissionState&&(identical(other.isReady, isReady) || other.isReady == isReady)&&const DeepCollectionEquality().equals(other.prepareError, prepareError)&&const DeepCollectionEquality().equals(other._sharingSpotIds, _sharingSpotIds)&&(identical(other.notice, notice) || other.notice == notice)&&(identical(other.discovery, discovery) || other.discovery == discovery));
}


@override
int get hashCode => Object.hash(runtimeType,isReady,const DeepCollectionEquality().hash(prepareError),const DeepCollectionEquality().hash(_sharingSpotIds),notice,discovery);

@override
String toString() {
  return 'CoopMissionState(isReady: $isReady, prepareError: $prepareError, sharingSpotIds: $sharingSpotIds, notice: $notice, discovery: $discovery)';
}


}

/// @nodoc
abstract mixin class _$CoopMissionStateCopyWith<$Res> implements $CoopMissionStateCopyWith<$Res> {
  factory _$CoopMissionStateCopyWith(_CoopMissionState value, $Res Function(_CoopMissionState) _then) = __$CoopMissionStateCopyWithImpl;
@override @useResult
$Res call({
 bool isReady, Object? prepareError, Set<SpotId> sharingSpotIds, CoopNotice? notice, CoopDiscoveryEvent? discovery
});


@override $CoopNoticeCopyWith<$Res>? get notice;@override $CoopDiscoveryEventCopyWith<$Res>? get discovery;

}
/// @nodoc
class __$CoopMissionStateCopyWithImpl<$Res>
    implements _$CoopMissionStateCopyWith<$Res> {
  __$CoopMissionStateCopyWithImpl(this._self, this._then);

  final _CoopMissionState _self;
  final $Res Function(_CoopMissionState) _then;

/// Create a copy of CoopMissionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isReady = null,Object? prepareError = freezed,Object? sharingSpotIds = null,Object? notice = freezed,Object? discovery = freezed,}) {
  return _then(_CoopMissionState(
isReady: null == isReady ? _self.isReady : isReady // ignore: cast_nullable_to_non_nullable
as bool,prepareError: freezed == prepareError ? _self.prepareError : prepareError ,sharingSpotIds: null == sharingSpotIds ? _self._sharingSpotIds : sharingSpotIds // ignore: cast_nullable_to_non_nullable
as Set<SpotId>,notice: freezed == notice ? _self.notice : notice // ignore: cast_nullable_to_non_nullable
as CoopNotice?,discovery: freezed == discovery ? _self.discovery : discovery // ignore: cast_nullable_to_non_nullable
as CoopDiscoveryEvent?,
  ));
}

/// Create a copy of CoopMissionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoopNoticeCopyWith<$Res>? get notice {
    if (_self.notice == null) {
    return null;
  }

  return $CoopNoticeCopyWith<$Res>(_self.notice!, (value) {
    return _then(_self.copyWith(notice: value));
  });
}/// Create a copy of CoopMissionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CoopDiscoveryEventCopyWith<$Res>? get discovery {
    if (_self.discovery == null) {
    return null;
  }

  return $CoopDiscoveryEventCopyWith<$Res>(_self.discovery!, (value) {
    return _then(_self.copyWith(discovery: value));
  });
}
}

// dart format on
