import 'package:snampo/domain/entities/location_entity.dart';

/// ミッション情報を取得するリポジトリのインターフェース
abstract class MissionRepository {
  /// ミッション情報を取得する
  ///
  /// [radius] はミッションの検索半径（キロメートル単位）
  /// [currentLat] は現在位置の緯度
  /// [currentLng] は現在位置の経度
  Future<LocationEntity> getMission({
    required double radius,
    required double currentLat,
    required double currentLng,
  });
}
