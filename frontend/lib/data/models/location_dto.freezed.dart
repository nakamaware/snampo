// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocationDto _$LocationDtoFromJson(Map<String, dynamic> json) {
  return _LocationDto.fromJson(json);
}

/// @nodoc
mixin _$LocationDto {
  @JsonKey(name: 'departure')
  LocationPointDto? get departure => throw _privateConstructorUsedError;
  @JsonKey(name: 'destination')
  LocationPointDto? get destination => throw _privateConstructorUsedError;
  @JsonKey(name: 'midpoints')
  List<MidPointDto>? get midpoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'overview_polyline')
  String? get overviewPolyline => throw _privateConstructorUsedError;

  /// Serializes this LocationDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationDtoCopyWith<LocationDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationDtoCopyWith<$Res> {
  factory $LocationDtoCopyWith(
          LocationDto value, $Res Function(LocationDto) then) =
      _$LocationDtoCopyWithImpl<$Res, LocationDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'departure') LocationPointDto? departure,
      @JsonKey(name: 'destination') LocationPointDto? destination,
      @JsonKey(name: 'midpoints') List<MidPointDto>? midpoints,
      @JsonKey(name: 'overview_polyline') String? overviewPolyline});

  $LocationPointDtoCopyWith<$Res>? get departure;
  $LocationPointDtoCopyWith<$Res>? get destination;
}

