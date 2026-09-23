// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_coordinate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImageCoordinate _$ImageCoordinateFromJson(Map<String, dynamic> json) =>
    _ImageCoordinate(
      coordinate: const CoordinateConverter().fromJson(
        json['coordinate'] as Map<String, dynamic>,
      ),
      imageBase64: json['imageBase64'] as String,
      referenceHeading: (json['referenceHeading'] as num?)?.toDouble(),
      name: json['name'] as String?,
      genre: json['genre'] as String?,
      googleMapsUrl: json['googleMapsUrl'] as String?,
      streetViewLatitude: (json['streetViewLatitude'] as num?)?.toDouble(),
      streetViewLongitude: (json['streetViewLongitude'] as num?)?.toDouble(),
      spotId: _$JsonConverterFromJson<String, SpotId>(
        json['spotId'],
        const SpotIdConverter().fromJson,
      ),
    );

Map<String, dynamic> _$ImageCoordinateToJson(_ImageCoordinate instance) =>
    <String, dynamic>{
      'coordinate': const CoordinateConverter().toJson(instance.coordinate),
      'imageBase64': instance.imageBase64,
      'referenceHeading': instance.referenceHeading,
      'name': instance.name,
      'genre': instance.genre,
      'googleMapsUrl': instance.googleMapsUrl,
      'streetViewLatitude': instance.streetViewLatitude,
      'streetViewLongitude': instance.streetViewLongitude,
      'spotId': _$JsonConverterToJson<String, SpotId>(
        instance.spotId,
        const SpotIdConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
