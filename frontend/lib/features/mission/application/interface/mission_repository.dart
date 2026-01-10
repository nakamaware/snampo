import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

/// ミッションリポジトリのインターフェース
///
/// 警告を抑制する理由:
/// - DIパターンでインターフェースとして使用されており、テスト時にモックに差し替えやすくするため
/// - 依存関係の逆転原則（DIP）に従い、アプリケーション層がデータ層の実装に依存しないようにするため
/// - 将来的にメソッドが追加される可能性があるため
// ignore: one_member_abstracts
abstract class IMissionRepository {
  /// ミッション情報を取得する
  ///
  /// [radius] はミッションの検索半径
  /// [currentLocation] は現在位置の座標
  Future<MissionEntity> getMission({
    required Radius radius,
    required Coordinate currentLocation,
  });
}
