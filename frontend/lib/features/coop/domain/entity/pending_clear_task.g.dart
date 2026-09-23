// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_clear_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PendingClearTask _$PendingClearTaskFromJson(Map<String, dynamic> json) =>
    _PendingClearTask(
      roomCode: json['roomCode'] as String,
      spotId: json['spotId'] as String,
      nickname: json['nickname'] as String,
      localThumbPath: json['localThumbPath'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      clearCreated: json['clearCreated'] as bool? ?? false,
    );

Map<String, dynamic> _$PendingClearTaskToJson(_PendingClearTask instance) =>
    <String, dynamic>{
      'roomCode': instance.roomCode,
      'spotId': instance.spotId,
      'nickname': instance.nickname,
      'localThumbPath': instance.localThumbPath,
      'expiresAt': instance.expiresAt.toIso8601String(),
      'clearCreated': instance.clearCreated,
    };

_PendingClearQueue _$PendingClearQueueFromJson(Map<String, dynamic> json) =>
    _PendingClearQueue(
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((e) => PendingClearTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PendingClearQueueToJson(_PendingClearQueue instance) =>
    <String, dynamic>{'tasks': _tasksToJson(instance.tasks)};
