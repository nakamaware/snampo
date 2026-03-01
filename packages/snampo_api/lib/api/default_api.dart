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
  /// ルートを生成  Args:     request: ルート生成リクエスト(現在地の緯度・経度、半径または目的地座標を含む)     usecase: ルート生成ユースケース  Returns:     RouteResponse: ルート情報  Raises:     HTTPException: 外部サービスエラーが発生した場合、またはバリデーションエラーが発生した場合
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [Request] request (required):
  Future<Response> routeRoutePostWithHttpInfo(Request request,) async {
    // ignore: prefer_const_declarations
    final path = r'/route';

    // ignore: prefer_final_locals
    Object? postBody = request;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Route
  ///
  /// ルートを生成  Args:     request: ルート生成リクエスト(現在地の緯度・経度、半径または目的地座標を含む)     usecase: ルート生成ユースケース  Returns:     RouteResponse: ルート情報  Raises:     HTTPException: 外部サービスエラーが発生した場合、またはバリデーションエラーが発生した場合
  ///
  /// Parameters:
  ///
  /// * [Request] request (required):
  Future<RouteResponse?> routeRoutePost(Request request,) async {
    final response = await routeRoutePostWithHttpInfo(request,);
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
