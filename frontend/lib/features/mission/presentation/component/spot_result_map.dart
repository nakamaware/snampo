import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/util/map_overlay_util.dart';

/// スポット結果画面用マップ
///
/// スポット位置・撮影位置・撮影方向コーンをオーバーレイ表示する。
/// 撮影位置が取得できている場合は両点が収まるようにカメラを自動調整する。
class SpotResultMap extends StatefulWidget {
  /// [SpotResultMap] のコンストラクタ
  const SpotResultMap({
    required this.missionPoint,
    required this.checkpoint,
    super.key,
  });

  /// スポット情報
  final ImageCoordinate missionPoint;

  /// チェックポイントの進捗情報
  final CheckpointProgress checkpoint;

  @override
  State<SpotResultMap> createState() => _SpotResultMapState();
}

class _SpotResultMapState extends State<SpotResultMap> {
  GoogleMapController? _controller;
  BitmapDescriptor? _shotMarkerIcon;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shotMarkerIcon == null) {
      _initShotMarkerIcon();
    }
  }

  Future<void> _initShotMarkerIcon() async {
    final color = Theme.of(context).colorScheme.primary;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final icon = await _buildCircleIcon(color: color, pixelRatio: pixelRatio);
    if (mounted) {
      setState(() => _shotMarkerIcon = icon);
    }
  }

  /// [color] の塗り + 白リングのシンプルな丸マーカーアイコンを生成する
  static Future<BitmapDescriptor> _buildCircleIcon({
    required Color color,
    required double pixelRatio,
  }) async {
    const logicalSize = 24.0;
    final physicalSize = logicalSize * pixelRatio;
    final half = physicalSize / 2;
    final strokeWidth = 3.0 * pixelRatio;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(half, half);

    // 白リング
    canvas.drawCircle(
      center,
      half - strokeWidth / 2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    // カラー塗り
    canvas.drawCircle(center, half - strokeWidth, Paint()..color = color);

    final image = await recorder.endRecording().toImage(
      physicalSize.toInt(),
      physicalSize.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      imagePixelRatio: pixelRatio,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final spotLatLng = LatLng(
      widget.missionPoint.coordinate.latitude,
      widget.missionPoint.coordinate.longitude,
    );

    final guessPos = widget.checkpoint.guessPosition;
    final capturedHeading = widget.checkpoint.capturedHeading;

    final shotLatLng =
        guessPos != null ? LatLng(guessPos.latitude, guessPos.longitude) : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: spotLatLng, zoom: 16),
        onMapCreated: (controller) {
          _controller = controller;
          _onMapReady(spotLatLng, shotLatLng);
        },
        markers: _buildMarkers(spotLatLng, shotLatLng),
        polylines: _buildPolylines(spotLatLng, shotLatLng, cs),
        polygons: _buildPolygons(shotLatLng, capturedHeading),
        zoomControlsEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        rotateGesturesEnabled: true,
        myLocationButtonEnabled: false,
        compassEnabled: true,
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
        },
      ),
    );
  }

  Set<Marker> _buildMarkers(LatLng spotLatLng, LatLng? shotLatLng) {
    final landmarkName = widget.missionPoint.name ?? 'ランドマーク';
    final svLat = widget.missionPoint.streetViewLatitude;
    final svLng = widget.missionPoint.streetViewLongitude;
    final svLatLng =
        svLat != null && svLng != null ? LatLng(svLat, svLng) : null;

    return {
      // ランドマーク: 赤ピン + 名前 InfoWindow (タップで詳細表示)
      Marker(
        markerId: const MarkerId('landmark'),
        position: spotLatLng,
        infoWindow: InfoWindow(title: landmarkName),
      ),
      // ストリートビュー撮影位置: 黄色ピン
      if (svLatLng != null)
        Marker(
          markerId: const MarkerId('street_view'),
          position: svLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow,
          ),
          infoWindow: const InfoWindow(title: 'ストリートビュー位置'),
        ),
      // 撮影位置: テーマカラーの丸
      if (shotLatLng != null)
        Marker(
          markerId: const MarkerId('shot'),
          position: shotLatLng,
          icon:
              _shotMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: '撮影位置'),
        ),
    };
  }

  Set<Polyline> _buildPolylines(
    LatLng spotLatLng,
    LatLng? shotLatLng,
    ColorScheme cs,
  ) {
    if (shotLatLng == null) return {};
    return {
      Polyline(
        polylineId: const PolylineId('shot_to_spot'),
        points: [shotLatLng, spotLatLng],
        color: cs.primary.withValues(alpha: 0.5),
        width: 2,
        patterns: [PatternItem.dash(12), PatternItem.gap(6)],
      ),
    };
  }

  Set<Polygon> _buildPolygons(LatLng? shotLatLng, double? capturedHeading) {
    if (shotLatLng == null || capturedHeading == null) return {};
    return {
      Polygon(
        polygonId: const PolygonId('camera_fov'),
        points: buildHeadingCone(shotLatLng, capturedHeading),
        fillColor: Colors.orange.withValues(alpha: 0.25),
        strokeColor: Colors.orange.withValues(alpha: 0.7),
        strokeWidth: 1,
      ),
    };
  }

  /// マップ準備完了後の処理
  ///
  /// ランドマークの InfoWindow を開き、全マーカーが収まるようカメラを調整する。
  Future<void> _onMapReady(LatLng spotLatLng, LatLng? shotLatLng) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted || _controller == null) return;

    // ランドマーク InfoWindow を自動展開
    await _controller!.showMarkerInfoWindow(const MarkerId('landmark'));

    // 全マーカーが収まるようにカメラを調整
    final svLat = widget.missionPoint.streetViewLatitude;
    final svLng = widget.missionPoint.streetViewLongitude;
    final allPoints = [
      spotLatLng,
      if (shotLatLng != null) shotLatLng,
      if (svLat != null && svLng != null) LatLng(svLat, svLng),
    ];
    await _fitBoundsToPoints(allPoints);
  }

  /// 複数座標がすべて収まるようにカメラを調整する
  Future<void> _fitBoundsToPoints(List<LatLng> points) async {
    if (points.isEmpty || _controller == null) return;

    var swLat = points.first.latitude;
    var swLng = points.first.longitude;
    var neLat = points.first.latitude;
    var neLng = points.first.longitude;
    for (final p in points.skip(1)) {
      swLat = math.min(swLat, p.latitude);
      swLng = math.min(swLng, p.longitude);
      neLat = math.max(neLat, p.latitude);
      neLng = math.max(neLng, p.longitude);
    }

    // 零面積バウンズを防ぐ
    const minSpan = 0.001;
    final centerLat = (swLat + neLat) / 2;
    final centerLng = (swLng + neLng) / 2;
    final halfLat = math.max((neLat - swLat) / 2, minSpan / 2);
    final halfLng = math.max((neLng - swLng) / 2, minSpan / 2);

    final bounds = LatLngBounds(
      southwest: LatLng(centerLat - halfLat, centerLng - halfLng),
      northeast: LatLng(centerLat + halfLat, centerLng + halfLng),
    );
    await _controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }
}
