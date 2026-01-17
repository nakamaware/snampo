import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/models/walk_history.dart';
import 'package:snampo/presentation/controllers/walk_history_controller.dart';

/// 履歴詳細を表示するページ
class HistoryDetailPage extends ConsumerWidget {
  /// HistoryDetailPageのコンストラクタ
  const HistoryDetailPage({
    required this.historyId,
    super.key,
  });

  /// 履歴ID
  final String historyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final titleTextStyle = (theme.textTheme.displayMedium ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(
      color: theme.colorScheme.onPrimary,
    );

    final historyAsync = ref.watch(
      walkHistoryControllerProvider.select(
        (histories) => histories.whenData(
          (histories) => histories.firstWhere(
            (h) => h.id == historyId,
            orElse: () => throw StateError('履歴が見つかりません'),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '履歴詳細',
          style: titleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: historyAsync.when(
        data: (history) => HistoryDetailContent(history: history),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                '履歴の読み込みに失敗しました',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 履歴詳細コンテンツウィジェット
class HistoryDetailContent extends StatefulWidget {
  /// HistoryDetailContentのコンストラクタ
  const HistoryDetailContent({
    required this.history,
    super.key,
  });

  /// 履歴データ
  final WalkHistory history;

  @override
  State<HistoryDetailContent> createState() => _HistoryDetailContentState();
}

/// HistoryDetailContentの状態管理クラス
class _HistoryDetailContentState extends State<HistoryDetailContent> {
  GoogleMapController? _mapController;
  List<LatLng> _polylineCoordinates = [];
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _decodePolyline();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _polylines.clear();
    _markers.clear();
    _polylineCoordinates.clear();
    super.dispose();
  }

  void _decodePolyline() {
    final polyline = widget.history.overviewPolyline;
    if (polyline == null || polyline.isEmpty) return;

    try {
      final points = PolylinePoints().decodePolyline(polyline);
      if (points.isEmpty) return;

      setState(() {
        _polylineCoordinates = points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: _polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        );
      });

      // ポリラインのデコードが完了したらマーカーを設定
      _setupMarkers();

      // マップの範囲に合わせてカメラを調整
      if (_mapController != null && _polylineCoordinates.isNotEmpty) {
        _fitBounds();
      }
    } catch (_) {
      // ポリラインのデコードに失敗した場合は無視
    }
  }

  void _setupMarkers() {
    final markers = <Marker>{};

    // 出発地点 (最初のポイント)
    if (_polylineCoordinates.isNotEmpty) {
      final startPoint = _polylineCoordinates.first;
      markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: startPoint,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: '出発地点'),
        ),
      );
    }

    // 目的地
    if (widget.history.destination != null &&
        widget.history.destination!.latitude != null &&
        widget.history.destination!.longitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(
            widget.history.destination!.latitude!,
            widget.history.destination!.longitude!,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          infoWindow: const InfoWindow(title: '目的地'),
        ),
      );
    }

    // 中間地点
    for (var i = 0; i < widget.history.midpoints.length; i++) {
      final midpoint = widget.history.midpoints[i];
      if (midpoint.latitude != null && midpoint.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId('midpoint_$i'),
            position: LatLng(
              midpoint.latitude!,
              midpoint.longitude!,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: InfoWindow(title: '中間地点 ${i + 1}'),
          ),
        );
      }
    }

    setState(() {
      _markers.addAll(markers);
    });
  }

  void _fitBounds() {
    if (_polylineCoordinates.isEmpty || _mapController == null) return;

    var minLat = _polylineCoordinates.first.latitude;
    var maxLat = _polylineCoordinates.first.latitude;
    var minLng = _polylineCoordinates.first.longitude;
    var maxLng = _polylineCoordinates.first.longitude;

    for (final point in _polylineCoordinates) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = _formatDate(widget.history.completedAt);
    final distanceText = widget.history.distanceKilometers >= 1
        ? '${widget.history.distanceKilometers.toStringAsFixed(2)} km'
        : '${widget.history.distanceMeters.toStringAsFixed(0)} m';

    // 初期カメラ位置を決定
    LatLng initialPosition;
    if (_polylineCoordinates.isNotEmpty) {
      initialPosition = _polylineCoordinates.first;
    } else if (widget.history.destination != null &&
        widget.history.destination!.latitude != null &&
        widget.history.destination!.longitude != null) {
      initialPosition = LatLng(
        widget.history.destination!.latitude!,
        widget.history.destination!.longitude!,
      );
    } else {
      initialPosition = const LatLng(35.6812, 139.7671); // 東京駅
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 地図
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 14,
              ),
              polylines: _polylines,
              markers: _markers,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
                if (_polylineCoordinates.isNotEmpty) {
                  _fitBounds();
                }
              },
            ),
          ),
          // 情報セクション
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 日付
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateText,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 距離
                Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      distanceText,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 写真セクション
                if (_hasPhotos())
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '写真',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPhotoGallery(theme),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasPhotos() {
    // 撮影した写真があるかチェック
    if (widget.history.photoPaths.any((path) => path != null)) {
      return true;
    }
    // ストリートビュー画像があるかチェック
    if (widget.history.destination?.imageUtf8 != null) {
      return true;
    }
    for (final midpoint in widget.history.midpoints) {
      if (midpoint.imageUtf8 != null) {
        return true;
      }
    }
    return false;
  }

  Widget _buildPhotoGallery(ThemeData theme) {
    final photos = <Widget>[];

    // 撮影した写真を追加
    for (var i = 0; i < widget.history.photoPaths.length; i++) {
      final photoPath = widget.history.photoPaths[i];
      if (photoPath != null) {
        final file = File(photoPath);
        if (file.existsSync()) {
          photos.add(
            _buildPhotoItem(
              Image.file(file, fit: BoxFit.cover),
              '撮影写真 ${i + 1}',
            ),
          );
        }
      }
    }

    // ストリートビュー画像を追加
    if (widget.history.destination?.imageUtf8 != null) {
      try {
        final imageBytes = base64Decode(widget.history.destination!.imageUtf8!);
        photos.add(
          _buildPhotoItem(
            Image.memory(
              imageBytes,
              fit: BoxFit.cover,
            ),
            '目的地のストリートビュー',
          ),
        );
      } catch (_) {
        // 画像の読み込みに失敗した場合は無視
      }
    }

    for (var i = 0; i < widget.history.midpoints.length; i++) {
      final midpoint = widget.history.midpoints[i];
      if (midpoint.imageUtf8 != null) {
        try {
          final imageBytes = base64Decode(midpoint.imageUtf8!);
          photos.add(
            _buildPhotoItem(
              Image.memory(
                imageBytes,
                fit: BoxFit.cover,
              ),
              '中間地点 ${i + 1} のストリートビュー',
            ),
          );
        } catch (_) {
          // 画像の読み込みに失敗した場合は無視
        }
      }
    }

    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: photos,
    );
  }

  Widget _buildPhotoItem(Widget image, String label) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 日付をフォーマットする
  String _formatDate(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$year年$month月$day日 $hour:$minute';
  }
}
