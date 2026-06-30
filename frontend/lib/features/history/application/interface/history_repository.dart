import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

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
}
