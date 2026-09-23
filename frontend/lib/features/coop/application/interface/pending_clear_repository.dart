import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';

/// 共有しきれていない発見のキューの保存先 (キルされても消えないように端末に保存する)
abstract class IPendingClearRepository {
  /// 読み込む
  Future<PendingClearQueue> load();

  /// 読み込んだキューに [change] を適用して保存し、保存したキューを返す
  ///
  /// 更新は 1 つずつ順番に行う (撮影と送り直しが重なっても、どちらの変更も失われないように)。
  Future<PendingClearQueue> update(
    PendingClearQueue Function(PendingClearQueue queue) change,
  );
}
