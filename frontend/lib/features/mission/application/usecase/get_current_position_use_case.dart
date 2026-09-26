import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';

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
