import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// ポリライン文字列をデコードして座標リストに変換する
List<LatLng> decodePolyline(String encodedPolyline) {
  final result = PolylinePoints().decodePolyline(encodedPolyline);
  return result
      .map((point) => LatLng(point.latitude, point.longitude))
      .toList();
}
