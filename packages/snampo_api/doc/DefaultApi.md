# snampo_api.api.DefaultApi

## Load the API package
```dart
import 'package:snampo_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getStreetViewImageStreetviewGet**](DefaultApi.md#getstreetviewimagestreetviewget) | **GET** /streetview | Get Street View Image
[**routeRoutePost**](DefaultApi.md#routeroutepost) | **POST** /route | Route


# **getStreetViewImageStreetviewGet**
> StreetViewImageResponse getStreetViewImageStreetviewGet(latitude, longitude, size)

Get Street View Image

Street View Image Metadata APIを使用して画像のメタデータを取得  Args:     latitude: 緯度     longitude: 経度     size: 画像サイズ  Returns:     StreetViewImageResponse: メタデータと画像データ

### Example
```dart
import 'package:snampo_api/api.dart';

final api_instance = DefaultApi();
final latitude = 35.6762; // num | 緯度
final longitude = 139.6503; // num | 経度
final size = 600x300; // String | 画像サイズ

try {
    final result = api_instance.getStreetViewImageStreetviewGet(latitude, longitude, size);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->getStreetViewImageStreetviewGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **latitude** | **num**| 緯度 | 
 **longitude** | **num**| 経度 | 
 **size** | **String**| 画像サイズ | [optional] [default to '600x300']

### Return type

[**StreetViewImageResponse**](StreetViewImageResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **routeRoutePost**
> RouteResponse routeRoutePost(routeRequest)

Route

ルートを生成  Args:     request: ルート生成リクエスト(現在地の緯度・経度、半径を含む)  Returns:     RouteResponse: ルート情報

### Example
```dart
import 'package:snampo_api/api.dart';

final api_instance = DefaultApi();
final routeRequest = RouteRequest(); // RouteRequest | 

try {
    final result = api_instance.routeRoutePost(routeRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->routeRoutePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **routeRequest** | [**RouteRequest**](RouteRequest.md)|  | 

### Return type

[**RouteResponse**](RouteResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

