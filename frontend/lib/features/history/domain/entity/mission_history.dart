import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';

part 'mission_history.freezed.dart';

/// ミッションの履歴
@freezed
abstract class MissionHistory with _$MissionHistory {
  /// [MissionHistory] を作成する
  const factory MissionHistory({
    required String id,
    required DateTime completedAt,
    required DateTime startedAt,
    required Coordinate departure,
    required String overviewPolyline,
    required List<MissionHistorySpot> spots,
    required MissionSettings settings,

    /// 協力プレイの情報 (ソロでは null)
    CoopHistoryInfo? coop,
  }) = _MissionHistory;

  const MissionHistory._();

  /// 遊んだときのセッション種別 (協力プレイの情報があれば協力プレイ)
  MissionSessionKind get sessionKind =>
      coop == null ? MissionSessionKind.solo : MissionSessionKind.coop;

  /// 遊び終わった時刻 (遊んだ時間の計算に使う)
  ///
  /// 協力プレイの途中の履歴は、終わった時刻 ([completedAt]) がまだ
  /// 始めた時刻と同じなので、最後に発見した時刻を使う。発見がなければ null。
  DateTime? get playEndedAt {
    if (completedAt.isAfter(startedAt)) return completedAt;
    final achieved = [
      for (final spot in spots)
        if (spot.achievedAt case final at?) at,
    ];
    return achieved.isEmpty
        ? null
        : achieved.reduce((a, b) => a.isAfter(b) ? a : b);
  }
}
