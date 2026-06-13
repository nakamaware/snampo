import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';

part 'image_coordinate.freezed.dart';
part 'image_coordinate.g.dart';

/// 画像付き座標値オブジェクト
@freezed
abstract class ImageCoordinate with _$ImageCoordinate {
  /// 画像付き座標を作成する
  ///
  /// [coordinate] は座標情報
  /// [imageBase64] はBase64エンコードされた画像データ
  const factory ImageCoordinate({
    /// 座標
    @CoordinateConverter() required Coordinate coordinate,

    /// Base64エンコードされた画像データ
    required String imageBase64,

    /// 正解画像の基準方角
    double? referenceHeading,

    /// 表示名
    String? name,

    /// ジャンル
    String? genre,

    /// Google Maps の詳細URL
    String? googleMapsUrl,
  }) = _ImageCoordinate;

  /// JSON から [ImageCoordinate] を生成する
  factory ImageCoordinate.fromJson(Map<String, dynamic> json) =>
      _$ImageCoordinateFromJson(json);
}
