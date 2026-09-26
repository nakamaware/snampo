import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';
import 'package:snampo/features/mission/presentation/component/judge_rank_badge.dart';
import 'package:snampo/features/mission/presentation/component/map_top_bar.dart';
import 'package:snampo/features/mission/presentation/util/polyline_util.dart';

/// 履歴のルートマップ
///
/// 出発地点は白い丸、スポットは判定の色の丸に番号を付ける (未発見は白)。
class HistoryRouteMap extends StatefulWidget {
  /// [HistoryRouteMap] を作成する
  const HistoryRouteMap({required this.record, super.key});

  /// 出す履歴
  final MissionHistory record;

  @override
  State<HistoryRouteMap> createState() => _HistoryRouteMapState();
}

class _HistoryRouteMapState extends State<HistoryRouteMap> {
  List<BitmapDescriptor>? _spotIcons;
  BitmapDescriptor? _departureIcon;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_spotIcons == null) _buildIcons();
  }

  Future<void> _buildIcons() async {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final spots = widget.record.spots;
    final icons = [
      for (final (i, spot) in spots.indexed)
        await _circleIcon(
          fill: spot.shownRank?.color ?? Colors.white,
          textColor:
              spot.shownRank == null ? const Color(0xFF41493F) : Colors.white,
          label: spot.isDestination ? 'G' : '${i + 1}',
          pixelRatio: pixelRatio,
        ),
    ];
    final departure = await _circleIcon(
      fill: Colors.white,
      textColor: const Color(0xFF41493F),
      label: '',
      pixelRatio: pixelRatio,
      size: 18,
    );
    if (mounted) {
      setState(() {
        _spotIcons = icons;
        _departureIcon = departure;
      });
    }
  }

  static Future<BitmapDescriptor> _circleIcon({
    required Color fill,
    required Color textColor,
    required String label,
    required double pixelRatio,
    double size = 24,
  }) async {
    final physical = size * pixelRatio;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(physical / 2, physical / 2);
    canvas
      ..drawCircle(center, physical / 2, Paint()..color = Colors.white)
      ..drawCircle(
        center,
        physical / 2 - 2 * pixelRatio,
        Paint()..color = fill == Colors.white ? const Color(0xFFE0E4DA) : fill,
      );
    if (fill == Colors.white) {
      canvas.drawCircle(
        center,
        physical / 2 - 3.5 * pixelRatio,
        Paint()..color = Colors.white,
      );
    }
    if (label.isNotEmpty) {
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: textColor, fontSize: 11 * pixelRatio),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        center - Offset(painter.width / 2, painter.height / 2),
      );
    } else {
      canvas.drawCircle(center, 3 * pixelRatio, Paint()..color = textColor);
    }
    final image = await recorder.endRecording().toImage(
      physical.round(),
      physical.round(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: pixelRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final encoded = record.overviewPolyline;
    final polylinePoints =
        encoded.isNotEmpty ? decodePolyline(encoded) : <LatLng>[];
    final spots = record.spots;
    final icons = _spotIcons;

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(record.departure.latitude, record.departure.longitude),
        zoom: 14,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + MapTopBar.height,
      ),
      polylines: {
        if (polylinePoints.isNotEmpty)
          Polyline(
            polylineId: const PolylineId('history_route'),
            points: polylinePoints,
            color: Colors.blue,
            width: 3,
          ),
      },
      markers: {
        Marker(
          markerId: const MarkerId('departure'),
          position: LatLng(
            record.departure.latitude,
            record.departure.longitude,
          ),
          anchor: const Offset(0.5, 0.5),
          icon: _departureIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(title: '出発'),
        ),
        for (var i = 0; i < spots.length; i++)
          Marker(
            markerId: MarkerId('spot_$i'),
            position: LatLng(
              spots[i].coordinate.latitude,
              spots[i].coordinate.longitude,
            ),
            anchor: const Offset(0.5, 0.5),
            icon: icons?[i] ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: formatHistorySpotTitle(spot: spots[i], index: i),
            ),
          ),
      },
    );
  }
}
