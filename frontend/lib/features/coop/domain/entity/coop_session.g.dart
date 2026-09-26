// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coop_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoopSession _$CoopSessionFromJson(Map<String, dynamic> json) => _CoopSession(
  roomCode: const RoomCodeConverter().fromJson(json['roomCode'] as String),
  uid: json['uid'] as String,
);

Map<String, dynamic> _$CoopSessionToJson(_CoopSession instance) =>
    <String, dynamic>{
      'roomCode': const RoomCodeConverter().toJson(instance.roomCode),
      'uid': instance.uid,
    };
