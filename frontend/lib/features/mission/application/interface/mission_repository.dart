import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

/// ミッションリポジトリのインターフェース
///
/// 警告を抑制する理由:
/// - DIパターンでインターフェースとして使用されており、テスト時にモックに差し替えやすくするため
/// - 依存関係の逆転原則（DIP）に従い、アプリケーション層がデータ層の実装に依存しないようにするため
abstract class IMissionRepository {
  /// ランダムモードでミッション情報を取得する
  ///
  /// [currentLocation] は現在位置の座標
  /// [radius] はミッションの検索半径
  Future<MissionEntity> createRandomMission({
    required Coordinate currentLocation,
    required Radius radius,
  });

  /// 目的地指定モードでミッション情報を取得する
  ///
  /// [currentLocation] は現在位置の座標
  /// [destination] は目的地の座標
  Future<MissionEntity> createDestinationMission({
    required Coordinate currentLocation,
    required Coordinate destination,
  });
}
