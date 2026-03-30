// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_history_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MissionHistoryEntity _$MissionHistoryEntityFromJson(
  Map<String, dynamic> json,
) => _MissionHistoryEntity(
  id: json['id'] as String,
  completedAt: DateTime.parse(json['completedAt'] as String),
  mission: MissionEntity.fromJson(json['mission'] as Map<String, dynamic>),
  progress: MissionProgressEntity.fromJson(
    json['progress'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$MissionHistoryEntityToJson(
  _MissionHistoryEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'completedAt': instance.completedAt.toIso8601String(),
  'mission': instance.mission.toJson(),
  'progress': instance.progress.toJson(),
};
