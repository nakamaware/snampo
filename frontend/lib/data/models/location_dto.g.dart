// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationDtoImpl _$$LocationDtoImplFromJson(Map<String, dynamic> json) =>
    _$LocationDtoImpl(
      departure: json['departure'] == null
          ? null
          : LocationPointDto.fromJson(
              json['departure'] as Map<String, dynamic>),
      destination: json['destination'] == null
          ? null
          : LocationPointDto.fromJson(
              json['destination'] as Map<String, dynamic>),
      midpoints: (json['midpoints'] as List<dynamic>?)
          ?.map((e) => MidPointDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      overviewPolyline: json['overview_polyline'] as String?,
    );

Map<String, dynamic> _$$LocationDtoImplToJson(_$LocationDtoImpl instance) =>
    <String, dynamic>{
      'departure': instance.departure,
      'destination': instance.destination,
      'midpoints': instance.midpoints,
      'overview_polyline': instance.overviewPolyline,
    };

_$LocationPointDtoImpl _$$LocationPointDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$LocationPointDtoImpl(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$LocationPointDtoImplToJson(
        _$LocationPointDtoImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_$MidPointDtoImpl _$$MidPointDtoImplFromJson(Map<String, dynamic> json) =>
    _$MidPointDtoImpl(
      imageLatitude: (json['metadata_latitude'] as num?)?.toDouble(),
      imageLongitude: (json['metadata_longitude'] as num?)?.toDouble(),
      latitude: (json['original_latitude'] as num?)?.toDouble(),
      longitude: (json['original_longitude'] as num?)?.toDouble(),
      imageUtf8: json['image_data'] as String?,
    );

Map<String, dynamic> _$$MidPointDtoImplToJson(_$MidPointDtoImpl instance) =>
    <String, dynamic>{
      'metadata_latitude': instance.imageLatitude,
      'metadata_longitude': instance.imageLongitude,
      'original_latitude': instance.latitude,
      'original_longitude': instance.longitude,
      'image_data': instance.imageUtf8,
    };
