import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

/// ポリラインから距離を計算するユーティリティ
class DistanceCalculator {
  /// ポリライン文字列から総距離 (メートル単位) を計算する
  ///
  /// [polyline] はエンコードされたポリライン文字列
  /// ポリラインが null または空の場合は 0.0 を返す
  static double calculateDistanceFromPolyline(String? polyline) {
    if (polyline == null || polyline.isEmpty) {
      return 0;
    }

    try {
      final points = PolylinePoints().decodePolyline(polyline);
      if (points.isEmpty) {
        return 0;
      }

      var totalDistance = 0.0;
      for (var i = 0; i < points.length - 1; i++) {
        totalDistance += _haversineDistance(
          points[i].latitude,
          points[i].longitude,
          points[i + 1].latitude,
          points[i + 1].longitude,
        );
      }

      return totalDistance;
    } catch (e) {
      log('DistanceCalculator error: $e', name: 'DistanceCalculator');
      return 0;
    }
  }

  /// Haversine公式を使用して2点間の距離を計算する (メートル単位)
  ///
  /// [lat1] は地点1の緯度
  /// [lon1] は地点1の経度
  /// [lat2] は地点2の緯度
  /// [lon2] は地点2の経度
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // 地球の半径 (メートル)

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  /// 度をラジアンに変換する
  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}
