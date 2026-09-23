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
      judgeRank: const PhotoJudgeRankConverter().fromJson(
        json['judgeRank'] as String?,
      ),
      achievedAt:
          json['achievedAt'] == null
              ? null
              : DateTime.parse(json['achievedAt'] as String),
      discovererUid: json['discovererUid'] as String?,
      discovererNickname: json['discovererNickname'] as String?,
      discovererThumbPath: json['discovererThumbPath'] as String?,
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
      'judgeRank': const PhotoJudgeRankConverter().toJson(instance.judgeRank),
      'achievedAt': instance.achievedAt?.toIso8601String(),
      'discovererUid': instance.discovererUid,
      'discovererNickname': instance.discovererNickname,
      'discovererThumbPath': instance.discovererThumbPath,
    };

_MissionProgressEntity _$MissionProgressEntityFromJson(
  Map<String, dynamic> json,
) => _MissionProgressEntity(
  startedAt: DateTime.parse(json['startedAt'] as String),
  roomCode: json['roomCode'] as String?,
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
  'roomCode': instance.roomCode,
  'checkpoints': _missionProgressCheckpointsToJson(instance.checkpoints),
};
