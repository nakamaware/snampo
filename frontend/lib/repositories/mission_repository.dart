import 'package:snampo/config.dart';
import 'package:snampo/models/location_entity.dart';
import 'package:snampo_api/api.dart' as generated;

/// ミッションリポジトリ
class MissionRepository {
  /// MissionRepositoryのコンストラクタ
  MissionRepository({generated.DefaultApi? generatedApi})
      : _generatedApi = generatedApi ??
            generated.DefaultApi(
              generated.ApiClient(basePath: Env.apiBaseUrl),
            );

  final generated.DefaultApi _generatedApi;

  /// ミッション情報を取得する
  ///
  /// [radius] はミッションの検索半径（キロメートル単位）
  /// [currentLat] は現在位置の緯度
  /// [currentLng] は現在位置の経度
  Future<LocationEntity> getMission({
    required double radius,
    required double currentLat,
    required double currentLng,
  }) async {
    final radiusString =
        (radius * 1000).toInt().toString(); // km から m にし整数値の文字列に

    // 生成されたAPIクライアントを直接使用
    final response = await _generatedApi.routeRouteGet(
      currentLat.toString(),
      currentLng.toString(),
      radiusString,
    );

    if (response == null) {
      throw Exception('APIレスポンスがnullです');
    }

    return _toEntity(response);
  }

  /// RouteResponseをエンティティに変換
  LocationEntity _toEntity(generated.RouteResponse response) {
    return LocationEntity(
      departure: LocationPointEntity(
        latitude: response.departure.latitude.toDouble(),
        longitude: response.departure.longitude.toDouble(),
      ),
      destination: LocationPointEntity(
        latitude: response.destination.latitude.toDouble(),
        longitude: response.destination.longitude.toDouble(),
      ),
      midpoints: response.midpoints
          .map(
            (point) => MidPointEntity(
              imageLatitude: null, // APIレスポンスには画像情報が含まれていない
              imageLongitude: null,
              latitude: point.latitude.toDouble(),
              longitude: point.longitude.toDouble(),
              imageUtf8: null,
            ),
          )
          .toList(),
      overviewPolyline: response.overviewPolyline,
    );
  }
}
