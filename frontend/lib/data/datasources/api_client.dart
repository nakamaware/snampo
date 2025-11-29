import 'package:dio/dio.dart';
import 'package:snampo/core/config/env.dart';
import 'package:snampo/data/models/location_dto.dart';

/// APIクライアント
class ApiClient {
  /// ApiClientのコンストラクタ
  ApiClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// ルート情報を取得する
  ///
  /// [currentLat] は現在位置の緯度
  /// [currentLng] は現在位置の経度
  /// [radius] は検索半径（メートル単位）
  Future<LocationDto> getRoute({
    required double currentLat,
    required double currentLng,
    required String radius,
  }) async {
    final url = '${Env.apiBaseUrl}/route/';
    final response = await _dio.get<Map<String, dynamic>>(
      url,
      queryParameters: {
        'currentLat': currentLat.toString(),
        'currentLng': currentLng.toString(),
        'radius': radius,
      },
    );
    final jsonData = response.data!;
    return LocationDto.fromJson(jsonData);
  }
}
