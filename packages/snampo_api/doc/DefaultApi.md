# snampo_api.api.DefaultApi

## Load the API package
```dart
import 'package:snampo_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**routeRouteGet**](DefaultApi.md#routerouteget) | **GET** /route | Route


# **routeRouteGet**
> RouteResponse routeRouteGet(currentLat, currentLng, radius)

Route

ルートを生成  Args:     current_lat: 現在の緯度     current_lng: 現在の経度     radius: 半径 (メートル単位)     usecase: ルート生成ユースケース  Returns:     RouteResponse: ルート情報  Raises:     HTTPException: 外部サービスエラーが発生した場合、またはバリデーションエラーが発生した場合

### Example
```dart
import 'package:snampo_api/api.dart';

final api_instance = DefaultApi();
final currentLat = 35.6762; // num | 現在地の緯度
final currentLng = 139.6503; // num | 現在地の経度
final radius = 5000; // num | 目的地を生成する半径 (メートル単位)

try {
    final result = api_instance.routeRouteGet(currentLat, currentLng, radius);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->routeRouteGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **currentLat** | **num**| 現在地の緯度 | 
 **currentLng** | **num**| 現在地の経度 | 
 **radius** | **num**| 目的地を生成する半径 (メートル単位) | 

### Return type

[**RouteResponse**](RouteResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