/// @nodoc
class _$LocationDtoCopyWithImpl<$Res, $Val extends LocationDto>
    implements $LocationDtoCopyWith<$Res> {
  _$LocationDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? departure = freezed,
    Object? destination = freezed,
    Object? midpoints = freezed,
    Object? overviewPolyline = freezed,
  }) {
    return _then(_value.copyWith(
      departure: freezed == departure
          ? _value.departure
          : departure // ignore: cast_nullable_to_non_nullable
              as LocationPointDto?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationPointDto?,
      midpoints: freezed == midpoints
          ? _value.midpoints
          : midpoints // ignore: cast_nullable_to_non_nullable
              as List<MidPointDto>?,
      overviewPolyline: freezed == overviewPolyline
          ? _value.overviewPolyline
          : overviewPolyline // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationPointDtoCopyWith<$Res>? get departure {
    if (_value.departure == null) {
      return null;
    }

    return $LocationPointDtoCopyWith<$Res>(_value.departure!, (value) {
      return _then(_value.copyWith(departure: value) as $Val);
    });
  }

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationPointDtoCopyWith<$Res>? get destination {
    if (_value.destination == null) {
      return null;
    }

    return $LocationPointDtoCopyWith<$Res>(_value.destination!, (value) {
      return _then(_value.copyWith(destination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LocationDtoImplCopyWith<$Res>
    implements $LocationDtoCopyWith<$Res> {
  factory _$$LocationDtoImplCopyWith(
          _$LocationDtoImpl value, $Res Function(_$LocationDtoImpl) then) =
      __$$LocationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'departure') LocationPointDto? departure,
      @JsonKey(name: 'destination') LocationPointDto? destination,
      @JsonKey(name: 'midpoints') List<MidPointDto>? midpoints,
      @JsonKey(name: 'overview_polyline') String? overviewPolyline});

  @override
  $LocationPointDtoCopyWith<$Res>? get departure;
  @override
  $LocationPointDtoCopyWith<$Res>? get destination;
}

/// @nodoc
class __$$LocationDtoImplCopyWithImpl<$Res>
    extends _$LocationDtoCopyWithImpl<$Res, _$LocationDtoImpl>
    implements _$$LocationDtoImplCopyWith<$Res> {
  __$$LocationDtoImplCopyWithImpl(
      _$LocationDtoImpl _value, $Res Function(_$LocationDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? departure = freezed,
    Object? destination = freezed,
    Object? midpoints = freezed,
    Object? overviewPolyline = freezed,
  }) {
    return _then(_$LocationDtoImpl(
      departure: freezed == departure
          ? _value.departure
          : departure // ignore: cast_nullable_to_non_nullable
              as LocationPointDto?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationPointDto?,
      midpoints: freezed == midpoints
          ? _value._midpoints
          : midpoints // ignore: cast_nullable_to_non_nullable
              as List<MidPointDto>?,
      overviewPolyline: freezed == overviewPolyline
          ? _value.overviewPolyline
          : overviewPolyline // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationDtoImpl implements _LocationDto {
  const _$LocationDtoImpl(
      {@JsonKey(name: 'departure') this.departure,
      @JsonKey(name: 'destination') this.destination,
      @JsonKey(name: 'midpoints') final List<MidPointDto>? midpoints,
      @JsonKey(name: 'overview_polyline') this.overviewPolyline})
      : _midpoints = midpoints;

  factory _$LocationDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationDtoImplFromJson(json);

  @override
  @JsonKey(name: 'departure')
  final LocationPointDto? departure;
  @override
  @JsonKey(name: 'destination')
  final LocationPointDto? destination;
  final List<MidPointDto>? _midpoints;
  @override
  @JsonKey(name: 'midpoints')
  List<MidPointDto>? get midpoints {
    final value = _midpoints;
    if (value == null) return null;
    if (_midpoints is EqualUnmodifiableListView) return _midpoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'overview_polyline')
  final String? overviewPolyline;

  @override
  String toString() {
    return 'LocationDto(departure: $departure, destination: $destination, midpoints: $midpoints, overviewPolyline: $overviewPolyline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationDtoImpl &&
            (identical(other.departure, departure) ||
                other.departure == departure) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            const DeepCollectionEquality()
                .equals(other._midpoints, _midpoints) &&
            (identical(other.overviewPolyline, overviewPolyline) ||
                other.overviewPolyline == overviewPolyline));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, departure, destination,
      const DeepCollectionEquality().hash(_midpoints), overviewPolyline);

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationDtoImplCopyWith<_$LocationDtoImpl> get copyWith =>
      __$$LocationDtoImplCopyWithImpl<_$LocationDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationDtoImplToJson(
      this,
    );
  }
}

abstract class _LocationDto implements LocationDto {
  const factory _LocationDto(
          {@JsonKey(name: 'departure') final LocationPointDto? departure,
          @JsonKey(name: 'destination') final LocationPointDto? destination,
          @JsonKey(name: 'midpoints') final List<MidPointDto>? midpoints,
          @JsonKey(name: 'overview_polyline') final String? overviewPolyline}) =
      _$LocationDtoImpl;

  factory _LocationDto.fromJson(Map<String, dynamic> json) =
      _$LocationDtoImpl.fromJson;

  @override
  @JsonKey(name: 'departure')
  LocationPointDto? get departure;
  @override
  @JsonKey(name: 'destination')
  LocationPointDto? get destination;
  @override
  @JsonKey(name: 'midpoints')
  List<MidPointDto>? get midpoints;
  @override
  @JsonKey(name: 'overview_polyline')
  String? get overviewPolyline;

  /// Create a copy of LocationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationDtoImplCopyWith<_$LocationDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LocationPointDto _$LocationPointDtoFromJson(Map<String, dynamic> json) {
  return _LocationPointDto.fromJson(json);
}

/// @nodoc
mixin _$LocationPointDto {
  @JsonKey(name: 'latitude')
  double? get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'longitude')
  double? get longitude => throw _privateConstructorUsedError;

  /// Serializes this LocationPointDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationPointDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationPointDtoCopyWith<LocationPointDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationPointDtoCopyWith<$Res> {
  factory $LocationPointDtoCopyWith(
          LocationPointDto value, $Res Function(LocationPointDto) then) =
      _$LocationPointDtoCopyWithImpl<$Res, LocationPointDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'latitude') double? latitude,
      @JsonKey(name: 'longitude') double? longitude});
}

/// @nodoc
class _$LocationPointDtoCopyWithImpl<$Res, $Val extends LocationPointDto>
    implements $LocationPointDtoCopyWith<$Res> {
  _$LocationPointDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationPointDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_value.copyWith(
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationPointDtoImplCopyWith<$Res>
    implements $LocationPointDtoCopyWith<$Res> {
  factory _$$LocationPointDtoImplCopyWith(_$LocationPointDtoImpl value,
          $Res Function(_$LocationPointDtoImpl) then) =
      __$$LocationPointDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'latitude') double? latitude,
      @JsonKey(name: 'longitude') double? longitude});
}

