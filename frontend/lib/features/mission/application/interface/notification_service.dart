/// プッシュ通知・ローカル通知サービスの抽象インターフェース
abstract class INotificationService {
  /// 通知プラグインの初期化
  Future<void> initialize();

  /// スポット離脱警告通知を表示する
  Future<void> showDepartureAlert({
    required int id,
    required String title,
    required String body,
  });

  /// 指定IDの通知をキャンセルする
  Future<void> cancel(int id);
}
