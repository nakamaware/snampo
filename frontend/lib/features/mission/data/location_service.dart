import 'package:geolocator/geolocator.dart';

/// 位置情報サービス
///
/// Geolocatorのラッパーサービス
class LocationService {
  /// LocationServiceのコンストラクタ
  LocationService();

  /// 現在位置を取得する
  ///
  /// 高精度で現在位置を取得します
  Future<Position> getCurrentPosition() async {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