/// @nodoc
class __$$LocationPointDtoImplCopyWithImpl<$Res>
    extends _$LocationPointDtoCopyWithImpl<$Res, _$LocationPointDtoImpl>
    implements _$$LocationPointDtoImplCopyWith<$Res> {
  __$$LocationPointDtoImplCopyWithImpl(_$LocationPointDtoImpl _value,
      $Res Function(_$LocationPointDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationPointDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_$LocationPointDtoImpl(
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationPointDtoImpl implements _LocationPointDto {
  const _$LocationPointDtoImpl(
      {@JsonKey(name: 'latitude') this.latitude,
      @JsonKey(name: 'longitude') this.longitude});

  factory _$LocationPointDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationPointDtoImplFromJson(json);

  @override
  @JsonKey(name: 'latitude')
  final double? latitude;
  @override
  @JsonKey(name: 'longitude')
  final double? longitude;

  @override
  String toString() {
    return 'LocationPointDto(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationPointDtoImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  /// Create a copy of LocationPointDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationPointDtoImplCopyWith<_$LocationPointDtoImpl> get copyWith =>
      __$$LocationPointDtoImplCopyWithImpl<_$LocationPointDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationPointDtoImplToJson(
      this,
    );
  }
}

abstract class _LocationPointDto implements LocationPointDto {
  const factory _LocationPointDto(
          {@JsonKey(name: 'latitude') final double? latitude,
          @JsonKey(name: 'longitude') final double? longitude}) =
      _$LocationPointDtoImpl;

  factory _LocationPointDto.fromJson(Map<String, dynamic> json) =
      _$LocationPointDtoImpl.fromJson;

  @override
  @JsonKey(name: 'latitude')
  double? get latitude;
  @override
  @JsonKey(name: 'longitude')
  double? get longitude;

  /// Create a copy of LocationPointDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationPointDtoImplCopyWith<_$LocationPointDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MidPointDto _$MidPointDtoFromJson(Map<String, dynamic> json) {
  return _MidPointDto.fromJson(json);
}

/// @nodoc
mixin _$MidPointDto {
  @JsonKey(name: 'metadata_latitude')
  double? get imageLatitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'metadata_longitude')
  double? get imageLongitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_latitude')
  double? get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_longitude')
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_data')
  String? get imageUtf8 => throw _privateConstructorUsedError;

  /// Serializes this MidPointDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MidPointDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MidPointDtoCopyWith<MidPointDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MidPointDtoCopyWith<$Res> {
  factory $MidPointDtoCopyWith(
          MidPointDto value, $Res Function(MidPointDto) then) =
      _$MidPointDtoCopyWithImpl<$Res, MidPointDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'metadata_latitude') double? imageLatitude,
      @JsonKey(name: 'metadata_longitude') double? imageLongitude,
      @JsonKey(name: 'original_latitude') double? latitude,
      @JsonKey(name: 'original_longitude') double? longitude,
      @JsonKey(name: 'image_data') String? imageUtf8});
}

/// @nodoc
class _$MidPointDtoCopyWithImpl<$Res, $Val extends MidPointDto>
    implements $MidPointDtoCopyWith<$Res> {
  _$MidPointDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MidPointDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageLatitude = freezed,
    Object? imageLongitude = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? imageUtf8 = freezed,
  }) {
    return _then(_value.copyWith(
      imageLatitude: freezed == imageLatitude
          ? _value.imageLatitude
          : imageLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      imageLongitude: freezed == imageLongitude
          ? _value.imageLongitude
          : imageLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      imageUtf8: freezed == imageUtf8
          ? _value.imageUtf8
          : imageUtf8 // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MidPointDtoImplCopyWith<$Res>
    implements $MidPointDtoCopyWith<$Res> {
  factory _$$MidPointDtoImplCopyWith(
          _$MidPointDtoImpl value, $Res Function(_$MidPointDtoImpl) then) =
      __$$MidPointDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'metadata_latitude') double? imageLatitude,
      @JsonKey(name: 'metadata_longitude') double? imageLongitude,
      @JsonKey(name: 'original_latitude') double? latitude,
      @JsonKey(name: 'original_longitude') double? longitude,
      @JsonKey(name: 'image_data') String? imageUtf8});
}

