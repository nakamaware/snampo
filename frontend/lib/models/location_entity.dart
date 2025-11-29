/// 位置情報エンティティ
class LocationEntity {
  /// LocationEntityのコンストラクタ
  LocationEntity({
    required this.departure,
    required this.destination,
    required this.midpoints,
    required this.overviewPolyline,
  });

  /// 出発地点
  final LocationPointEntity? departure;

  /// 目的地
  final LocationPointEntity? destination;

  /// 中間地点のリスト
  final List<MidPointEntity> midpoints;

  /// ルートのポリライン文字列
  final String? overviewPolyline;
}

/// 位置ポイントエンティティ
class LocationPointEntity {
  /// LocationPointEntityのコンストラクタ
  LocationPointEntity({
    required this.latitude,
    required this.longitude,
  });

  /// 緯度
  final double? latitude;

  /// 経度
  final double? longitude;
}

/// 中間ポイントエンティティ
class MidPointEntity {
  /// MidPointEntityのコンストラクタ
  MidPointEntity({
    required this.imageLatitude,
    required this.imageLongitude,
    required this.latitude,
    required this.longitude,
    required this.imageUtf8,
  });

  /// 画像のメタデータ緯度
  final double? imageLatitude;

  /// 画像のメタデータ経度
  final double? imageLongitude;

  /// 元の緯度
  final double? latitude;

  /// 元の経度
  final double? longitude;

  /// Base64エンコードされた画像データ
  final String? imageUtf8;
}
