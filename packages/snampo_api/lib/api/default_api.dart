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

  /// Get Street View Image
  ///
  /// Street View Image Metadata APIを使用して画像のメタデータを取得  Args:     latitude: 緯度     longitude: 経度     size: 画像サイズ  Returns:     dict: メタデータ
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [num] latitude (required):
  ///
  /// * [num] longitude (required):
  ///
  /// * [String] size:
  Future<Response> getStreetViewImageStreetviewGetWithHttpInfo(num latitude, num longitude, { String? size, }) async {
    // ignore: prefer_const_declarations
    final path = r'/streetview';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

      queryParams.addAll(_queryParams('', 'latitude', latitude));
      queryParams.addAll(_queryParams('', 'longitude', longitude));
    if (size != null) {
      queryParams.addAll(_queryParams('', 'size', size));
    }

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

  /// Get Street View Image
  ///
  /// Street View Image Metadata APIを使用して画像のメタデータを取得  Args:     latitude: 緯度     longitude: 経度     size: 画像サイズ  Returns:     dict: メタデータ
  ///
  /// Parameters:
  ///
  /// * [num] latitude (required):
  ///
  /// * [num] longitude (required):
  ///
  /// * [String] size:
  Future<Map<String, Object>?> getStreetViewImageStreetviewGet(num latitude, num longitude, { String? size, }) async {
    final response = await getStreetViewImageStreetviewGetWithHttpInfo(latitude, longitude,  size: size, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return Map<String, Object>.from(await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Map<String, Object>'),);

    }
    return null;
  }

  /// Route
  ///
  /// ルートを生成  Args:     current_lat: 現在の緯度     current_lng: 現在の経度     radius: 半径  Returns:     RouteResponse: ルート情報
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] currentLat (required):
  ///
  /// * [String] currentLng (required):
  ///
  /// * [String] radius (required):
  Future<Response> routeRouteGetWithHttpInfo(String currentLat, String currentLng, String radius,) async {
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
  /// ルートを生成  Args:     current_lat: 現在の緯度     current_lng: 現在の経度     radius: 半径  Returns:     RouteResponse: ルート情報
  ///
  /// Parameters:
  ///
  /// * [String] currentLat (required):
  ///
  /// * [String] currentLng (required):
  ///
  /// * [String] radius (required):
  Future<RouteResponse?> routeRouteGet(String currentLat, String currentLng, String radius,) async {
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
