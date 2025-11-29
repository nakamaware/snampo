# snampo_api.api.DefaultApi

## Load the API package
```dart
import 'package:snampo_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getStreetViewImageStreetviewGet**](DefaultApi.md#getstreetviewimagestreetviewget) | **GET** /streetview | Get Street View Image
[**routeRouteGet**](DefaultApi.md#routerouteget) | **GET** /route | Route


# **getStreetViewImageStreetviewGet**
> Map<String, Object> getStreetViewImageStreetviewGet(latitude, longitude, size)

Get Street View Image

Street View Image Metadata APIを使用して画像のメタデータを取得  Args:     latitude: 緯度     longitude: 経度     size: 画像サイズ  Returns:     dict: メタデータ

### Example
```dart
import 'package:snampo_api/api.dart';

final api_instance = DefaultApi();
final latitude = 8.14; // num |
final longitude = 8.14; // num |
final size = size_example; // String |

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
 **latitude** | **num**|  |
 **longitude** | **num**|  |
 **size** | **String**|  | [optional]

### Return type

[**Map<String, Object>**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **routeRouteGet**
> RouteResponse routeRouteGet(currentLat, currentLng, radius)

Route

ルートを生成  Args:     current_lat: 現在の緯度     current_lng: 現在の経度     radius: 半径  Returns:     RouteResponse: ルート情報

### Example
```dart
import 'package:snampo_api/api.dart';

final api_instance = DefaultApi();
final currentLat = currentLat_example; // String |
final currentLng = currentLng_example; // String |
final radius = radius_example; // String |

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
 **currentLat** | **String**|  |
 **currentLng** | **String**|  |
 **radius** | **String**|  |

### Return type

[**RouteResponse**](RouteResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)
