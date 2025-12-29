//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class DefaultApi {
  DefaultApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Route
  ///
  /// ルートを生成  Args:     current_lat: 現在の緯度     current_lng: 現在の経度     radius: 半径 (メートル単位)     usecase: ルート生成ユースケース  Returns:     RouteResponse: ルート情報  Raises:     HTTPException: 外部サービスエラーが発生した場合、またはバリデーションエラーが発生した場合
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [num] currentLat (required):
  ///   現在地の緯度
  ///
  /// * [num] currentLng (required):
  ///   現在地の経度
  ///
  /// * [num] radius (required):
  ///   目的地を生成する半径 (メートル単位)
  Future<Response> routeRouteGetWithHttpInfo(num currentLat, num currentLng, num radius,) async {
    // ignore: prefer_const_declarations
    final path = r'/route';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'currentLat', currentLat));
      queryParams.addAll(_queryParams('', 'currentLng', currentLng));
      queryParams.addAll(_queryParams('', 'radius', radius));

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Route
  ///
  /// ルートを生成  Args:     current_lat: 現在の緯度     current_lng: 現在の経度     radius: 半径 (メートル単位)     usecase: ルート生成ユースケース  Returns:     RouteResponse: ルート情報  Raises:     HTTPException: 外部サービスエラーが発生した場合、またはバリデーションエラーが発生した場合
  ///
  /// Parameters:
  ///
  /// * [num] currentLat (required):
  ///   現在地の緯度
  ///
  /// * [num] currentLng (required):
  ///   現在地の経度
  ///
  /// * [num] radius (required):
  ///   目的地を生成する半径 (メートル単位)
  Future<RouteResponse?> routeRouteGet(num currentLat, num currentLng, num radius,) async {
    final response = await routeRouteGetWithHttpInfo(currentLat, currentLng, radius,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RouteResponse',) as RouteResponse;
    
    }
    return null;
  }
}
