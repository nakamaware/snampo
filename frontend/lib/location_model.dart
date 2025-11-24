import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_model.freezed.dart';
part 'location_model.g.dart';

@freezed
abstract class LocationModel with _$LocationModel {
  @JsonSerializable(explicitToJson: true)
  factory LocationModel({
    @JsonKey(name: 'departure') LocationPoint? departure,
    @JsonKey(name: 'destination') LocationPoint? destination,
    @JsonKey(name: 'midpoints') List<MidPoint>? midpoints,
    @JsonKey(name: 'overview_polyline') String? overviewPolyline,
  }) = _LocationModel;

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);
}

@freezed
abstract class LocationPoint with _$LocationPoint {
  factory LocationPoint({
    @JsonKey(name: 'latitude') double? latitude,
    @JsonKey(name: 'longitude') double? longitude,
  }) = _LocationPoint;

  factory LocationPoint.fromJson(Map<String, dynamic> json) =>
      _$LocationPointFromJson(json);
}

@freezed
abstract class MidPoint with _$MidPoint {
  factory MidPoint({
    @JsonKey(name: 'metadata_latitude') double? imageLatitude,
    @JsonKey(name: 'metadata_longitude') double? imageLongitude,
    @JsonKey(name: 'original_latitude') double? latitude,
    @JsonKey(name: 'original_longitude') double? longitude,
    @JsonKey(name: 'image_data') String? imageUtf8,
  }) = _MidPoint;

  factory MidPoint.fromJson(Map<String, dynamic> json) =>
      _$MidPointFromJson(json);
}