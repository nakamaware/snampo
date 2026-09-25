import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/genre_label.dart';
import 'package:snampo/features/mission/presentation/component/expand_photo_icon.dart';
import 'package:snampo/features/mission/presentation/component/heading_dial.dart';
import 'package:snampo/features/mission/presentation/component/judge_distance_bar.dart';
import 'package:snampo/features/mission/presentation/component/judge_rank_badge.dart';
import 'package:snampo/features/mission/presentation/component/map_top_bar.dart';
import 'package:snampo/features/mission/presentation/component/photo_compare_viewer.dart';
import 'package:snampo/features/mission/presentation/component/spot_result_map.dart';
import 'package:snampo/features/mission/presentation/util/mission_format_util.dart';
import 'package:url_launcher/url_launcher.dart';

/// SpotResultPage の引数
class SpotResultPageArgs {
  /// SpotResultPageArgs のコンストラクタ
  const SpotResultPageArgs({
    required this.spotIndex,
    required this.totalCheckpointCount,
    required this.missionPoint,
    required this.checkpoint,
    this.fromSummary = false,
    this.isDestinationMode = false,
    this.discovererDisplayName,
    this.closeLabel,
    this.referenceImagePath,
  });

  /// Spot のインデックス
  final int spotIndex;

  /// 全チェックポイント数
  final int totalCheckpointCount;

  /// 表示対象の地点情報
  final ImageCoordinate missionPoint;

  /// 表示対象の進捗情報
  final CheckpointProgress checkpoint;

  /// プレイ結果や履歴の詳細から開いたか
  ///
  /// 見返しているだけなので、下のボタンは出さず、左上の戻るボタンで戻る。
  final bool fromSummary;

  /// 目的地指定モードのミッションかどうか
  final bool isDestinationMode;

  /// 協力プレイの発見者の表示名 (null なら発見時点のニックネームを使う)
  final String? discovererDisplayName;

  /// 下のボタンの文言 (null なら「ミッションに戻る」)
  ///
  /// 協力プレイの最後のスポットでは、閉じるとプレイ結果へ移るため、そのことを文言で示す。
  final String? closeLabel;

  /// 見本の画像のパス (履歴から開くとき。null なら [missionPoint] の画像を使う)
  final String? referenceImagePath;
}

/// Spot単位の採点結果画面
///
/// 上の帯に判定・場所の名前・写真をまとめ、その下に距離と向きのずれを図で出す。
class SpotResultPage extends StatelessWidget {
  /// SpotResultPageのコンストラクタ
  const SpotResultPage({required this.args, super.key});

  /// 画面引数
  final SpotResultPageArgs args;

