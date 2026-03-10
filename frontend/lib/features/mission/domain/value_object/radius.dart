import 'package:freezed_annotation/freezed_annotation.dart';

part 'radius.freezed.dart';

/// [Radius] を JSON と相互変換するための [JsonConverter]。
///
/// MissionEntity で [Radius] を JSON シリアライズする際に使用する。復元時も公開 factory を通して
/// 500m〜10000m の範囲チェックを行うため、破損した保存データからの不正値は弾かれる。
class RadiusConverter implements JsonConverter<Radius, Map<String, dynamic>> {
  /// [RadiusConverter] を作成する
  const RadiusConverter();

  @override
  Radius fromJson(Map<String, dynamic> json) =>
      Radius(meters: json['meters'] as int);

  @override
  Map<String, dynamic> toJson(Radius object) => {'meters': object.meters};
}

/// 半径値オブジェクト
@freezed
abstract class Radius with _$Radius {
  /// 半径を作成する
  ///
  /// [meters] は半径（メートル単位、500から10000の範囲）
  ///
  /// 範囲外の値が渡された場合は[ArgumentError]をスローします
  factory Radius({required int meters}) {
    if (meters < 500 || meters > 10000) {
      throw ArgumentError.value(
        meters,
        'meters',
        '半径は500mから10000mの範囲である必要があります',
      );
    }
    return Radius.internal(meters: meters);
  }
  const Radius._();

  /// 内部コンストラクタ
  ///
  /// バリデーション済みの値でRadiusを作成します。
  /// このコンストラクタは外部から直接呼び出すべきではありません。
  const factory Radius.internal({required int meters}) = _Radius;
}
