// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RouteEntity {
  /// 出発地点
  LocationEntity? get departure;

  /// 目的地
  MidPointEntity? get destination;

  /// 中間地点のリスト
  List<MidPointEntity> get midpoints;

  /// ルートのポリライン文字列
  String? get overviewPolyline;

  /// Create a copy of RouteEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RouteEntityCopyWith<RouteEntity> get copyWith =>
      _$RouteEntityCopyWithImpl<RouteEntity>(this as RouteEntity, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RouteEntity &&
            (identical(other.departure, departure) ||
                other.departure == departure) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            const DeepCollectionEquality().equals(other.midpoints, midpoints) &&
            (identical(other.overviewPolyline, overviewPolyline) ||
                other.overviewPolyline == overviewPolyline));
  }

  @override
  int get hashCode => Object.hash(runtimeType, departure, destination,
      const DeepCollectionEquality().hash(midpoints), overviewPolyline);

  @override
  String toString() {
    return 'RouteEntity(departure: $departure, destination: $destination, midpoints: $midpoints, overviewPolyline: $overviewPolyline)';
  }
}

/// @nodoc
abstract mixin class $RouteEntityCopyWith<$Res> {
  factory $RouteEntityCopyWith(
          RouteEntity value, $Res Function(RouteEntity) _then) =
      _$RouteEntityCopyWithImpl;
  @useResult
  $Res call(
      {LocationEntity? departure,
      MidPointEntity? destination,
      List<MidPointEntity> midpoints,
      String? overviewPolyline});

  $LocationEntityCopyWith<$Res>? get departure;
  $MidPointEntityCopyWith<$Res>? get destination;
}

/// @nodoc
class _$RouteEntityCopyWithImpl<$Res> implements $RouteEntityCopyWith<$Res> {
  _$RouteEntityCopyWithImpl(this._self, this._then);

  final RouteEntity _self;
  final $Res Function(RouteEntity) _then;

  /// Create a copy of RouteEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? departure = freezed,
    Object? destination = freezed,
    Object? midpoints = null,
    Object? overviewPolyline = freezed,
  }) {
    return _then(_self.copyWith(
      departure: freezed == departure
          ? _self.departure
          : departure // ignore: cast_nullable_to_non_nullable
              as LocationEntity?,
      destination: freezed == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as MidPointEntity?,
      midpoints: null == midpoints
          ? _self.midpoints
          : midpoints // ignore: cast_nullable_to_non_nullable
              as List<MidPointEntity>,
      overviewPolyline: freezed == overviewPolyline
          ? _self.overviewPolyline
          : overviewPolyline // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of RouteEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationEntityCopyWith<$Res>? get departure {
    if (_self.departure == null) {
      return null;
    }

    return $LocationEntityCopyWith<$Res>(_self.departure!, (value) {
      return _then(_self.copyWith(departure: value));
    });
  }

  /// Create a copy of RouteEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MidPointEntityCopyWith<$Res>? get destination {
    if (_self.destination == null) {
      return null;
    }

    return $MidPointEntityCopyWith<$Res>(_self.destination!, (value) {
      return _then(_self.copyWith(destination: value));
    });
  }
}

/// Adds pattern-matching-related methods to [RouteEntity].
extension RouteEntityPatterns on RouteEntity {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RouteEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RouteEntity() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RouteEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RouteEntity():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RouteEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RouteEntity() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(LocationEntity? departure, MidPointEntity? destination,
            List<MidPointEntity> midpoints, String? overviewPolyline)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RouteEntity() when $default != null:
        return $default(_that.departure, _that.destination, _that.midpoints,
            _that.overviewPolyline);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(LocationEntity? departure, MidPointEntity? destination,
            List<MidPointEntity> midpoints, String? overviewPolyline)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RouteEntity():
        return $default(_that.departure, _that.destination, _that.midpoints,
            _that.overviewPolyline);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(LocationEntity? departure, MidPointEntity? destination,
            List<MidPointEntity> midpoints, String? overviewPolyline)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RouteEntity() when $default != null:
        return $default(_that.departure, _that.destination, _that.midpoints,
            _that.overviewPolyline);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RouteEntity implements RouteEntity {
  const _RouteEntity(
      {this.departure,
      this.destination,
      final List<MidPointEntity> midpoints = const [],
      this.overviewPolyline})
      : _midpoints = midpoints;

  /// 出発地点
  @override
  final LocationEntity? departure;

  /// 目的地
  @override
  final MidPointEntity? destination;

  /// 中間地点のリスト
  final List<MidPointEntity> _midpoints;

  /// 中間地点のリスト
  @override
  @JsonKey()
  List<MidPointEntity> get midpoints {
    if (_midpoints is EqualUnmodifiableListView) return _midpoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_midpoints);
  }

