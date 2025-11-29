import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_dto.freezed.dart';
part 'location_dto.g.dart';

/// 位置情報DTO
@freezed
class LocationDto with _$LocationDto {
  /// LocationDtoのコンストラクタ
  const factory LocationDto({
    @JsonKey(name: 'departure') LocationPointDto? departure,
    @JsonKey(name: 'destination') LocationPointDto? destination,
    @JsonKey(name: 'midpoints') List<MidPointDto>? midpoints,
    @JsonKey(name: 'overview_polyline') String? overviewPolyline,
  }) = _LocationDto;

  /// JSONからLocationDtoを作成
  factory LocationDto.fromJson(Map<String, dynamic> json) =>
      _$LocationDtoFromJson(json);
}

/// 位置ポイントDTO
@freezed
class LocationPointDto with _$LocationPointDto {
  /// LocationPointDtoのコンストラクタ
  const factory LocationPointDto({
    @JsonKey(name: 'latitude') double? latitude,
    @JsonKey(name: 'longitude') double? longitude,
  }) = _LocationPointDto;

  /// JSONからLocationPointDtoを作成
  factory LocationPointDto.fromJson(Map<String, dynamic> json) =>
      _$LocationPointDtoFromJson(json);
}

/// 中間ポイントDTO
@freezed
class MidPointDto with _$MidPointDto {
  /// MidPointDtoのコンストラクタ
  const factory MidPointDto({
    @JsonKey(name: 'metadata_latitude') double? imageLatitude,
    @JsonKey(name: 'metadata_longitude') double? imageLongitude,
    @JsonKey(name: 'original_latitude') double? latitude,
    @JsonKey(name: 'original_longitude') double? longitude,
    @JsonKey(name: 'image_data') String? imageUtf8,
  }) = _MidPointDto;

  /// JSONからMidPointDtoを作成
  factory MidPointDto.fromJson(Map<String, dynamic> json) =>
      _$MidPointDtoFromJson(json);
}
