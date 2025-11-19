// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationModelImpl _$$LocationModelImplFromJson(Map<String, dynamic> json) =>
    _$LocationModelImpl(
      departure: json['departure'] == null
          ? null
          : LocationPoint.fromJson(json['departure'] as Map<String, dynamic>),
      destination: json['destination'] == null
          ? null
          : LocationPoint.fromJson(json['destination'] as Map<String, dynamic>),
      midpoints: (json['midpoints'] as List<dynamic>?)
          ?.map((e) => MidPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      overviewPolyline: json['overview_polyline'] as String?,
    );

Map<String, dynamic> _$$LocationModelImplToJson(_$LocationModelImpl instance) =>
    <String, dynamic>{
      'departure': instance.departure?.toJson(),
      'destination': instance.destination?.toJson(),
      'midpoints': instance.midpoints?.map((e) => e.toJson()).toList(),
      'overview_polyline': instance.overviewPolyline,
    };

_$LocationPointImpl _$$LocationPointImplFromJson(Map<String, dynamic> json) =>
    _$LocationPointImpl(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$LocationPointImplToJson(_$LocationPointImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_$MidPointImpl _$$MidPointImplFromJson(Map<String, dynamic> json) =>
    _$MidPointImpl(
      imageLatitude: (json['metadata_latitude'] as num?)?.toDouble(),
      imageLongitude: (json['metadata_longitude'] as num?)?.toDouble(),
      latitude: (json['original_latitude'] as num?)?.toDouble(),
      longitude: (json['original_longitude'] as num?)?.toDouble(),
      imageUtf8: json['image_data'] as String?,
    );

Map<String, dynamic> _$$MidPointImplToJson(_$MidPointImpl instance) =>
    <String, dynamic>{
      'metadata_latitude': instance.imageLatitude,
      'metadata_longitude': instance.imageLongitude,
      'original_latitude': instance.latitude,
      'original_longitude': instance.longitude,
      'image_data': instance.imageUtf8,
    };