  /// ルートのポリライン文字列
  @override
  final String? overviewPolyline;

  /// Create a copy of RouteEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RouteEntityCopyWith<_RouteEntity> get copyWith =>
      __$RouteEntityCopyWithImpl<_RouteEntity>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RouteEntity &&
            (identical(other.departure, departure) ||
                other.departure == departure) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            const DeepCollectionEquality()
                .equals(other._midpoints, _midpoints) &&
            (identical(other.overviewPolyline, overviewPolyline) ||
                other.overviewPolyline == overviewPolyline));
  }

  @override
  int get hashCode => Object.hash(runtimeType, departure, destination,
      const DeepCollectionEquality().hash(_midpoints), overviewPolyline);

  @override
  String toString() {
    return 'RouteEntity(departure: $departure, destination: $destination, midpoints: $midpoints, overviewPolyline: $overviewPolyline)';
  }
}

/// @nodoc
abstract mixin class _$RouteEntityCopyWith<$Res>
    implements $RouteEntityCopyWith<$Res> {
  factory _$RouteEntityCopyWith(
          _RouteEntity value, $Res Function(_RouteEntity) _then) =
      __$RouteEntityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {LocationEntity? departure,
      MidPointEntity? destination,
      List<MidPointEntity> midpoints,
      String? overviewPolyline});

  @override
  $LocationEntityCopyWith<$Res>? get departure;
  @override
  $MidPointEntityCopyWith<$Res>? get destination;
}

/// @nodoc
class __$RouteEntityCopyWithImpl<$Res> implements _$RouteEntityCopyWith<$Res> {
  __$RouteEntityCopyWithImpl(this._self, this._then);

  final _RouteEntity _self;
  final $Res Function(_RouteEntity) _then;

  /// Create a copy of RouteEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? departure = freezed,
    Object? destination = freezed,
    Object? midpoints = null,
    Object? overviewPolyline = freezed,
  }) {
    return _then(_RouteEntity(
      departure: freezed == departure
          ? _self.departure
          : departure // ignore: cast_nullable_to_non_nullable
              as LocationEntity?,
      destination: freezed == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as MidPointEntity?,
      midpoints: null == midpoints
          ? _self._midpoints
          : midpoints // ignore: cast_nullable_to_non_nullable
              as List<MidPointEntity>,
      overviewPolyline: freezed == overviewPolyline
          ? _self.overviewPolyline
          : overviewPolyline // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of RouteEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationEntityCopyWith<$Res>? get departure {
    if (_self.departure == null) {
      return null;
    }

    return $LocationEntityCopyWith<$Res>(_self.departure!, (value) {
      return _then(_self.copyWith(departure: value));
    });
  }

  /// Create a copy of RouteEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MidPointEntityCopyWith<$Res>? get destination {
    if (_self.destination == null) {
      return null;
    }

    return $MidPointEntityCopyWith<$Res>(_self.destination!, (value) {
      return _then(_self.copyWith(destination: value));
    });
  }
}

