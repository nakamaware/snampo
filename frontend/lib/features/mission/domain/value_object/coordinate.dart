import 'package:freezed_annotation/freezed_annotation.dart';

part 'coordinate.freezed.dart';

/// 座標値オブジェクト
@freezed
abstract class Coordinate with _$Coordinate {
  /// 座標を作成する
  ///
  /// [latitude] は緯度（-90から90の範囲）
  /// [longitude] は経度（-180から180の範囲）
  ///
  /// 範囲外の値が渡された場合は[ArgumentError]をスローします
  factory Coordinate({
    required double latitude,
    required double longitude,
  }) {
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError.value(
        latitude,
        'latitude',
        '緯度は-90から90の範囲である必要があります',
      );
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError.value(
        longitude,
        'longitude',
        '経度は-180から180の範囲である必要があります',
      );
    }
    return Coordinate.internal(
      latitude: latitude,
      longitude: longitude,
    );
  }
  const Coordinate._();

  /// 内部コンストラクタ
  ///
  /// バリデーション済みの値でCoordinateを作成します。
  /// このコンストラクタは外部から直接呼び出すべきではありません。
  const factory Coordinate.internal({
    required double latitude,
    required double longitude,
  }) = _Coordinate;
}
