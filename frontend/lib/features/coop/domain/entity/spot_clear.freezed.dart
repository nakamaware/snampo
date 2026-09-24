// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spot_clear.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SpotClear {

 SpotId get spotId;/// 発見者の Auth uid
 String get clearedBy;/// 発見時点の発見者のニックネーム
 String get nickname; DateTime get clearedAt;/// サムネの Storage パス (サムネを上げてからクリアを作成するので必ずある)
 String get thumbPath;
/// Create a copy of SpotClear
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotClearCopyWith<SpotClear> get copyWith => _$SpotClearCopyWithImpl<SpotClear>(this as SpotClear, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpotClear&&(identical(other.spotId, spotId) || other.spotId == spotId)&&(identical(other.clearedBy, clearedBy) || other.clearedBy == clearedBy)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.clearedAt, clearedAt) || other.clearedAt == clearedAt)&&(identical(other.thumbPath, thumbPath) || other.thumbPath == thumbPath));
}


@override
int get hashCode => Object.hash(runtimeType,spotId,clearedBy,nickname,clearedAt,thumbPath);

@override
String toString() {
  return 'SpotClear(spotId: $spotId, clearedBy: $clearedBy, nickname: $nickname, clearedAt: $clearedAt, thumbPath: $thumbPath)';
}


}

/// @nodoc
abstract mixin class $SpotClearCopyWith<$Res>  {
  factory $SpotClearCopyWith(SpotClear value, $Res Function(SpotClear) _then) = _$SpotClearCopyWithImpl;
@useResult
$Res call({
 SpotId spotId, String clearedBy, String nickname, DateTime clearedAt, String thumbPath
});




}
/// @nodoc
class _$SpotClearCopyWithImpl<$Res>
    implements $SpotClearCopyWith<$Res> {
  _$SpotClearCopyWithImpl(this._self, this._then);

  final SpotClear _self;
  final $Res Function(SpotClear) _then;

/// Create a copy of SpotClear
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? spotId = null,Object? clearedBy = null,Object? nickname = null,Object? clearedAt = null,Object? thumbPath = null,}) {
  return _then(_self.copyWith(
spotId: null == spotId ? _self.spotId : spotId // ignore: cast_nullable_to_non_nullable
as SpotId,clearedBy: null == clearedBy ? _self.clearedBy : clearedBy // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,clearedAt: null == clearedAt ? _self.clearedAt : clearedAt // ignore: cast_nullable_to_non_nullable
as DateTime,thumbPath: null == thumbPath ? _self.thumbPath : thumbPath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SpotClear].
extension SpotClearPatterns on SpotClear {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpotClear value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpotClear() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpotClear value)  $default,){
final _that = this;
switch (_that) {
case _SpotClear():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpotClear value)?  $default,){
final _that = this;
switch (_that) {
case _SpotClear() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SpotId spotId,  String clearedBy,  String nickname,  DateTime clearedAt,  String thumbPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpotClear() when $default != null:
return $default(_that.spotId,_that.clearedBy,_that.nickname,_that.clearedAt,_that.thumbPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SpotId spotId,  String clearedBy,  String nickname,  DateTime clearedAt,  String thumbPath)  $default,) {final _that = this;
switch (_that) {
case _SpotClear():
return $default(_that.spotId,_that.clearedBy,_that.nickname,_that.clearedAt,_that.thumbPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SpotId spotId,  String clearedBy,  String nickname,  DateTime clearedAt,  String thumbPath)?  $default,) {final _that = this;
switch (_that) {
case _SpotClear() when $default != null:
return $default(_that.spotId,_that.clearedBy,_that.nickname,_that.clearedAt,_that.thumbPath);case _:
  return null;

}
}

}

/// @nodoc


class _SpotClear implements SpotClear {
  const _SpotClear({required this.spotId, required this.clearedBy, required this.nickname, required this.clearedAt, required this.thumbPath});


@override final  SpotId spotId;
/// 発見者の Auth uid
@override final  String clearedBy;
/// 発見時点の発見者のニックネーム
@override final  String nickname;
@override final  DateTime clearedAt;
/// サムネの Storage パス (サムネを上げてからクリアを作成するので必ずある)
@override final  String thumbPath;

/// Create a copy of SpotClear
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotClearCopyWith<_SpotClear> get copyWith => __$SpotClearCopyWithImpl<_SpotClear>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpotClear&&(identical(other.spotId, spotId) || other.spotId == spotId)&&(identical(other.clearedBy, clearedBy) || other.clearedBy == clearedBy)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.clearedAt, clearedAt) || other.clearedAt == clearedAt)&&(identical(other.thumbPath, thumbPath) || other.thumbPath == thumbPath));
}


