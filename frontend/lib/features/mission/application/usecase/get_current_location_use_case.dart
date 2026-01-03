import 'package:geolocator/geolocator.dart';
import 'package:snampo/features/mission/data/location_service.dart';

/// 現在地を取得するユースケース
class GetCurrentLocationUseCase {
  /// GetCurrentLocationUseCaseのコンストラクタ
  ///
  /// [locationService] は位置情報サービス
  GetCurrentLocationUseCase(this._locationService);

  final LocationService _locationService;

  /// 現在位置を取得する
  ///
  /// 高精度で現在位置を取得します
  Future<Position> call() async {
    return _locationService.getCurrentPosition();
  }
}
