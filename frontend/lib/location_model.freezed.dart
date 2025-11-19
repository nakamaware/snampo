// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) {
  return _LocationModel.fromJson(json);
}

/// @nodoc
mixin _$LocationModel {
  @JsonKey(name: 'departure')
  LocationPoint? get departure => throw _privateConstructorUsedError;
  @JsonKey(name: 'destination')
  LocationPoint? get destination => throw _privateConstructorUsedError;
  @JsonKey(name: 'midpoints')
  List<MidPoint>? get midpoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'overview_polyline')
  String? get overviewPolyline => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LocationModelCopyWith<LocationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationModelCopyWith<$Res> {
  factory $LocationModelCopyWith(
          LocationModel value, $Res Function(LocationModel) then) =
      _$LocationModelCopyWithImpl<$Res, LocationModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'departure') LocationPoint? departure,
      @JsonKey(name: 'destination') LocationPoint? destination,
      @JsonKey(name: 'midpoints') List<MidPoint>? midpoints,
      @JsonKey(name: 'overview_polyline') String? overviewPolyline});

  $LocationPointCopyWith<$Res>? get departure;
  $LocationPointCopyWith<$Res>? get destination;
}

/// @nodoc
class _$LocationModelCopyWithImpl<$Res, $Val extends LocationModel>
    implements $LocationModelCopyWith<$Res> {
  _$LocationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
              as LocationPoint?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationPoint?,
      midpoints: freezed == midpoints
          ? _value.midpoints
          : midpoints // ignore: cast_nullable_to_non_nullable
              as List<MidPoint>?,
      overviewPolyline: freezed == overviewPolyline
          ? _value.overviewPolyline
          : overviewPolyline // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationPointCopyWith<$Res>? get departure {
    if (_value.departure == null) {
      return null;
    }

    return $LocationPointCopyWith<$Res>(_value.departure!, (value) {
      return _then(_value.copyWith(departure: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationPointCopyWith<$Res>? get destination {
    if (_value.destination == null) {
      return null;
    }

    return $LocationPointCopyWith<$Res>(_value.destination!, (value) {
      return _then(_value.copyWith(destination: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LocationModelImplCopyWith<$Res>
    implements $LocationModelCopyWith<$Res> {
  factory _$$LocationModelImplCopyWith(
          _$LocationModelImpl value, $Res Function(_$LocationModelImpl) then) =
      __$$LocationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'departure') LocationPoint? departure,
      @JsonKey(name: 'destination') LocationPoint? destination,
      @JsonKey(name: 'midpoints') List<MidPoint>? midpoints,
      @JsonKey(name: 'overview_polyline') String? overviewPolyline});

  @override
  $LocationPointCopyWith<$Res>? get departure;
  @override
  $LocationPointCopyWith<$Res>? get destination;
}

/// @nodoc
class __$$LocationModelImplCopyWithImpl<$Res>
    extends _$LocationModelCopyWithImpl<$Res, _$LocationModelImpl>
    implements _$$LocationModelImplCopyWith<$Res> {
  __$$LocationModelImplCopyWithImpl(
      _$LocationModelImpl _value, $Res Function(_$LocationModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? departure = freezed,
    Object? destination = freezed,
    Object? midpoints = freezed,
    Object? overviewPolyline = freezed,
  }) {
    return _then(_$LocationModelImpl(
      departure: freezed == departure
          ? _value.departure
          : departure // ignore: cast_nullable_to_non_nullable
              as LocationPoint?,
      destination: freezed == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as LocationPoint?,
      midpoints: freezed == midpoints
          ? _value._midpoints
          : midpoints // ignore: cast_nullable_to_non_nullable
              as List<MidPoint>?,
      overviewPolyline: freezed == overviewPolyline
          ? _value.overviewPolyline
          : overviewPolyline // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$LocationModelImpl implements _LocationModel {
  _$LocationModelImpl(
      {@JsonKey(name: 'departure') this.departure,
      @JsonKey(name: 'destination') this.destination,
      @JsonKey(name: 'midpoints') final List<MidPoint>? midpoints,
      @JsonKey(name: 'overview_polyline') this.overviewPolyline})
      : _midpoints = midpoints;

  factory _$LocationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationModelImplFromJson(json);

  @override
  @JsonKey(name: 'departure')
  final LocationPoint? departure;
  @override
  @JsonKey(name: 'destination')
  final LocationPoint? destination;
  final List<MidPoint>? _midpoints;
  @override
  @JsonKey(name: 'midpoints')
  List<MidPoint>? get midpoints {
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
    return 'LocationModel(departure: $departure, destination: $destination, midpoints: $midpoints, overviewPolyline: $overviewPolyline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationModelImpl &&
            (identical(other.departure, departure) ||
                other.departure == departure) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            const DeepCollectionEquality()
                .equals(other._midpoints, _midpoints) &&
            (identical(other.overviewPolyline, overviewPolyline) ||
                other.overviewPolyline == overviewPolyline));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, departure, destination,
      const DeepCollectionEquality().hash(_midpoints), overviewPolyline);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationModelImplCopyWith<_$LocationModelImpl> get copyWith =>
      __$$LocationModelImplCopyWithImpl<_$LocationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationModelImplToJson(
      this,
    );
  }
}

abstract class _LocationModel implements LocationModel {
  factory _LocationModel(
          {@JsonKey(name: 'departure') final LocationPoint? departure,
          @JsonKey(name: 'destination') final LocationPoint? destination,
          @JsonKey(name: 'midpoints') final List<MidPoint>? midpoints,
          @JsonKey(name: 'overview_polyline') final String? overviewPolyline}) =
      _$LocationModelImpl;

  factory _LocationModel.fromJson(Map<String, dynamic> json) =
      _$LocationModelImpl.fromJson;

  @override
  @JsonKey(name: 'departure')
  LocationPoint? get departure;
  @override
  @JsonKey(name: 'destination')
  LocationPoint? get destination;
  @override
  @JsonKey(name: 'midpoints')
  List<MidPoint>? get midpoints;
  @override
  @JsonKey(name: 'overview_polyline')
  String? get overviewPolyline;
  @override
  @JsonKey(ignore: true)
  _$$LocationModelImplCopyWith<_$LocationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LocationPoint _$LocationPointFromJson(Map<String, dynamic> json) {
  return _LocationPoint.fromJson(json);
}

/// @nodoc
mixin _$LocationPoint {
  @JsonKey(name: 'latitude')
  double? get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'longitude')
  double? get longitude => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LocationPointCopyWith<LocationPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationPointCopyWith<$Res> {
  factory $LocationPointCopyWith(
          LocationPoint value, $Res Function(LocationPoint) then) =
      _$LocationPointCopyWithImpl<$Res, LocationPoint>;
  @useResult
  $Res call(
      {@JsonKey(name: 'latitude') double? latitude,
      @JsonKey(name: 'longitude') double? longitude});
}

/// @nodoc
class _$LocationPointCopyWithImpl<$Res, $Val extends LocationPoint>
    implements $LocationPointCopyWith<$Res> {
  _$LocationPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
abstract class _$$LocationPointImplCopyWith<$Res>
    implements $LocationPointCopyWith<$Res> {
  factory _$$LocationPointImplCopyWith(
          _$LocationPointImpl value, $Res Function(_$LocationPointImpl) then) =
      __$$LocationPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'latitude') double? latitude,
      @JsonKey(name: 'longitude') double? longitude});
}

/// @nodoc
class __$$LocationPointImplCopyWithImpl<$Res>
    extends _$LocationPointCopyWithImpl<$Res, _$LocationPointImpl>
    implements _$$LocationPointImplCopyWith<$Res> {
  __$$LocationPointImplCopyWithImpl(
      _$LocationPointImpl _value, $Res Function(_$LocationPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(_$LocationPointImpl(
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
class _$LocationPointImpl implements _LocationPoint {
  _$LocationPointImpl(
      {@JsonKey(name: 'latitude') this.latitude,
      @JsonKey(name: 'longitude') this.longitude});

  factory _$LocationPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationPointImplFromJson(json);

  @override
  @JsonKey(name: 'latitude')
  final double? latitude;
  @override
  @JsonKey(name: 'longitude')
  final double? longitude;

  @override
  String toString() {
    return 'LocationPoint(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationPointImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationPointImplCopyWith<_$LocationPointImpl> get copyWith =>
      __$$LocationPointImplCopyWithImpl<_$LocationPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationPointImplToJson(
      this,
    );
  }
}

abstract class _LocationPoint implements LocationPoint {
  factory _LocationPoint(
          {@JsonKey(name: 'latitude') final double? latitude,
          @JsonKey(name: 'longitude') final double? longitude}) =
      _$LocationPointImpl;

  factory _LocationPoint.fromJson(Map<String, dynamic> json) =
      _$LocationPointImpl.fromJson;

  @override
  @JsonKey(name: 'latitude')
  double? get latitude;
  @override
  @JsonKey(name: 'longitude')
  double? get longitude;
  @override
  @JsonKey(ignore: true)
  _$$LocationPointImplCopyWith<_$LocationPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MidPoint _$MidPointFromJson(Map<String, dynamic> json) {
  return _MidPoint.fromJson(json);
}

/// @nodoc
mixin _$MidPoint {
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

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MidPointCopyWith<MidPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MidPointCopyWith<$Res> {
  factory $MidPointCopyWith(MidPoint value, $Res Function(MidPoint) then) =
      _$MidPointCopyWithImpl<$Res, MidPoint>;
  @useResult
  $Res call(
      {@JsonKey(name: 'metadata_latitude') double? imageLatitude,
      @JsonKey(name: 'metadata_longitude') double? imageLongitude,
      @JsonKey(name: 'original_latitude') double? latitude,
      @JsonKey(name: 'original_longitude') double? longitude,
      @JsonKey(name: 'image_data') String? imageUtf8});
}

/// @nodoc
class _$MidPointCopyWithImpl<$Res, $Val extends MidPoint>
    implements $MidPointCopyWith<$Res> {
  _$MidPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
abstract class _$$MidPointImplCopyWith<$Res>
    implements $MidPointCopyWith<$Res> {
  factory _$$MidPointImplCopyWith(
          _$MidPointImpl value, $Res Function(_$MidPointImpl) then) =
      __$$MidPointImplCopyWithImpl<$Res>;
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
class __$$MidPointImplCopyWithImpl<$Res>
    extends _$MidPointCopyWithImpl<$Res, _$MidPointImpl>
    implements _$$MidPointImplCopyWith<$Res> {
  __$$MidPointImplCopyWithImpl(
      _$MidPointImpl _value, $Res Function(_$MidPointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageLatitude = freezed,
    Object? imageLongitude = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? imageUtf8 = freezed,
  }) {
    return _then(_$MidPointImpl(
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
class _$MidPointImpl implements _MidPoint {
  _$MidPointImpl(
      {@JsonKey(name: 'metadata_latitude') this.imageLatitude,
      @JsonKey(name: 'metadata_longitude') this.imageLongitude,
      @JsonKey(name: 'original_latitude') this.latitude,
      @JsonKey(name: 'original_longitude') this.longitude,
      @JsonKey(name: 'image_data') this.imageUtf8});

  factory _$MidPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$MidPointImplFromJson(json);

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
    return 'MidPoint(imageLatitude: $imageLatitude, imageLongitude: $imageLongitude, latitude: $latitude, longitude: $longitude, imageUtf8: $imageUtf8)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MidPointImpl &&
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

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, imageLatitude, imageLongitude,
      latitude, longitude, imageUtf8);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MidPointImplCopyWith<_$MidPointImpl> get copyWith =>
      __$$MidPointImplCopyWithImpl<_$MidPointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MidPointImplToJson(
      this,
    );
  }
}

abstract class _MidPoint implements MidPoint {
  factory _MidPoint(
      {@JsonKey(name: 'metadata_latitude') final double? imageLatitude,
      @JsonKey(name: 'metadata_longitude') final double? imageLongitude,
      @JsonKey(name: 'original_latitude') final double? latitude,
      @JsonKey(name: 'original_longitude') final double? longitude,
      @JsonKey(name: 'image_data') final String? imageUtf8}) = _$MidPointImpl;

  factory _MidPoint.fromJson(Map<String, dynamic> json) =
      _$MidPointImpl.fromJson;

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
  @override
  @JsonKey(ignore: true)
  _$$MidPointImplCopyWith<_$MidPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
