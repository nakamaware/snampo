import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/value_object/photo_judgement.dart';

/// 履歴の永続化 (アプリケーション層から見たポート)
abstract class IHistoryRepository {
  /// 新しい履歴を保存する
  Future<void> insertHistory({
    required String id,
    required MissionEntity mission,
    required MissionProgressEntity progress,
  });

  /// 履歴と紐づくユーザー写真・Street View ファイル・DB 行を削除する
  Future<void> deleteHistory(String id);

  /// 履歴一覧 (完了日時の新しい順)
  Future<List<MissionHistory>> getHistories({int? limit, int offset = 0});

  /// id で 1 件取得
  Future<MissionHistory?> getHistoryById(String id);

  /// 協力プレイの履歴を「進行中」として作成する (roomCode をキーに upsert)
  ///
  /// 既にあれば、メンバー一覧だけを更新する。ミッション画像はこの時点ですべて端末に保存する。
  Future<void> upsertCoopHistory({
    required MissionEntity mission,
    required DateTime startedAt,
    required CoopHistoryInfo coop,
  });

  /// roomCode で協力プレイの履歴を 1 件取得する
  Future<MissionHistory?> getCoopHistory(RoomCode roomCode);

  /// スポットの発見者と、その採点を反映し、クリア済みにする
  ///
  /// 発見者が変わった場合は、前の発見者のサムネを外す。
  Future<void> applyCoopDiscoverer({
    required RoomCode roomCode,
    required SpotId spotId,
    required String discovererUid,
    required String discovererNickname,
    required DateTime clearedAt,
    required PhotoJudgement? judgement,
  });

  /// 発見者のサムネを履歴の保存先にコピーして反映する
  Future<void> saveCoopThumb({
    required RoomCode roomCode,
    required SpotId spotId,
    required String sourcePath,
  });

  /// 自分が撮影した写真と採点を反映する (先に他の人が発見していても手元に残す)
  Future<void> saveCoopUserPhoto({
    required RoomCode roomCode,
    required SpotId spotId,
    required CheckpointProgress checkpoint,
  });

  /// 協力プレイの履歴を「確定」にする (以後は同期しない)
  Future<void> finalizeCoopHistory(
    RoomCode roomCode, {
    required DateTime completedAt,
  });

  /// 進行中 (未確定) の協力プレイの履歴
  Future<List<MissionHistory>> getInProgressCoopHistories();
}
