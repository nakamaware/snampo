/// 位置情報エンティティ
class LocationEntity {
  /// LocationEntityのコンストラクタ
  LocationEntity({
    required this.departure,
    required this.destination,
    required this.midpoints,
    required this.overviewPolyline,
  });

  /// JSONからLocationEntityを生成する
  factory LocationEntity.fromJson(Map<String, dynamic> json) {
    return LocationEntity(
      departure: json['departure'] != null
          ? LocationPointEntity.fromJson(
              json['departure'] as Map<String, dynamic>,
            )
          : null,
      destination: json['destination'] != null
          ? MidPointEntity.fromJson(
              json['destination'] as Map<String, dynamic>,
            )
          : null,
      midpoints: (json['midpoints'] as List<dynamic>)
          .map((e) => MidPointEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      overviewPolyline: json['overviewPolyline'] as String?,
    );
  }

  /// 出発地点
  final LocationPointEntity? departure;

  /// 目的地
  final MidPointEntity? destination;

  /// 中間地点のリスト
  final List<MidPointEntity> midpoints;

  /// ルートのポリライン文字列
  final String? overviewPolyline;

  /// LocationEntityをJSONに変換する
  Map<String, dynamic> toJson() {
    return {
      'departure': departure?.toJson(),
      'destination': destination?.toJson(),
      'midpoints': midpoints.map((e) => e.toJson()).toList(),
      'overviewPolyline': overviewPolyline,
    };
  }
}

/// 位置ポイントエンティティ
class LocationPointEntity {
  /// LocationPointEntityのコンストラクタ
  LocationPointEntity({
    required this.latitude,
    required this.longitude,
  });

  /// JSONからLocationPointEntityを生成する
  factory LocationPointEntity.fromJson(Map<String, dynamic> json) {
    return LocationPointEntity(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// 緯度
  final double? latitude;

  /// 経度
  final double? longitude;

  /// LocationPointEntityをJSONに変換する
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
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

  /// JSONからMidPointEntityを生成する
  factory MidPointEntity.fromJson(Map<String, dynamic> json) {
    return MidPointEntity(
      imageLatitude: (json['imageLatitude'] as num?)?.toDouble(),
      imageLongitude: (json['imageLongitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUtf8: json['imageUtf8'] as String?,
    );
  }

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

  /// MidPointEntityをJSONに変換する
  Map<String, dynamic> toJson() {
    return {
      'imageLatitude': imageLatitude,
      'imageLongitude': imageLongitude,
      'latitude': latitude,
      'longitude': longitude,
      'imageUtf8': imageUtf8,
    };
  }
}
