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
      discovererJudgement: _judgementFromJson(
        json['discovererJudgement'] as Map<String, dynamic>?,
      ),
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
      'discovererJudgement': _judgementToJson(instance.discovererJudgement),
    };

_MissionProgressEntity _$MissionProgressEntityFromJson(
  Map<String, dynamic> json,
) => _MissionProgressEntity(
  startedAt: DateTime.parse(json['startedAt'] as String),
  roomCode: _$JsonConverterFromJson<String, RoomCode>(
    json['roomCode'],
    const RoomCodeConverter().fromJson,
  ),
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
  'roomCode': _$JsonConverterToJson<String, RoomCode>(
    instance.roomCode,
    const RoomCodeConverter().toJson,
  ),
  'checkpoints': _missionProgressCheckpointsToJson(instance.checkpoints),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
