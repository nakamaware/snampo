import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';
import 'package:snampo/core/storage/mission_photo_directory.dart';
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
  /// [photoDirectory] は保存先 (ソロと協力プレイで分ける)
  Future<CheckpointProgress> call({
    required String tempPhotoPath,
    required int checkpointIndex,
    required MissionPhotoDirectory photoDirectory,
    required Coordinate? guessPosition,
    required double? capturedHeading,
    required PhotoJudgeRank judgeRank,
    required double distanceErrorMeters,
    required double? headingErrorDegrees,
    required double zoomLevel,
  }) async {
    final savedPath = await _photoStorage.savePhoto(
      tempPhotoPath,
      checkpointIndex,
      directory: photoDirectory,
    );
    return CheckpointProgress(
      guessPosition: guessPosition,
      userPhotoPath: savedPath,
      capturedHeading: capturedHeading,
      distanceErrorMeters: distanceErrorMeters,
      headingErrorDegrees: headingErrorDegrees,
      judgeRank: judgeRank,
      zoomLevel: zoomLevel,
      achievedAt: DateTime.now(),
    );
  }
}
