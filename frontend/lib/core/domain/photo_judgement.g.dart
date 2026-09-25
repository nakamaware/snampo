// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_judgement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PhotoJudgement _$PhotoJudgementFromJson(Map<String, dynamic> json) =>
    _PhotoJudgement(
      rank: _rankFromJson(json['rank'] as String),
      distanceErrorMeters: (json['distanceErrorMeters'] as num).toDouble(),
      headingErrorDegrees: (json['headingErrorDegrees'] as num?)?.toDouble(),
      guessPosition: const NullableCoordinateConverter().fromJson(
        json['guessPosition'] as Map<String, dynamic>?,
      ),
      capturedHeading: (json['capturedHeading'] as num?)?.toDouble(),
      zoomLevel: (json['zoomLevel'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PhotoJudgementToJson(_PhotoJudgement instance) =>
    <String, dynamic>{
      'rank': _rankToJson(instance.rank),
      'distanceErrorMeters': instance.distanceErrorMeters,
      'headingErrorDegrees': instance.headingErrorDegrees,
      'guessPosition': const NullableCoordinateConverter().toJson(
        instance.guessPosition,
      ),
      'capturedHeading': instance.capturedHeading,
      'zoomLevel': instance.zoomLevel,
    };
