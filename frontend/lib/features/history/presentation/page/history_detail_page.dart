import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snampo/features/history/domain/entity/mission_history_entity.dart';
import 'package:snampo/features/history/presentation/store/history_store.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';
import 'package:snampo/features/history/presentation/util/history_fullscreen_image.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/presentation/util/polyline_util.dart';

/// 1 件の履歴の詳細 (地図 + 各スポットの写真)
class HistoryDetailPage extends ConsumerWidget {
  /// [HistoryDetailPage] を作成する
  const HistoryDetailPage({required this.recordId, super.key});

  /// 履歴レコードの id ( [MissionHistoryEntity.id] )
  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final titleTextStyle = (theme.textTheme.displayMedium ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.onPrimary);

    final historyAsync = ref.watch(historyStoreProvider);

    return historyAsync.when(
      data: (data) {
        MissionHistoryEntity? found;
        for (final r in data.records) {
          if (r.id == recordId) {
            found = r;
            break;
          }
        }
        if (found == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('履歴', style: titleTextStyle),
              centerTitle: true,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            body: const Center(child: Text('この履歴は見つかりませんでした')),
          );
        }
        final record = found;

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
          body: _HistoryDetailBody(record: record),
        );
      },
      loading:
          () => Scaffold(
            appBar: AppBar(
              title: Text('履歴の詳細', style: titleTextStyle),
              centerTitle: true,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stackTrace) => Scaffold(
            appBar: AppBar(
              title: Text('履歴の詳細', style: titleTextStyle),
              centerTitle: true,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            body: Center(child: Text('読み込みに失敗しました\n$error')),
          ),
    );
  }
}

class _HistoryDetailBody extends StatelessWidget {
  const _HistoryDetailBody({required this.record});

  final MissionHistoryEntity record;

  @override
  Widget build(BuildContext context) {
    final mission = record.mission;
    final spots = <ImageCoordinate>[...mission.waypoints, mission.destination];
    final encoded = mission.overviewPolyline;
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

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('departure'),
        position: LatLng(
          mission.departure.latitude,
          mission.departure.longitude,
        ),
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

    final departure = mission.departure;
    final durationText = formatMissionDuration(
      record.progress.startedAt,
      record.completedAt,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.38,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(departure.latitude, departure.longitude),
              zoom: 14,
            ),
            polylines: polylines,
            markers: markers,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '所要時間: $durationText',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: spots.length,
            itemBuilder: (context, index) {
              final spot = spots[index];
              final cp =
                  index < record.progress.checkpoints.length
                      ? record.progress.checkpoints[index]
                      : null;
              final userPath = cp?.userPhotoPath;

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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('参考画像 ( Street View )'),
                                const SizedBox(height: 4),
                                _StreetViewThumb(imageBase64: spot.imageBase64),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('あなたの写真'),
                                const SizedBox(height: 4),
                                _UserPhotoThumb(path: userPath),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StreetViewThumb extends StatelessWidget {
  const _StreetViewThumb({required this.imageBase64});

  final String imageBase64;

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(imageBase64);
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openHistoryFullscreenImageFromBytes(context, bytes),
        child: Image.memory(
          bytes,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _UserPhotoThumb extends StatelessWidget {
  const _UserPhotoThumb({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pathNonNull = path;
    if (pathNonNull != null && File(pathNonNull).existsSync()) {
      final filePath = pathNonNull;
      return Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openHistoryFullscreenImageFromFile(context, filePath),
          child: Image.file(
            File(filePath),
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container(
      height: 120,
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