@override
int get hashCode => Object.hash(runtimeType,spotId,clearedBy,nickname,clearedAt,thumbPath);

@override
String toString() {
  return 'SpotClear(spotId: $spotId, clearedBy: $clearedBy, nickname: $nickname, clearedAt: $clearedAt, thumbPath: $thumbPath)';
}


}

/// @nodoc
abstract mixin class _$SpotClearCopyWith<$Res> implements $SpotClearCopyWith<$Res> {
  factory _$SpotClearCopyWith(_SpotClear value, $Res Function(_SpotClear) _then) = __$SpotClearCopyWithImpl;
@override @useResult
$Res call({
 SpotId spotId, String clearedBy, String nickname, DateTime clearedAt, String thumbPath
});




}
/// @nodoc
class __$SpotClearCopyWithImpl<$Res>
    implements _$SpotClearCopyWith<$Res> {
  __$SpotClearCopyWithImpl(this._self, this._then);

  final _SpotClear _self;
  final $Res Function(_SpotClear) _then;

/// Create a copy of SpotClear
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? spotId = null,Object? clearedBy = null,Object? nickname = null,Object? clearedAt = null,Object? thumbPath = null,}) {
  return _then(_SpotClear(
spotId: null == spotId ? _self.spotId : spotId // ignore: cast_nullable_to_non_nullable
as SpotId,clearedBy: null == clearedBy ? _self.clearedBy : clearedBy // ignore: cast_nullable_to_non_nullable
as String,nickname: null == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String,clearedAt: null == clearedAt ? _self.clearedAt : clearedAt // ignore: cast_nullable_to_non_nullable
as DateTime,thumbPath: null == thumbPath ? _self.thumbPath : thumbPath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$LocalClearState {

/// 反映済みの発見者の uid
 String? get discovererUid;/// 発見者のサムネを取得済みか
 bool get hasThumb;
/// Create a copy of LocalClearState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalClearStateCopyWith<LocalClearState> get copyWith => _$LocalClearStateCopyWithImpl<LocalClearState>(this as LocalClearState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalClearState&&(identical(other.discovererUid, discovererUid) || other.discovererUid == discovererUid)&&(identical(other.hasThumb, hasThumb) || other.hasThumb == hasThumb));
}


@override
int get hashCode => Object.hash(runtimeType,discovererUid,hasThumb);

@override
String toString() {
  return 'LocalClearState(discovererUid: $discovererUid, hasThumb: $hasThumb)';
}


}

/// @nodoc
abstract mixin class $LocalClearStateCopyWith<$Res>  {
  factory $LocalClearStateCopyWith(LocalClearState value, $Res Function(LocalClearState) _then) = _$LocalClearStateCopyWithImpl;
@useResult
$Res call({
 String? discovererUid, bool hasThumb
});




}
/// @nodoc
class _$LocalClearStateCopyWithImpl<$Res>
    implements $LocalClearStateCopyWith<$Res> {
  _$LocalClearStateCopyWithImpl(this._self, this._then);

  final LocalClearState _self;
  final $Res Function(LocalClearState) _then;

/// Create a copy of LocalClearState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? discovererUid = freezed,Object? hasThumb = null,}) {
  return _then(_self.copyWith(
discovererUid: freezed == discovererUid ? _self.discovererUid : discovererUid // ignore: cast_nullable_to_non_nullable
as String?,hasThumb: null == hasThumb ? _self.hasThumb : hasThumb // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalClearState].
extension LocalClearStatePatterns on LocalClearState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalClearState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalClearState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalClearState value)  $default,){
final _that = this;
switch (_that) {
case _LocalClearState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalClearState value)?  $default,){
final _that = this;
switch (_that) {
case _LocalClearState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? discovererUid,  bool hasThumb)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalClearState() when $default != null:
return $default(_that.discovererUid,_that.hasThumb);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? discovererUid,  bool hasThumb)  $default,) {final _that = this;
switch (_that) {
case _LocalClearState():
return $default(_that.discovererUid,_that.hasThumb);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? discovererUid,  bool hasThumb)?  $default,) {final _that = this;
switch (_that) {
case _LocalClearState() when $default != null:
return $default(_that.discovererUid,_that.hasThumb);case _:
  return null;

}
}

}

/// @nodoc


class _LocalClearState implements LocalClearState {
  const _LocalClearState({required this.discovererUid, required this.hasThumb});


/// 反映済みの発見者の uid
@override final  String? discovererUid;
/// 発見者のサムネを取得済みか
@override final  bool hasThumb;

/// Create a copy of LocalClearState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalClearStateCopyWith<_LocalClearState> get copyWith => __$LocalClearStateCopyWithImpl<_LocalClearState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalClearState&&(identical(other.discovererUid, discovererUid) || other.discovererUid == discovererUid)&&(identical(other.hasThumb, hasThumb) || other.hasThumb == hasThumb));
}


@override
int get hashCode => Object.hash(runtimeType,discovererUid,hasThumb);

@override
String toString() {
  return 'LocalClearState(discovererUid: $discovererUid, hasThumb: $hasThumb)';
}


}

