import 'package:geolocator/geolocator.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';

/// 位置情報サービス
///
/// Geolocatorのラッパーサービス
class LocationService implements ILocationService {
  /// LocationServiceのコンストラクタ
  LocationService();

  /// 現在位置を取得する
  ///
  /// 高精度で現在位置を取得します
  @override
  Future<Coordinate> getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return Coordinate(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
