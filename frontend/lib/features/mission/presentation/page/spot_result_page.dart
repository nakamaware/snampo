import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/genre_label.dart';
import 'package:snampo/features/mission/presentation/component/judge_detail_sections.dart';
import 'package:snampo/features/mission/presentation/component/map_top_bar.dart';
import 'package:snampo/features/mission/presentation/component/photo_compare_viewer.dart';
import 'package:snampo/features/mission/presentation/component/spot_result_band.dart';
import 'package:snampo/features/mission/presentation/component/spot_result_map.dart';
import 'package:snampo/features/mission/presentation/component/spot_result_map_legend.dart';
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
    this.isCoop = false,
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

  /// 協力プレイのスポットか (写真に撮った人の名札を付ける)
  ///
  /// 撮った直後は発見の共有が終わっておらず、進捗に発見者がまだないので、これで判断する。
  final bool isCoop;
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
            : args.isCoop || checkpoint.discovererUid != null
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
                SpotResultBand(
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
                  photo: SpotResultPhoto(
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
                        JudgeDistanceSection(
                          distanceErrorMeters: distanceErrorMeters,
                          zoomLevel: zoomLevel,
                          rank: rank,
                        ),
                        const SizedBox(height: 18),
                        // 向きを取れない端末では、向きのずれは出さない
                        if (headingErrorDegrees != null) ...[
                          const Divider(height: 1),
                          const SizedBox(height: 18),
                          JudgeHeadingSection(
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
                              child: SpotResultMapLegend(
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
