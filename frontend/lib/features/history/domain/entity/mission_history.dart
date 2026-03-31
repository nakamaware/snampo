import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';

part 'mission_history.freezed.dart';

/// ミッションの履歴
@freezed
abstract class MissionHistory with _$MissionHistory {
  /// [MissionHistory] を作成する
  const factory MissionHistory({
    required String id,
    required DateTime completedAt,
    required DateTime startedAt,
    @CoordinateConverter() required Coordinate departure,
    required String overviewPolyline,
    required List<MissionHistorySpot> spots,
    required MissionSettings settings,
  }) = _MissionHistory;
}
