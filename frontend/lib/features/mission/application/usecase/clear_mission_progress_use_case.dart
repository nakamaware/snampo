import 'package:snampo/core/storage/photo_storage.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// ミッション進捗に紐づくユーザー写真をストレージから削除する
class ClearMissionProgressUseCase {
  /// [ClearMissionProgressUseCase] を作成する
  ClearMissionProgressUseCase(this._photoStorage);

  final IPhotoStorage _photoStorage;

  /// [progress] の各チェックポイントで保存済みの写真ファイルを削除する
  ///
  /// いずれか 1 件の削除が失敗しても残りの削除を続ける。
  Future<void> call(MissionProgressEntity progress) async {
    for (final cp in progress.checkpoints) {
      if (cp?.userPhotoPath != null) {
        try {
          await _photoStorage.deletePhoto(cp!.userPhotoPath!);
        } on Object {
          // 1 件の削除失敗でループを止めない
        }
      }
    }
  }
}
