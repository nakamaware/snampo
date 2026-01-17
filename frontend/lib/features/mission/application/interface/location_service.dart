import 'package:snampo/features/mission/domain/value_object/coordinate.dart';

/// 位置情報サービスのインターフェース
///
/// 警告を抑制する理由:
/// - DIパターンでインターフェースとして使用されており、テスト時にモックに差し替えやすくするため
/// - 依存関係の逆転原則（DIP）に従い、アプリケーション層がデータ層の実装に依存しないようにするため
/// - 将来的にメソッドが追加される可能性があるため
// ignore: one_member_abstracts
abstract class ILocationService {
  /// 現在位置を取得する
  ///
  /// 高精度で現在位置を取得します
  Future<Coordinate> getCurrentPosition();
}
