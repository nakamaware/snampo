// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coop_history_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoopHistoryMember _$CoopHistoryMemberFromJson(Map<String, dynamic> json) =>
    _CoopHistoryMember(
      uid: json['uid'] as String,
      nickname: json['nickname'] as String,
      namedAt:
          json['namedAt'] == null
              ? null
              : DateTime.parse(json['namedAt'] as String),
    );

Map<String, dynamic> _$CoopHistoryMemberToJson(_CoopHistoryMember instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'nickname': instance.nickname,
      'namedAt': instance.namedAt?.toIso8601String(),
    };
