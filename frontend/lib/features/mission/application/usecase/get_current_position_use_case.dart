import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';

/// 現在位置を取得するユースケース
class GetCurrentPositionUseCase {
  /// GetCurrentPositionUseCaseのコンストラクタ
  ///
  /// [_locationService] は位置情報サービス
  GetCurrentPositionUseCase(this._locationService);

  final ILocationService _locationService;

  /// 現在位置を取得する
  ///
  /// 高精度で現在位置を取得します
  Future<Coordinate> call() async {
    return _locationService.getCurrentPosition();
  }
}
