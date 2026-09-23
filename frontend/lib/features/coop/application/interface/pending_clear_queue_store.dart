import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';

/// 共有しきれていない発見のキューの保存先 (キルされても消えないように端末に保存する)
abstract class IPendingClearQueueStore {
  /// 読み込む
  Future<PendingClearQueue> load();

  /// 保存する
  Future<void> save(PendingClearQueue queue);
}