/// @nodoc
abstract mixin class _$LocalClearStateCopyWith<$Res> implements $LocalClearStateCopyWith<$Res> {
  factory _$LocalClearStateCopyWith(_LocalClearState value, $Res Function(_LocalClearState) _then) = __$LocalClearStateCopyWithImpl;
@override @useResult
$Res call({
 String? discovererUid, bool hasThumb
});




}
/// @nodoc
class __$LocalClearStateCopyWithImpl<$Res>
    implements _$LocalClearStateCopyWith<$Res> {
  __$LocalClearStateCopyWithImpl(this._self, this._then);

  final _LocalClearState _self;
  final $Res Function(_LocalClearState) _then;

/// Create a copy of LocalClearState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? discovererUid = freezed,Object? hasThumb = null,}) {
  return _then(_LocalClearState(
discovererUid: freezed == discovererUid ? _self.discovererUid : discovererUid // ignore: cast_nullable_to_non_nullable
as String?,hasThumb: null == hasThumb ? _self.hasThumb : hasThumb // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ClearSyncPlan {

/// 発見者を端末に反映するクリア
 List<SpotClear> get discoverersToApply;/// サムネを取得するクリア
 List<SpotClear> get thumbsToFetch;
/// Create a copy of ClearSyncPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClearSyncPlanCopyWith<ClearSyncPlan> get copyWith => _$ClearSyncPlanCopyWithImpl<ClearSyncPlan>(this as ClearSyncPlan, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearSyncPlan&&const DeepCollectionEquality().equals(other.discoverersToApply, discoverersToApply)&&const DeepCollectionEquality().equals(other.thumbsToFetch, thumbsToFetch));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(discoverersToApply),const DeepCollectionEquality().hash(thumbsToFetch));

@override
String toString() {
  return 'ClearSyncPlan(discoverersToApply: $discoverersToApply, thumbsToFetch: $thumbsToFetch)';
}


}

/// @nodoc
abstract mixin class $ClearSyncPlanCopyWith<$Res>  {
  factory $ClearSyncPlanCopyWith(ClearSyncPlan value, $Res Function(ClearSyncPlan) _then) = _$ClearSyncPlanCopyWithImpl;
@useResult
$Res call({
 List<SpotClear> discoverersToApply, List<SpotClear> thumbsToFetch
});




}
/// @nodoc
class _$ClearSyncPlanCopyWithImpl<$Res>
    implements $ClearSyncPlanCopyWith<$Res> {
  _$ClearSyncPlanCopyWithImpl(this._self, this._then);

  final ClearSyncPlan _self;
  final $Res Function(ClearSyncPlan) _then;

/// Create a copy of ClearSyncPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? discoverersToApply = null,Object? thumbsToFetch = null,}) {
  return _then(_self.copyWith(
discoverersToApply: null == discoverersToApply ? _self.discoverersToApply : discoverersToApply // ignore: cast_nullable_to_non_nullable
as List<SpotClear>,thumbsToFetch: null == thumbsToFetch ? _self.thumbsToFetch : thumbsToFetch // ignore: cast_nullable_to_non_nullable
as List<SpotClear>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClearSyncPlan].
extension ClearSyncPlanPatterns on ClearSyncPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClearSyncPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClearSyncPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClearSyncPlan value)  $default,){
final _that = this;
switch (_that) {
case _ClearSyncPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClearSyncPlan value)?  $default,){
final _that = this;
switch (_that) {
case _ClearSyncPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SpotClear> discoverersToApply,  List<SpotClear> thumbsToFetch)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClearSyncPlan() when $default != null:
return $default(_that.discoverersToApply,_that.thumbsToFetch);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SpotClear> discoverersToApply,  List<SpotClear> thumbsToFetch)  $default,) {final _that = this;
switch (_that) {
case _ClearSyncPlan():
return $default(_that.discoverersToApply,_that.thumbsToFetch);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SpotClear> discoverersToApply,  List<SpotClear> thumbsToFetch)?  $default,) {final _that = this;
switch (_that) {
case _ClearSyncPlan() when $default != null:
return $default(_that.discoverersToApply,_that.thumbsToFetch);case _:
  return null;

}
}

}

