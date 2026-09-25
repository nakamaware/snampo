import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/discoverer_rank.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';
import 'package:snampo/features/history/presentation/hook/use_history_detail.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/component/expand_photo_icon.dart';
import 'package:snampo/features/mission/presentation/component/judge_rank_badge.dart';
import 'package:snampo/features/mission/presentation/component/map_top_bar.dart';
import 'package:snampo/features/mission/presentation/component/mission_recap.dart';
import 'package:snampo/features/mission/presentation/component/photo_compare_viewer.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';
import 'package:snampo/features/mission/presentation/util/mission_format_util.dart';
import 'package:snampo/features/mission/presentation/util/polyline_util.dart';

/// 1 件の履歴の詳細
///
/// 上に歩いたルートの地図、その下にプレイ結果と同じまとめ、スポットごとに見本と撮った写真を並べる。
/// 削除すると、一覧に `true` を返して戻る。
class HistoryDetailPage extends HookConsumerWidget {
  /// [HistoryDetailPage] を作成する
  const HistoryDetailPage({required this.recordId, super.key});

  /// 履歴の id ( [MissionHistory.id] )
  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = useHistoryDetail(ref, recordId);

    return detailAsync.when(
      data: (found) {
        if (found == null) {
          return const _MessageScaffold(message: 'この履歴は見つかりませんでした');
        }
        return _HistoryDetailBody(record: found);
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) {
        log(
          'HistoryDetailPage load error',
          error: error,
          stackTrace: stackTrace,
        );
        return const _MessageScaffold(message: '読み込みに失敗しました');
      },
    );
  }
}

class _MessageScaffold extends StatelessWidget {
  const _MessageScaffold({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [Center(child: Text(message)), const MapTopBar()]),
    );
  }
}

/// 履歴の詳細の本体
class _HistoryDetailBody extends ConsumerWidget {
  const _HistoryDetailBody({required this.record});

