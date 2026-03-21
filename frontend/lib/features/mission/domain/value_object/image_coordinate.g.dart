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
    );

Map<String, dynamic> _$ImageCoordinateToJson(_ImageCoordinate instance) =>
    <String, dynamic>{
      'coordinate': const CoordinateConverter().toJson(instance.coordinate),
      'imageBase64': instance.imageBase64,
    };