/// @nodoc


class _ClearSyncPlan implements ClearSyncPlan {
  const _ClearSyncPlan({required final  List<SpotClear> discoverersToApply, required final  List<SpotClear> thumbsToFetch}): _discoverersToApply = discoverersToApply,_thumbsToFetch = thumbsToFetch;


/// 発見者を端末に反映するクリア
 final  List<SpotClear> _discoverersToApply;
/// 発見者を端末に反映するクリア
@override List<SpotClear> get discoverersToApply {
  if (_discoverersToApply is EqualUnmodifiableListView) return _discoverersToApply;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discoverersToApply);
}

/// サムネを取得するクリア
 final  List<SpotClear> _thumbsToFetch;
/// サムネを取得するクリア
@override List<SpotClear> get thumbsToFetch {
  if (_thumbsToFetch is EqualUnmodifiableListView) return _thumbsToFetch;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_thumbsToFetch);
}


/// Create a copy of ClearSyncPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClearSyncPlanCopyWith<_ClearSyncPlan> get copyWith => __$ClearSyncPlanCopyWithImpl<_ClearSyncPlan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClearSyncPlan&&const DeepCollectionEquality().equals(other._discoverersToApply, _discoverersToApply)&&const DeepCollectionEquality().equals(other._thumbsToFetch, _thumbsToFetch));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_discoverersToApply),const DeepCollectionEquality().hash(_thumbsToFetch));

@override
String toString() {
  return 'ClearSyncPlan(discoverersToApply: $discoverersToApply, thumbsToFetch: $thumbsToFetch)';
}


}

/// @nodoc
abstract mixin class _$ClearSyncPlanCopyWith<$Res> implements $ClearSyncPlanCopyWith<$Res> {
  factory _$ClearSyncPlanCopyWith(_ClearSyncPlan value, $Res Function(_ClearSyncPlan) _then) = __$ClearSyncPlanCopyWithImpl;
@override @useResult
$Res call({
 List<SpotClear> discoverersToApply, List<SpotClear> thumbsToFetch
});




}
/// @nodoc
class __$ClearSyncPlanCopyWithImpl<$Res>
    implements _$ClearSyncPlanCopyWith<$Res> {
  __$ClearSyncPlanCopyWithImpl(this._self, this._then);

  final _ClearSyncPlan _self;
  final $Res Function(_ClearSyncPlan) _then;

/// Create a copy of ClearSyncPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? discoverersToApply = null,Object? thumbsToFetch = null,}) {
  return _then(_ClearSyncPlan(
discoverersToApply: null == discoverersToApply ? _self._discoverersToApply : discoverersToApply // ignore: cast_nullable_to_non_nullable
as List<SpotClear>,thumbsToFetch: null == thumbsToFetch ? _self._thumbsToFetch : thumbsToFetch // ignore: cast_nullable_to_non_nullable
as List<SpotClear>,
  ));
}


}

// dart format on
