// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_progress_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckpointProgress _$CheckpointProgressFromJson(Map<String, dynamic> json) =>
    _CheckpointProgress(
      guessPosition: const NullableCoordinateConverter().fromJson(
        json['guessPosition'] as Map<String, dynamic>?,
      ),
      userPhotoPath: json['userPhotoPath'] as String?,
      capturedHeading: (json['capturedHeading'] as num?)?.toDouble(),
      distanceErrorMeters: (json['distanceErrorMeters'] as num?)?.toDouble(),
      headingErrorDegrees: (json['headingErrorDegrees'] as num?)?.toDouble(),
      judgeRank: $enumDecodeNullable(
        _$PhotoJudgeRankEnumMap,
        json['judgeRank'],
      ),
      achievedAt:
          json['achievedAt'] == null
              ? null
              : DateTime.parse(json['achievedAt'] as String),
    );

Map<String, dynamic> _$CheckpointProgressToJson(_CheckpointProgress instance) =>
    <String, dynamic>{
      'guessPosition': const NullableCoordinateConverter().toJson(
        instance.guessPosition,
      ),
      'userPhotoPath': instance.userPhotoPath,
      'capturedHeading': instance.capturedHeading,
      'distanceErrorMeters': instance.distanceErrorMeters,
      'headingErrorDegrees': instance.headingErrorDegrees,
      'judgeRank': _$PhotoJudgeRankEnumMap[instance.judgeRank],
      'achievedAt': instance.achievedAt?.toIso8601String(),
    };

const _$PhotoJudgeRankEnumMap = {
  PhotoJudgeRank.excellent: 'excellent',
  PhotoJudgeRank.good: 'good',
  PhotoJudgeRank.fair: 'fair',
  PhotoJudgeRank.retry: 'retry',
};

_MissionProgressEntity _$MissionProgressEntityFromJson(
  Map<String, dynamic> json,
) => _MissionProgressEntity(
  startedAt: DateTime.parse(json['startedAt'] as String),
  checkpoints:
      (json['checkpoints'] as List<dynamic>?)
          ?.map(
            (e) =>
                e == null
                    ? null
                    : CheckpointProgress.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$MissionProgressEntityToJson(
  _MissionProgressEntity instance,
) => <String, dynamic>{
  'startedAt': instance.startedAt.toIso8601String(),
  'checkpoints': _missionProgressCheckpointsToJson(instance.checkpoints),
};
