import 'package:snampo/config.dart';
import 'package:snampo/features/mission/application/interface/mission_repository.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';
import 'package:snampo_api/api.dart' as snampo_api;

/// ミッションリポジトリ
class MissionRepository implements IMissionRepository {
  /// MissionRepositoryのコンストラクタ
  MissionRepository({snampo_api.DefaultApi? generatedApi})
    : _generatedApi =
          generatedApi ??
          snampo_api.DefaultApi(snampo_api.ApiClient(basePath: Env.apiBaseUrl));

  final snampo_api.DefaultApi _generatedApi;

  /// ランダムモードでミッション情報を取得する
  ///
  /// [currentLocation] は現在位置の座標
  /// [radius] はミッションの検索半径
  @override
  Future<MissionEntity> createRandomMission({
    required Coordinate currentLocation,
    required Radius radius,
  }) async {
    // リクエストボディを作成
    final request = snampo_api.Request(
      currentLat: currentLocation.latitude,
      currentLng: currentLocation.longitude,
      mode: 'random',
      radius: radius.meters,
      destinationLat: null,
      destinationLng: null,
    );

    final response = await _generatedApi.routeRoutePost(request);

    if (response == null) {
      throw Exception('APIレスポンスがnullです');
    }

    return _toEntity(response, radius);
  }

  /// 目的地指定モードでミッション情報を取得する
  ///
  /// [currentLocation] は現在位置の座標
  /// [destination] は目的地の座標
  @override
  Future<MissionEntity> createDestinationMission({
    required Coordinate currentLocation,
    required Coordinate destination,
  }) async {
    // リクエストボディを作成
    final request = snampo_api.Request(
      currentLat: currentLocation.latitude,
      currentLng: currentLocation.longitude,
      mode: 'destination',
      radius: null,
      destinationLat: destination.latitude,
      destinationLng: destination.longitude,
    );

    final response = await _generatedApi.routeRoutePost(request);

    if (response == null) {
      throw Exception('APIレスポンスがnullです');
    }

    return _toEntity(response, null);
  }

  /// RouteResponseをエンティティに変換
  MissionEntity _toEntity(snampo_api.RouteResponse response, Radius? radius) {
    // 必須フィールドのnullチェック
    if (response.overviewPolyline.isEmpty) {
      throw Exception('ルート情報が取得できませんでした');
    }

    // imageUtf8のnullチェック（ImageCoordinateのimageBase64は必須のため）
    if (response.destination.imageUtf8 == null ||
        response.destination.imageUtf8!.isEmpty) {
      throw Exception('目的地の画像情報が取得できませんでした');
    }

    return MissionEntity(
      departure: Coordinate(
        latitude: response.departure.latitude.toDouble(),
        longitude: response.departure.longitude.toDouble(),
      ),
      destination: ImageCoordinate(
        coordinate: Coordinate(
          latitude: response.destination.latitude.toDouble(),
          longitude: response.destination.longitude.toDouble(),
        ),
        imageBase64: response.destination.imageUtf8!,
      ),
      waypoints:
          response.midpoints.map((midpoint) {
            // waypointsのimageUtf8もnullチェック
            if (midpoint.imageUtf8 == null || midpoint.imageUtf8!.isEmpty) {
              throw Exception('通過地点の画像情報が取得できませんでした');
            }
            return ImageCoordinate(
              coordinate: Coordinate(
                latitude: midpoint.latitude.toDouble(),
                longitude: midpoint.longitude.toDouble(),
              ),
              imageBase64: midpoint.imageUtf8!,
            );
          }).toList(),
      overviewPolyline: response.overviewPolyline,
      radius: radius,
    );
  }
}