/// @nodoc
mixin _$LocationEntity {
  /// 緯度
  double? get latitude;

  /// 経度
  double? get longitude;

  /// Create a copy of LocationEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LocationEntityCopyWith<LocationEntity> get copyWith =>
      _$LocationEntityCopyWithImpl<LocationEntity>(
          this as LocationEntity, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LocationEntity &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  @override
  String toString() {
    return 'LocationEntity(latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class $LocationEntityCopyWith<$Res> {
  factory $LocationEntityCopyWith(
          LocationEntity value, $Res Function(LocationEntity) _then) =
      _$LocationEntityCopyWithImpl;
  @useResult
  $Res call({double? latitude, double? longitude});
}

/// @nodoc
class _$LocationEntityCopyWithImpl<$Res>
    implements $LocationEntityCopyWith<$Res> {
  _$LocationEntityCopyWithImpl(this._self, this._then);

  final LocationEntity _self;
  final $Res Function(LocationEntity) _then;

  /// Create a copy of LocationEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_self.copyWith(
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// Adds pattern-matching-related methods to [LocationEntity].
extension LocationEntityPatterns on LocationEntity {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_LocationEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationEntity() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_LocationEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationEntity():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_LocationEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationEntity() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(double? latitude, double? longitude)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LocationEntity() when $default != null:
        return $default(_that.latitude, _that.longitude);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(double? latitude, double? longitude) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationEntity():
        return $default(_that.latitude, _that.longitude);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(double? latitude, double? longitude)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LocationEntity() when $default != null:
        return $default(_that.latitude, _that.longitude);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LocationEntity implements LocationEntity {
  const _LocationEntity({this.latitude, this.longitude});

  /// 緯度
  @override
  final double? latitude;

  /// 経度
  @override
  final double? longitude;

  /// Create a copy of LocationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LocationEntityCopyWith<_LocationEntity> get copyWith =>
      __$LocationEntityCopyWithImpl<_LocationEntity>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LocationEntity &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  @override
  String toString() {
    return 'LocationEntity(latitude: $latitude, longitude: $longitude)';
  }
}

/// @nodoc
abstract mixin class _$LocationEntityCopyWith<$Res>
    implements $LocationEntityCopyWith<$Res> {
  factory _$LocationEntityCopyWith(
          _LocationEntity value, $Res Function(_LocationEntity) _then) =
      __$LocationEntityCopyWithImpl;
  @override
  @useResult
  $Res call({double? latitude, double? longitude});
}

/// @nodoc
class __$LocationEntityCopyWithImpl<$Res>
    implements _$LocationEntityCopyWith<$Res> {
  __$LocationEntityCopyWithImpl(this._self, this._then);

  final _LocationEntity _self;
  final $Res Function(_LocationEntity) _then;

  /// Create a copy of LocationEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_LocationEntity(
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
mixin _$MidPointEntity {
  /// 画像のメタデータ緯度
  double? get imageLatitude;

  /// 画像のメタデータ経度
  double? get imageLongitude;

  /// 元の緯度
  double? get latitude;

  /// 元の経度
  double? get longitude;

  /// Base64エンコードされた画像データ
  String? get imageBase64;

  /// Create a copy of MidPointEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MidPointEntityCopyWith<MidPointEntity> get copyWith =>
      _$MidPointEntityCopyWithImpl<MidPointEntity>(
          this as MidPointEntity, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MidPointEntity &&
            (identical(other.imageLatitude, imageLatitude) ||
                other.imageLatitude == imageLatitude) &&
            (identical(other.imageLongitude, imageLongitude) ||
                other.imageLongitude == imageLongitude) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.imageBase64, imageBase64) ||
                other.imageBase64 == imageBase64));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imageLatitude, imageLongitude,
      latitude, longitude, imageBase64);

  @override
  String toString() {
    return 'MidPointEntity(imageLatitude: $imageLatitude, imageLongitude: $imageLongitude, latitude: $latitude, longitude: $longitude, imageBase64: $imageBase64)';
  }
}

/// @nodoc
abstract mixin class $MidPointEntityCopyWith<$Res> {
  factory $MidPointEntityCopyWith(
          MidPointEntity value, $Res Function(MidPointEntity) _then) =
      _$MidPointEntityCopyWithImpl;
  @useResult
  $Res call(
      {double? imageLatitude,
      double? imageLongitude,
      double? latitude,
      double? longitude,
      String? imageBase64});
}

/// @nodoc
class _$MidPointEntityCopyWithImpl<$Res>
    implements $MidPointEntityCopyWith<$Res> {
  _$MidPointEntityCopyWithImpl(this._self, this._then);

  final MidPointEntity _self;
  final $Res Function(MidPointEntity) _then;

  /// Create a copy of MidPointEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageLatitude = freezed,
    Object? imageLongitude = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? imageBase64 = freezed,
  }) {
    return _then(_self.copyWith(
      imageLatitude: freezed == imageLatitude
          ? _self.imageLatitude
          : imageLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      imageLongitude: freezed == imageLongitude
          ? _self.imageLongitude
          : imageLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      imageBase64: freezed == imageBase64
          ? _self.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [MidPointEntity].
extension MidPointEntityPatterns on MidPointEntity {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MidPointEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MidPointEntity() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MidPointEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MidPointEntity():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MidPointEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MidPointEntity() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(double? imageLatitude, double? imageLongitude,
            double? latitude, double? longitude, String? imageBase64)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MidPointEntity() when $default != null:
        return $default(_that.imageLatitude, _that.imageLongitude,
            _that.latitude, _that.longitude, _that.imageBase64);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(double? imageLatitude, double? imageLongitude,
            double? latitude, double? longitude, String? imageBase64)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MidPointEntity():
        return $default(_that.imageLatitude, _that.imageLongitude,
            _that.latitude, _that.longitude, _that.imageBase64);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(double? imageLatitude, double? imageLongitude,
            double? latitude, double? longitude, String? imageBase64)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MidPointEntity() when $default != null:
        return $default(_that.imageLatitude, _that.imageLongitude,
            _that.latitude, _that.longitude, _that.imageBase64);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MidPointEntity implements MidPointEntity {
  const _MidPointEntity(
      {this.imageLatitude,
      this.imageLongitude,
      this.latitude,
      this.longitude,
      this.imageBase64});

  /// 画像のメタデータ緯度
  @override
  final double? imageLatitude;

  /// 画像のメタデータ経度
  @override
  final double? imageLongitude;

  /// 元の緯度
  @override
  final double? latitude;

  /// 元の経度
  @override
  final double? longitude;

  /// Base64エンコードされた画像データ
  @override
  final String? imageBase64;

  /// Create a copy of MidPointEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MidPointEntityCopyWith<_MidPointEntity> get copyWith =>
      __$MidPointEntityCopyWithImpl<_MidPointEntity>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MidPointEntity &&
            (identical(other.imageLatitude, imageLatitude) ||
                other.imageLatitude == imageLatitude) &&
            (identical(other.imageLongitude, imageLongitude) ||
                other.imageLongitude == imageLongitude) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.imageBase64, imageBase64) ||
                other.imageBase64 == imageBase64));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imageLatitude, imageLongitude,
      latitude, longitude, imageBase64);

  @override
  String toString() {
    return 'MidPointEntity(imageLatitude: $imageLatitude, imageLongitude: $imageLongitude, latitude: $latitude, longitude: $longitude, imageBase64: $imageBase64)';
  }
}

/// @nodoc
abstract mixin class _$MidPointEntityCopyWith<$Res>
    implements $MidPointEntityCopyWith<$Res> {
  factory _$MidPointEntityCopyWith(
          _MidPointEntity value, $Res Function(_MidPointEntity) _then) =
      __$MidPointEntityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double? imageLatitude,
      double? imageLongitude,
      double? latitude,
      double? longitude,
      String? imageBase64});
}

/// @nodoc
class __$MidPointEntityCopyWithImpl<$Res>
    implements _$MidPointEntityCopyWith<$Res> {
  __$MidPointEntityCopyWithImpl(this._self, this._then);

  final _MidPointEntity _self;
  final $Res Function(_MidPointEntity) _then;

  /// Create a copy of MidPointEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? imageLatitude = freezed,
    Object? imageLongitude = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? imageBase64 = freezed,
  }) {
    return _then(_MidPointEntity(
      imageLatitude: freezed == imageLatitude
          ? _self.imageLatitude
          : imageLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      imageLongitude: freezed == imageLongitude
          ? _self.imageLongitude
          : imageLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      imageBase64: freezed == imageBase64
          ? _self.imageBase64
          : imageBase64 // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
