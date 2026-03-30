// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_persisted_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HistoryPersistedState _$HistoryPersistedStateFromJson(
  Map<String, dynamic> json,
) => _HistoryPersistedState(
  records:
      (json['records'] as List<dynamic>?)
          ?.map((e) => MissionHistoryEntity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <MissionHistoryEntity>[],
);

Map<String, dynamic> _$HistoryPersistedStateToJson(
  _HistoryPersistedState instance,
) => <String, dynamic>{
  'records': instance.records.map((e) => e.toJson()).toList(),
};