  final MissionHistory record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coop = record.coop;
    // 重複した名前には、表示するときだけ入室順に番号を付ける
    final displayNames =
        coop == null
            ? const <String, String>{}
            : displayNicknames([
              for (final m in coop.members) (uid: m.uid, nickname: m.nickname),
            ]);
    // 自分の uid は保存していないので、自分の写真で発見したスポットの発見者から分かる
    final myUid =
        record.spots
            .where((s) => s.userPhotoPath != null && s.discovererUid != null)
            .firstOrNull
            ?.discovererUid;

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + 24,
            ),
            children: [
              SizedBox(
                height:
                    MediaQuery.paddingOf(context).top + MapTopBar.height + 170,
                child: _RouteMap(record: record),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: MissionRecap(
                  caption: [
                    formatCompletedDate(record.completedAt),
                    if (coop == null) 'ひとりで' else 'みんなで',
                  ].join(' · '),
                  meta: [
                    formatMissionDuration(record.startedAt, record.completedAt),
                    _settingsLabel(),
                  ].join(' · '),
                  spots: [
                    for (final s in record.spots)
                      (found: s.isCleared, rank: s.shownRank),
                  ],
                  members:
                      coop == null
                          ? const []
                          : _members(
                            uids: [for (final m in coop.members) m.uid],
                            displayNames: displayNames,
                            myUid: myUid,
                          ),
                ),
              ),
              for (final (i, spot) in record.spots.indexed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _SpotBlock(
                    record: record,
                    spot: spot,
                    index: i,
                    ownerLabel: _ownerLabel(spot, displayNames, myUid),
                    discovererName:
                        displayNames[spot.discovererUid] ??
                        spot.discovererNickname,
                  ),
                ),
            ],
          ),
          MapTopBar(
            actions: [
              PopupMenuButton<void>(
                tooltip: 'メニュー',
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        onTap: () => _confirmRemove(context, ref),
                        child: const Text('この履歴を削除'),
                      ),
                    ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _settingsLabel() => switch (record.settings) {
    MissionSettingsRandom(:final radius) => 'ランダム 半径 ${radius.meters} m',
    MissionSettingsDestination() =>
      '目的地指定 · ${record.spots.lastOrNull?.name ?? '指定したゴール地点'}',
  };

  /// 見つけた数の多い順 (同数なら入室順)
  List<RecapMember> _members({
    required List<String> uids,
    required Map<String, String> displayNames,
    required String? myUid,
  }) {
    final discoveries = [
      for (final spot in record.spots)
        if (spot.discovererUid != null && spot.isCleared) spot,
    ];
    // 抜けたメンバーなどで名前がなければ、発見時点のニックネームで表示する
    final fallbackNames = {
      for (final spot in discoveries)
        spot.discovererUid!: spot.discovererNickname,
    };
    return [
      for (final rank in rankDiscoverers(
        discovererUids: [for (final s in discoveries) s.discovererUid!],
        uidsInJoinOrder: uids,
      ))
        (
          name: displayNames[rank.uid] ?? fallbackNames[rank.uid] ?? '???',
          count: rank.count,
          isMe: rank.uid == myUid,
        ),
    ];
  }

  /// 写真を撮った人の名札 (ソロは全部自分の写真なので付けない)
  String? _ownerLabel(
    MissionHistorySpot spot,
    Map<String, String> displayNames,
    String? myUid,
  ) {
    if (record.coop == null) return null;
    if (spot.userPhotoPath != null) return 'あなた';
    final uid = spot.discovererUid;
    if (uid == null) return null;
    return uid == myUid
        ? 'あなた'
        : displayNames[uid] ?? spot.discovererNickname ?? '発見者';
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('削除の確認'),
            content: const Text('この履歴を削除しますか？写真ファイルも削除されます。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('削除'),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(removeMissionHistoryUseCaseProvider).call(record.id);
    } catch (error, stackTrace) {
      log('履歴の削除に失敗', error: error, stackTrace: stackTrace);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('履歴の削除に失敗しました')));
      }
      return;
    }
    if (context.mounted) context.pop(true);
  }
}

/// 1 スポットの結果 (見本と撮った写真、判定、ずれ)
class _SpotBlock extends StatelessWidget {
  const _SpotBlock({
    required this.record,
    required this.spot,
    required this.index,
    required this.ownerLabel,
    required this.discovererName,
  });

  final MissionHistory record;
  final MissionHistorySpot spot;
  final int index;
  final String? ownerLabel;
  final String? discovererName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final title = spot.isDestination ? 'GOAL' : 'SPOT ${index + 1}';
    final name = formatHistorySpotTitle(spot: spot, index: index);
    final rank = spot.shownRank;
    final photoPath = spot.shownPhotoPath;
    final judgement = _judgement();
    final reference = FileImage(File(spot.streetViewImagePath));
    final photo = photoPath == null ? null : FileImage(File(photoPath));
    final canOpenResult =
        spot.isCleared &&
        (spot.userPhotoPath != null || spot.discovererUid != null);

