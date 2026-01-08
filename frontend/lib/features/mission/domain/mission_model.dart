import 'package:freezed_annotation/freezed_annotation.dart';

part 'mission_model.freezed.dart';

/// 位置情報エンティティ
@freezed
abstract class LocationEntity with _$LocationEntity {
  /// LocationEntityのコンストラクタ
  const factory LocationEntity({
    /// 出発地点
    LocationPointEntity? departure,

    /// 目的地
    MidPointEntity? destination,

    /// 中間地点のリスト
    @Default([]) List<MidPointEntity> midpoints,

    /// ルートのポリライン文字列
    String? overviewPolyline,
  }) = _LocationEntity;
}

/// 位置ポイントエンティティ
@freezed
abstract class LocationPointEntity with _$LocationPointEntity {
  /// LocationPointEntityのコンストラクタ
  const factory LocationPointEntity({
    /// 緯度
    double? latitude,

    /// 経度
    double? longitude,
  }) = _LocationPointEntity;
}

/// 中間ポイントエンティティ
@freezed
abstract class MidPointEntity with _$MidPointEntity {
  /// MidPointEntityのコンストラクタ
  const factory MidPointEntity({
    /// 画像のメタデータ緯度
    double? imageLatitude,

    /// 画像のメタデータ経度
    double? imageLongitude,

    /// 元の緯度
    double? latitude,

    /// 元の経度
    double? longitude,

    /// Base64エンコードされた画像データ
    String? imageUtf8,
  }) = _MidPointEntity;
}
