# snampo_api.api.DefaultApi

## Load the API package
```dart
import 'package:snampo_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**routeRoutePost**](DefaultApi.md#routeroutepost) | **POST** /route | Route


# **routeRoutePost**
> RouteResponse routeRoutePost(request)

Route

ルートを生成  Args:     request: ルート生成リクエスト(現在地の緯度・経度、半径または目的地座標を含む)     usecase: ルート生成ユースケース  Returns:     RouteResponse: ルート情報  Raises:     HTTPException: 外部サービスエラーが発生した場合、またはバリデーションエラーが発生した場合

### Example
```dart
import 'package:snampo_api/api.dart';

final api_instance = DefaultApi();
final request = Request(); // Request | 

try {
    final result = api_instance.routeRoutePost(request);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->routeRoutePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **request** | [**Request**](Request.md)|  | 

### Return type

[**RouteResponse**](RouteResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

