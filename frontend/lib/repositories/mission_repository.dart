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
    final radiusInMeters = radius * 1000; // km から m に変換

    // リクエストボディを作成
    final request = generated.RouteRequest(
      currentLat: currentLat,
      currentLng: currentLng,
      radius: radiusInMeters,
    );

    // 生成されたAPIクライアントを直接使用
    final response = await _generatedApi.routeRoutePost(request);

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
      destination: MidPointEntity(
        imageLatitude: response.destination.imageLatitude?.toDouble(),
        imageLongitude: response.destination.imageLongitude?.toDouble(),
        latitude: response.destination.latitude.toDouble(),
        longitude: response.destination.longitude.toDouble(),
        imageUtf8: response.destination.imageUtf8,
      ),
      midpoints: response.midpoints
          .map(
            (midpoint) => MidPointEntity(
              imageLatitude: midpoint.imageLatitude?.toDouble(),
              imageLongitude: midpoint.imageLongitude?.toDouble(),
              latitude: midpoint.latitude.toDouble(),
              longitude: midpoint.longitude.toDouble(),
              imageUtf8: midpoint.imageUtf8,
            ),
          )
          .toList(),
      overviewPolyline: response.overviewPolyline,
    );
  }
}
