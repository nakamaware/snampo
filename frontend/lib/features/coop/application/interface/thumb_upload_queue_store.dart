import 'package:snampo/features/coop/domain/entity/thumb_upload_task.dart';

/// サムネの再送キューの保存先 (キルされても消えないように端末に保存する)
abstract class IThumbUploadQueueStore {
  /// 読み込む
  Future<ThumbUploadQueue> load();

  /// 保存する
  Future<void> save(ThumbUploadQueue queue);
}
