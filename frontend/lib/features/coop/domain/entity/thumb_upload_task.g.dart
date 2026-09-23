// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thumb_upload_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThumbUploadTask _$ThumbUploadTaskFromJson(Map<String, dynamic> json) =>
    _ThumbUploadTask(
      roomCode: json['roomCode'] as String,
      spotId: json['spotId'] as String,
      localPath: json['localPath'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$ThumbUploadTaskToJson(_ThumbUploadTask instance) =>
    <String, dynamic>{
      'roomCode': instance.roomCode,
      'spotId': instance.spotId,
      'localPath': instance.localPath,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };

_ThumbUploadQueue _$ThumbUploadQueueFromJson(Map<String, dynamic> json) =>
    _ThumbUploadQueue(
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((e) => ThumbUploadTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ThumbUploadQueueToJson(_ThumbUploadQueue instance) =>
    <String, dynamic>{'tasks': _tasksToJson(instance.tasks)};
