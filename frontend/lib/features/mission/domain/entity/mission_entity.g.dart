// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MissionEntity _$MissionEntityFromJson(Map<String, dynamic> json) =>
    _MissionEntity(
      departure: const CoordinateConverter().fromJson(
        json['departure'] as Map<String, dynamic>,
      ),
      destination: ImageCoordinate.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      overviewPolyline: json['overviewPolyline'] as String,
      radius: _$JsonConverterFromJson<Map<String, dynamic>, Radius>(
        json['radius'],
        const RadiusConverter().fromJson,
      ),
      waypoints:
          (json['waypoints'] as List<dynamic>?)
              ?.map((e) => ImageCoordinate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MissionEntityToJson(_MissionEntity instance) =>
    <String, dynamic>{
      'departure': const CoordinateConverter().toJson(instance.departure),
      'destination': _destinationToJson(instance.destination),
      'overviewPolyline': instance.overviewPolyline,
      'radius': _$JsonConverterToJson<Map<String, dynamic>, Radius>(
        instance.radius,
        const RadiusConverter().toJson,
      ),
      'waypoints': _waypointsToJson(instance.waypoints),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
