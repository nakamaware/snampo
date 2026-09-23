import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// 協力プレイでのチェックポイントの扱い
extension CoopCheckpoint on CheckpointProgress {
  /// 発見者の写真として表示するパス (null ならプレースホルダを表示する)
  ///
  /// - 自分が発見者なら自分の写真
  /// - 他の人が発見者なら、その人のサムネ。自分の写真 (先着に負けたもの) は使わない
  /// - 発見者がまだいなければ (自分のクリアが送信待ち) 自分の写真
  String? discovererPhotoPath({required String myUid}) =>
      switch (discovererUid) {
        null => userPhotoPath,
        final uid when uid == myUid => userPhotoPath ?? discovererThumbPath,
        _ => discovererThumbPath,
      };
}
