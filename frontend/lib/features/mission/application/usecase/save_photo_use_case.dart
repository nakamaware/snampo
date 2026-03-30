import 'package:snampo/core/storage/photo_storage.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// 写真を永続保存するユースケース
class SavePhotoUseCase {
  /// [SavePhotoUseCase] を作成する
  SavePhotoUseCase(this._photoStorage);

  final IPhotoStorage _photoStorage;

  /// 撮影した写真を永続保存し、CheckpointProgress を返す
  ///
  /// [tempPhotoPath] は一時ディレクトリの写真パス
  /// [checkpointIndex] はチェックポイントのインデックス
  Future<CheckpointProgress> call({
    required String tempPhotoPath,
    required int checkpointIndex,
  }) async {
    final savedPath = await _photoStorage.savePhoto(
      tempPhotoPath,
      checkpointIndex,
    );
    return CheckpointProgress(
      userPhotoPath: savedPath,
      achievedAt: DateTime.now(),
    );
  }
}
