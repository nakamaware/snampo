/// 方角取得サービスのインターフェース
// ignore: one_member_abstracts
abstract class IHeadingService {
  /// 現在の方角を取得する
  Future<double?> getCurrentHeading();
}
