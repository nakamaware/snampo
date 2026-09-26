import 'package:geolocator/geolocator.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';

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
    final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } on LocationServiceDisabledException catch (e) {
      // Android で「位置情報の精度」の確認を断った場合もここに来る
      throw LocationUnavailableException(e.toString());
    } on PermissionDeniedException catch (e) {
      throw LocationUnavailableException(e.toString());
    }
    return Coordinate(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