  @override
  Widget build(BuildContext context) {
    final checkpoint = args.checkpoint;
    final isGoal = args.spotIndex == args.totalCheckpointCount - 1;
    final isSelectedDestinationGoal = isGoal && args.isDestinationMode;
    // 協力プレイで他の人が発見したスポット (自分の写真と採点はない) は、発見者の写真を表示する
    final isOthersDiscovery =
        checkpoint.userPhotoPath == null && checkpoint.discovererUid != null;
    final photoPath =
        isOthersDiscovery
            ? checkpoint.discovererThumbPath
            : checkpoint.userPhotoPath;
    if (checkpoint.userPhotoPath == null && !isOthersDiscovery) {
      return const _ErrorScaffold(message: '採点結果を表示できませんでした。');
    }

    final point = args.missionPoint;
    // 他の人の発見は、共有された発見者の採点を表示する (古いクリアには採点がない)
    final othersJudgement =
        isOthersDiscovery ? checkpoint.discovererJudgement : null;
    final rank =
        isOthersDiscovery ? othersJudgement?.rank : checkpoint.judgeRank;
    final distanceErrorMeters =
        isOthersDiscovery
            ? othersJudgement?.distanceErrorMeters
            : checkpoint.distanceErrorMeters;
    final headingErrorDegrees =
        isOthersDiscovery
            ? othersJudgement?.headingErrorDegrees
            : checkpoint.headingErrorDegrees;
    final zoomLevel =
        isOthersDiscovery ? othersJudgement?.zoomLevel : checkpoint.zoomLevel;
    // 地図には、撮影した人の位置と向きを出す
    final mapCheckpoint =
        isOthersDiscovery
            ? checkpoint.copyWith(
              guessPosition: othersJudgement?.guessPosition,
              capturedHeading: othersJudgement?.capturedHeading,
            )
            : checkpoint;
    final discovererName =
        args.discovererDisplayName ?? checkpoint.discovererNickname;
    // 協力プレイでは写真に撮った人の名札を付ける (ソロは全部自分の写真なので付けない)
    final ownerLabel =
        isOthersDiscovery
            ? (discovererName ?? '発見者')
            : checkpoint.discovererUid != null
            ? 'あなた'
            : null;
    final pointName =
        point.name ??
        (isSelectedDestinationGoal
            ? '指定したゴール地点'
            : 'Spot ${args.spotIndex + 1}');
    final genre =
        point.genre?.japaneseLabel ??
        (isSelectedDestinationGoal ? '目的地指定' : null);
    final caption = [
      if (isGoal)
        'GOAL / ${args.totalCheckpointCount}'
      else
        'SPOT ${args.spotIndex + 1} / ${args.totalCheckpointCount}',
      if (genre != null) genre,
    ].join(' · ');
    final reference = _referenceImage();
    final photo = photoPath == null ? null : FileImage(File(photoPath));

    void openViewer() => PhotoCompareViewer.open(
      context,
      title: pointName,
      caption: caption,
      reference: ComparePhoto(label: '見本', image: reference),
      photo: ComparePhoto(
        label: ownerLabel ?? 'あなた',
        image: photo,
        isMine: !isOthersDiscovery,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom:
                  args.fromSummary ? MediaQuery.paddingOf(context).bottom : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ResultBand(
                  caption: caption,
                  rank: rank,
                  pointName: pointName,
                  chips: [
                    if (discovererName != null && isOthersDiscovery)
                      rank != null
                          ? '$discovererNameの採点'
                          : '発見: $discovererName',
                    if (rank == PhotoJudgeRank.miss) '発見済み',
                  ],
                  photo: _PhotoWithReference(
                    photo: photo,
                    reference: reference,
                    ownerLabel: ownerLabel,
                    onOpen: openViewer,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (rank != null && distanceErrorMeters != null) ...[
                        _DistanceSection(
                          distanceErrorMeters: distanceErrorMeters,
                          zoomLevel: zoomLevel,
                          rank: rank,
                        ),
                        const SizedBox(height: 18),
                        // 向きを取れない端末では、向きのずれは出さない
                        if (headingErrorDegrees != null) ...[
                          const Divider(height: 1),
                          const SizedBox(height: 18),
                          _HeadingSection(
                            headingErrorDegrees: headingErrorDegrees,
                            rank: rank,
                            isOthersDiscovery: isOthersDiscovery,
                            discovererName: discovererName,
                          ),
                          const SizedBox(height: 18),
                        ],
                      ],
                      SizedBox(
                        height: 170,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: SpotResultMap(
                                missionPoint: point,
                                checkpoint: mapCheckpoint,
                              ),
                            ),
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: _MapLegend(
                                hasStreetView:
                                    point.streetViewLatitude != null &&
                                    point.streetViewLongitude != null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (point.googleMapsUrl case final url?)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => _openGoogleMaps(context, url),
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Google Map で開く'),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const MapTopBar(),
        ],
      ),
      bottomNavigationBar:
          args.fromSummary
              ? null
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: () => context.pop(),
                    child: Text(args.closeLabel ?? 'ミッションに戻る'),
                  ),
                ),
              ),
    );
  }

  /// 見本の画像 (読めなければ null)
  ImageProvider? _referenceImage() {
    if (args.referenceImagePath case final path?) {
      return FileImage(File(path));
    }
    final base64 = args.missionPoint.imageBase64;
    if (base64.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(base64));
    } on FormatException {
      return null;
    }
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

/// 判定の色で塗った上の帯 (判定・場所の名前・写真)
class _ResultBand extends StatelessWidget {
  const _ResultBand({
    required this.caption,
    required this.rank,
    required this.pointName,
    required this.chips,
    required this.photo,
  });

  final String caption;
  final PhotoJudgeRank? rank;
  final String pointName;
  final List<String> chips;
  final Widget photo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rank = this.rank;
    final accent = rank?.color ?? theme.colorScheme.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: rank?.containerColor ?? theme.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.paddingOf(context).top + MapTopBar.height + 4,
          16,
          26,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caption,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (rank != null)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        rank.label,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontSize: 44,
                          height: 1.1,
                          color: accent,
                        ),
                      ),
                    ),
                  if (chips.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [for (final chip in chips) _BandChip(chip)],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(pointName, style: theme.textTheme.titleLarge),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(width: 132, child: photo),
          ],
        ),
      ),
    );
  }
}

class _BandChip extends StatelessWidget {
  const _BandChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        child: Text(text, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}

/// 撮った写真と、左下に重ねた見本の小窓
///
/// 小窓をタップすると大小を入れ替える。大きい写真をタップすると、2 枚を並べた全画面を開く。
class _PhotoWithReference extends StatefulWidget {
  const _PhotoWithReference({
    required this.photo,
    required this.reference,
    required this.ownerLabel,
    required this.onOpen,
  });

