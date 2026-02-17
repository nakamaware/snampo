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
      radius: const RadiusConverter().fromJson(
        json['radius'] as Map<String, dynamic>,
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
      'radius': const RadiusConverter().toJson(instance.radius),
      'waypoints': _waypointsToJson(instance.waypoints),
    };
