import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 撮影方向の視野角コーンを構成する [LatLng] リストを生成する
///
/// 扇形の頂点を [origin]、中心方位を [headingDegrees]、
/// 開き角を [fovDegrees]、半径を [radiusMeters] として
/// 閉じた多角形の座標列を返す。
List<LatLng> buildHeadingCone(
  LatLng origin,
  double headingDegrees, {
  double fovDegrees = 60.0,
  double radiusMeters = 80.0,
}) {
  const steps = 20;
  final halfFov = fovDegrees / 2;
  final points = <LatLng>[origin];
  for (var i = 0; i <= steps; i++) {
    final bearing = headingDegrees - halfFov + fovDegrees * i / steps;
    points.add(_destinationPoint(origin, bearing, radiusMeters));
  }
  points.add(origin);
  return points;
}

/// 球面三角法に基づき、[origin] から [bearingDeg] 方位に [distMeters] 進んだ座標を返す
LatLng _destinationPoint(LatLng origin, double bearingDeg, double distMeters) {
  const earthRadius = 6371000.0;
  final lat1 = origin.latitude * math.pi / 180;
  final lon1 = origin.longitude * math.pi / 180;
  final brng = bearingDeg * math.pi / 180;
  final d = distMeters / earthRadius;

  final lat2 = math.asin(
    math.sin(lat1) * math.cos(d) +
        math.cos(lat1) * math.sin(d) * math.cos(brng),
  );
  final lon2 =
      lon1 +
      math.atan2(
        math.sin(brng) * math.sin(d) * math.cos(lat1),
        math.cos(d) - math.sin(lat1) * math.sin(lat2),
      );
  return LatLng(lat2 * 180 / math.pi, lon2 * 180 / math.pi);
}