  final ImageProvider? photo;
  final ImageProvider? reference;
  final String? ownerLabel;
  final VoidCallback onOpen;

  @override
  State<_PhotoWithReference> createState() => _PhotoWithReferenceState();
}

class _PhotoWithReferenceState extends State<_PhotoWithReference> {
  bool _swapped = false;

  @override
  Widget build(BuildContext context) {
    final hasReference = widget.reference != null;
    final showReferenceLarge = _swapped && hasReference;
    final large = showReferenceLarge ? widget.reference : widget.photo;
    final small = showReferenceLarge ? widget.photo : widget.reference;
    final largeLabel = showReferenceLarge ? '見本' : widget.ownerLabel;
    // ソロでは自分の写真に名札を付けない
    final smallLabel = showReferenceLarge ? widget.ownerLabel : '見本';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Semantics(
          button: true,
          label: '写真を大きく見る',
          child: GestureDetector(
            onTap: widget.onOpen,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _SquareImage(image: large),
                    if (largeLabel != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _PhotoLabel(
                          largeLabel,
                          isMine: largeLabel == 'あなた',
                        ),
                      ),
                    const Positioned(
                      right: 6,
                      bottom: 6,
                      child: ExpandPhotoIcon(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasReference)
          Positioned(
            left: -14,
            bottom: -14,
            width: 58,
            height: 58,
            child: Semantics(
              button: true,
              label: '見本と入れ替える',
              child: GestureDetector(
                onTap: () => setState(() => _swapped = !_swapped),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2.5),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _SquareImage(image: small),
                        if (smallLabel != null)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: ColoredBox(
                              color: Colors.black54,
                              child: Text(
                                smallLabel,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SquareImage extends StatelessWidget {
  const _SquareImage({required this.image});

  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
    final image = this.image;
    if (image == null) return placeholder;
    return Image(
      image: image,
      fit: BoxFit.cover,
      // 協力プレイで共有に失敗すると、表示中に写真を捨てることがある
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

class _PhotoLabel extends StatelessWidget {
  const _PhotoLabel(this.text, {required this.isMine});

  final String text;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            isMine
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.85)
                : Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}

class _DistanceSection extends StatelessWidget {
  const _DistanceSection({
    required this.distanceErrorMeters,
    required this.zoomLevel,
    required this.rank,
  });

  final double distanceErrorMeters;
  final double? zoomLevel;
  final PhotoJudgeRank rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effective = effectiveDistanceMeters(distanceErrorMeters, zoomLevel);
    final zoom = zoomLevel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'スポットまで',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              '${distanceErrorMeters.toStringAsFixed(1)} m',
              style: theme.textTheme.headlineSmall,
            ),
          ],
        ),
        if (zoom != null && zoom > 1)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_formatZoom(zoom)}x ズームなので '
              '${effective.toStringAsFixed(1)} m として判定',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 10),
        JudgeDistanceBar(effectiveDistanceMeters: effective, rank: rank),
      ],
    );
  }

  static String _formatZoom(double zoom) =>
      zoom == zoom.roundToDouble()
          ? zoom.toStringAsFixed(0)
          : zoom.toStringAsFixed(1);
}

class _HeadingSection extends StatelessWidget {
  const _HeadingSection({
    required this.headingErrorDegrees,
    required this.rank,
    required this.isOthersDiscovery,
    required this.discovererName,
  });

  final double headingErrorDegrees;
  final PhotoJudgeRank rank;
  final bool isOthersDiscovery;
  final String? discovererName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final heading = headingErrorDegrees;
    final owner = isOthersDiscovery ? '${discovererName ?? '発見者'}の' : 'あなたの';
    final needleColor =
        heading.abs() > photoJudgeHeadingLimitDegrees
            ? PhotoJudgeRank.miss.color
            : rank.color;
    return Row(
      children: [
        HeadingDial(
          headingErrorDegrees: heading,
          color: rank.color,
          missColor: PhotoJudgeRank.miss.color,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('向きのずれ', style: muted),
              Text(
                formatHeadingErrorText(heading),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text('- - -  見本の向き', style: muted),
              Text('━  $owner向き', style: muted?.copyWith(color: needleColor)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.hasStreetView});

  final bool hasStreetView;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    Widget item(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 3),
        Text(label, style: style),
      ],
    );
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          child: Wrap(
            spacing: 10,
            children: [
              item(const Color(0xFFD93025), 'スポット'),
              if (hasStreetView) item(const Color(0xFFE8B400), '見本の場所'),
              item(Theme.of(context).colorScheme.primary, '撮った場所'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [Center(child: Text(message)), const MapTopBar()]),
    );
  }
}
