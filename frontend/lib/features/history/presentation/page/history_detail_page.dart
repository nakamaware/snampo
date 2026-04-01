import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/presentation/component/history_fullscreen_image_viewer.dart';
import 'package:snampo/features/history/presentation/hook/use_history_detail.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';
import 'package:snampo/features/mission/presentation/util/polyline_util.dart';

/// 1 件の履歴の詳細
class HistoryDetailPage extends HookConsumerWidget {
  /// [HistoryDetailPage] を作成する
  const HistoryDetailPage({required this.recordId, super.key});

  /// 履歴の id ( [MissionHistory.id] )
  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final titleTextStyle = (theme.textTheme.displayMedium ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.onPrimary);
    final detailAsync = useHistoryDetail(ref, recordId);

    return Scaffold(
      appBar: AppBar(
        title: Text('履歴の詳細', style: titleTextStyle),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
      ),
      body: detailAsync.when(
        data: (found) {
          if (found == null) {
            return const Center(child: Text('この履歴は見つかりませんでした'));
          }
          return _HistoryDetailBody(record: found);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('読み込みに失敗しました\n$error')),
      ),
    );
  }
}

/// 履歴の詳細の本体
class _HistoryDetailBody extends StatelessWidget {
  const _HistoryDetailBody({required this.record});

  final MissionHistory record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RouteMap(record: record),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '所要時間: '
            '${formatMissionDuration(record.startedAt, record.completedAt)}',
            style: theme.textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Text(
            formatMissionSettings(record.settings),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: record.spots.length,
            itemBuilder:
                (context, index) =>
                    _SpotCard(spot: record.spots[index], index: index),
          ),
        ),
      ],
    );
  }
}

/// 履歴のルートマップ
class _RouteMap extends StatelessWidget {
  const _RouteMap({required this.record});

  final MissionHistory record;

  @override
  Widget build(BuildContext context) {
    final encoded = record.overviewPolyline;
    final polylinePoints =
        encoded.isNotEmpty ? decodePolyline(encoded) : <LatLng>[];

    final polylines = <Polyline>{
      if (polylinePoints.isNotEmpty)
        Polyline(
          polylineId: const PolylineId('history_route'),
          points: polylinePoints,
          color: Colors.blue,
          width: 3,
        ),
    };

    final spots = record.spots;
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('departure'),
        position: LatLng(record.departure.latitude, record.departure.longitude),
        infoWindow: const InfoWindow(title: '出発'),
      ),
      for (var i = 0; i < spots.length; i++)
        Marker(
          markerId: MarkerId('spot_$i'),
          position: LatLng(
            spots[i].coordinate.latitude,
            spots[i].coordinate.longitude,
          ),
          infoWindow: InfoWindow(title: 'Spot ${i + 1}'),
        ),
    };

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.38,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(record.departure.latitude, record.departure.longitude),
          zoom: 14,
        ),
        polylines: polylines,
        markers: markers,
      ),
    );
  }
}

/// スポットのカード
class _SpotCard extends StatelessWidget {
  const _SpotCard({required this.spot, required this.index});

  final MissionHistorySpot spot;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spot ${index + 1}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PhotoColumn(
                    label: '参考画像 (Street View)',
                    path: spot.streetViewImagePath,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PhotoColumn(
                    label: 'あなたの写真',
                    path: spot.userPhotoPath,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 写真のカラム
class _PhotoColumn extends StatelessWidget {
  const _PhotoColumn({required this.label, this.path});

  final String label;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        _PhotoThumbnail(path: path),
      ],
    );
  }
}

/// 写真のサムネイル
class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({this.path});

  final String? path;

  static const _height = 120.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedPath = path;

    if (resolvedPath != null && resolvedPath.isNotEmpty) {
      final file = File(resolvedPath);
      Widget thumbnailError(BuildContext _, Object __, StackTrace? ___) {
        return SizedBox(
          height: _height,
          width: double.infinity,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: theme.colorScheme.outline,
              size: 40,
            ),
          ),
        );
      }

      return Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder:
                    (_) => HistoryFullscreenImageViewer(
                      child: Image.file(
                        file,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.white54,
                              size: 64,
                            ),
                          );
                        },
                      ),
                    ),
              ),
            );
          },
          child: Image.file(
            file,
            height: _height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: thumbnailError,
          ),
        ),
      );
    }

    return Container(
      height: _height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.colorScheme.outline,
        size: 40,
      ),
    );
  }
}
