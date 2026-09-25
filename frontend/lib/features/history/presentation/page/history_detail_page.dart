import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/presentation/component/history_photo_thumbnail.dart';
import 'package:snampo/features/history/presentation/hook/use_history_detail.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/genre_label.dart';
import 'package:snampo/features/mission/presentation/util/polyline_util.dart';
import 'package:url_launcher/url_launcher.dart';

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
        error: (error, stackTrace) {
          log(
            'HistoryDetailPage load error',
            error: error,
            stackTrace: stackTrace,
          );
          return const Center(child: Text('読み込みに失敗しました'));
        },
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

    final coop = record.coop;
    // 重複した名前には、表示するときだけ入室順に番号を付ける
    final displayNames =
        coop == null
            ? const <String, String>{}
            : displayNicknames([
              for (final m in coop.members) (uid: m.uid, nickname: m.nickname),
            ]);

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
        if (record.coop case final coop?)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(
              '${formatCoopLabel(coop)}  ${formatCoopMembers(coop)}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: record.spots.length,
            itemBuilder:
                (context, index) => _SpotCard(
                  spot: record.spots[index],
                  index: index,
                  isCoop: record.coop != null,
                  displayNames: displayNames,
                ),
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
  const _SpotCard({
    required this.spot,
    required this.index,
    this.isCoop = false,
    this.displayNames = const {},
  });

  /// 協力プレイのメンバーの uid ごとの表示名 (重複した名前には番号を付けたもの)
  final Map<String, String> displayNames;

  final MissionHistorySpot spot;
  final int index;
  final bool isCoop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 自分が撮影していなければ、協力プレイの発見者の採点を表示する
    final ownScore = spot.judgeRank != null;
    final discovererJudgement = ownScore ? null : spot.discovererJudgement;
    final rank = spot.judgeRank ?? discovererJudgement?.rank;
    final distanceErrorMeters =
        ownScore
            ? spot.distanceErrorMeters
            : discovererJudgement?.distanceErrorMeters;
    final headingErrorDegrees =
        ownScore
            ? spot.headingErrorDegrees
            : discovererJudgement?.headingErrorDegrees;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatHistorySpotTitle(spot: spot, index: index),
              style: theme.textTheme.titleSmall,
            ),
            if (isCoop)
              Text(
                discovererLabel(
                  displayNames[spot.discovererUid] ?? spot.discovererNickname,
                  isCleared: spot.isCleared,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      spot.isCleared
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                ),
              ),
            if (rank != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  _RankBadge(rank: rank),
                  if (discovererJudgement != null) ...[
                    const SizedBox(width: 8),
                    Text('発見者の採点', style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ],
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
                // 協力プレイで他の人が発見したスポットは、発見者のサムネを表示する
                // (取得できなければプレースホルダ)
                if (isCoop &&
                    spot.discovererNickname != null &&
                    spot.userPhotoPath == null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PhotoColumn(
                      label: '発見者の写真',
                      path: spot.discovererThumbPath,
                    ),
                  ),
                ],
              ],
            ),
            if (spot.genre != null ||
                distanceErrorMeters != null ||
                headingErrorDegrees != null) ...[
              const SizedBox(height: 8),
              if (spot.genre != null)
                _InfoRow(label: 'ジャンル', value: spot.genre!.japaneseLabel),
              if (distanceErrorMeters != null)
                _InfoRow(
                  label: 'スポットまで残り',
                  value: formatDistanceError(distanceErrorMeters),
                ),
              if (headingErrorDegrees != null)
                _InfoRow(
                  label: '向きのずれ',
                  value: formatHeadingError(headingErrorDegrees),
                ),
            ],
            if (spot.googleMapsUrl != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed:
                      () => _openGoogleMaps(context, spot.googleMapsUrl!),
                  child: const Text('Google Mapでスポットを確認する'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(BuildContext context, String url) async {
    final Uri uri;
    try {
      uri = Uri.parse(url);
    } on FormatException {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google Map を開けませんでした')));
      }
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google Map を開けませんでした')));
      }
    }
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final PhotoJudgeRank rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (rank) {
      PhotoJudgeRank.excellent => Colors.green,
      PhotoJudgeRank.good => Colors.blue,
      PhotoJudgeRank.fair => Colors.orange,
      PhotoJudgeRank.miss => Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rank.label,
        style: theme.textTheme.titleSmall?.copyWith(color: color),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
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
        HistoryPhotoThumbnail(path: path),
      ],
    );
  }
}