    void openViewer() => PhotoCompareViewer.open(
      context,
      title: name,
      caption: '$title · ${formatCompletedDate(record.completedAt)}',
      reference: ComparePhoto(label: '見本', image: reference),
      photo:
          photo == null
              ? null
              : ComparePhoto(
                label: ownerLabel ?? 'あなた',
                image: photo,
                isMine: spot.userPhotoPath != null,
              ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      title,
                      if (record.coop != null && spot.isCleared)
                        if (discovererName case final d?) '発見: $d',
                    ].join(' · '),
                    style: muted,
                  ),
                  Text(name, style: theme.textTheme.titleMedium),
                ],
              ),
            ),
            if (rank != null)
              JudgeRankBadge(rank: rank)
            else if (!spot.isCleared)
              Text('未発見', style: muted),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Photo(image: reference, label: '見本', onTap: openViewer),
            ),
            const SizedBox(width: 8),
            Expanded(
              child:
                  photo == null
                      // 協力プレイで、発見者のサムネがまだ届いていないこともある
                      ? _MissingPhoto(isCleared: spot.isCleared)
                      : _Photo(
                        image: photo,
                        label: ownerLabel ?? 'あなた',
                        isMine: spot.userPhotoPath != null,
                        onTap: openViewer,
                      ),
            ),
          ],
        ),
        if (canOpenResult)
          Row(
            children: [
              if (judgement case (final distance, final heading))
                Expanded(
                  child: Text(
                    [
                      'スポットまで ${distance.toStringAsFixed(1)} m',
                      if (heading != null)
                        '向き ${formatHeadingErrorText(heading)}',
                    ].join('　'),
                    style: muted,
                  ),
                )
              else
                const Spacer(),
              TextButton(
                onPressed: () => _openSpotResult(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text('くわしく'), Icon(Icons.chevron_right)],
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// 出す距離と向き (自分が撮っていなければ、協力プレイの発見者のもの)
  (double, double?)? _judgement() {
    if (!spot.isCleared) return null;
    if (spot.distanceErrorMeters case final d? when spot.judgeRank != null) {
      return (d, spot.headingErrorDegrees);
    }
    final j = spot.discovererJudgement;
    return j == null ? null : (j.distanceErrorMeters, j.headingErrorDegrees);
  }

  void _openSpotResult(BuildContext context) {
    context.push(
      '/spot-result',
      extra: SpotResultPageArgs(
        spotIndex: index,
        totalCheckpointCount: record.spots.length,
        missionPoint: ImageCoordinate(
          coordinate: spot.coordinate,
          imageBase64: '',
          referenceHeading: spot.referenceHeading,
          name: spot.name,
          genre: spot.genre,
          googleMapsUrl: spot.googleMapsUrl,
        ),
        checkpoint: CheckpointProgress(
          guessPosition: spot.guessPosition,
          userPhotoPath: spot.userPhotoPath,
          capturedHeading: spot.capturedHeading,
          distanceErrorMeters: spot.distanceErrorMeters,
          headingErrorDegrees: spot.headingErrorDegrees,
          judgeRank: spot.judgeRank,
          zoomLevel: spot.zoomLevel,
          achievedAt: spot.achievedAt,
          discovererUid: spot.discovererUid,
          discovererNickname: spot.discovererNickname,
          discovererThumbPath: spot.discovererThumbPath,
          discovererJudgement: spot.discovererJudgement,
        ),
        fromSummary: true,
        isDestinationMode: record.settings is MissionSettingsDestination,
        discovererDisplayName: discovererName,
        referenceImagePath: spot.streetViewImagePath,
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({
    required this.image,
    required this.label,
    required this.onTap,
    this.isMine = false,
  });

  final ImageProvider image;
  final String label;
  final bool isMine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colorScheme.outline,
        ),
      ),
    );
    return Semantics(
      button: true,
      label: '$labelを大きく見る',
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => placeholder,
                ),
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color:
                          isMine
                              ? colorScheme.primary.withValues(alpha: 0.85)
                              : Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 1,
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(right: 6, bottom: 6, child: ExpandPhotoIcon()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingPhoto extends StatelessWidget {
  const _MissingPhoto({required this.isCleared});

  /// 発見済みなら、写真がないだけなので「未発見」とは出さない
  final bool isCleared;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isCleared) {
      return AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.image_not_supported_outlined,
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            '未発見',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}

/// 履歴のルートマップ
///
/// 出発地点は白い丸、スポットは判定の色の丸に番号を付ける (未発見は白)。
class _RouteMap extends StatefulWidget {
  const _RouteMap({required this.record});

  final MissionHistory record;

  @override
  State<_RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<_RouteMap> {
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
