import 'package:freezed_annotation/freezed_annotation.dart';

part 'radius.freezed.dart';

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