/// @nodoc
class __$$MidPointDtoImplCopyWithImpl<$Res>
    extends _$MidPointDtoCopyWithImpl<$Res, _$MidPointDtoImpl>
    implements _$$MidPointDtoImplCopyWith<$Res> {
  __$$MidPointDtoImplCopyWithImpl(
      _$MidPointDtoImpl _value, $Res Function(_$MidPointDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of MidPointDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageLatitude = freezed,
    Object? imageLongitude = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? imageUtf8 = freezed,
  }) {
    return _then(_$MidPointDtoImpl(
      imageLatitude: freezed == imageLatitude
          ? _value.imageLatitude
          : imageLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      imageLongitude: freezed == imageLongitude
          ? _value.imageLongitude
          : imageLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      imageUtf8: freezed == imageUtf8
          ? _value.imageUtf8
          : imageUtf8 // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MidPointDtoImpl implements _MidPointDto {
  const _$MidPointDtoImpl(
      {@JsonKey(name: 'metadata_latitude') this.imageLatitude,
      @JsonKey(name: 'metadata_longitude') this.imageLongitude,
      @JsonKey(name: 'original_latitude') this.latitude,
      @JsonKey(name: 'original_longitude') this.longitude,
      @JsonKey(name: 'image_data') this.imageUtf8});

  factory _$MidPointDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MidPointDtoImplFromJson(json);

  @override
  @JsonKey(name: 'metadata_latitude')
  final double? imageLatitude;
  @override
  @JsonKey(name: 'metadata_longitude')
  final double? imageLongitude;
  @override
  @JsonKey(name: 'original_latitude')
  final double? latitude;
  @override
  @JsonKey(name: 'original_longitude')
  final double? longitude;
  @override
  @JsonKey(name: 'image_data')
  final String? imageUtf8;

  @override
  String toString() {
    return 'MidPointDto(imageLatitude: $imageLatitude, imageLongitude: $imageLongitude, latitude: $latitude, longitude: $longitude, imageUtf8: $imageUtf8)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MidPointDtoImpl &&
            (identical(other.imageLatitude, imageLatitude) ||
                other.imageLatitude == imageLatitude) &&
            (identical(other.imageLongitude, imageLongitude) ||
                other.imageLongitude == imageLongitude) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.imageUtf8, imageUtf8) ||
                other.imageUtf8 == imageUtf8));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, imageLatitude, imageLongitude,
      latitude, longitude, imageUtf8);

  /// Create a copy of MidPointDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MidPointDtoImplCopyWith<_$MidPointDtoImpl> get copyWith =>
      __$$MidPointDtoImplCopyWithImpl<_$MidPointDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MidPointDtoImplToJson(
      this,
    );
  }
}

abstract class _MidPointDto implements MidPointDto {
  const factory _MidPointDto(
          {@JsonKey(name: 'metadata_latitude') final double? imageLatitude,
          @JsonKey(name: 'metadata_longitude') final double? imageLongitude,
          @JsonKey(name: 'original_latitude') final double? latitude,
          @JsonKey(name: 'original_longitude') final double? longitude,
          @JsonKey(name: 'image_data') final String? imageUtf8}) =
      _$MidPointDtoImpl;

  factory _MidPointDto.fromJson(Map<String, dynamic> json) =
      _$MidPointDtoImpl.fromJson;

  @override
  @JsonKey(name: 'metadata_latitude')
  double? get imageLatitude;
  @override
  @JsonKey(name: 'metadata_longitude')
  double? get imageLongitude;
  @override
  @JsonKey(name: 'original_latitude')
  double? get latitude;
  @override
  @JsonKey(name: 'original_longitude')
  double? get longitude;
  @override
  @JsonKey(name: 'image_data')
  String? get imageUtf8;

  /// Create a copy of MidPointDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MidPointDtoImplCopyWith<_$MidPointDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
