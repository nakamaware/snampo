import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/genre_label.dart';
import 'package:snampo/features/mission/presentation/component/spot_result_map.dart';
import 'package:url_launcher/url_launcher.dart';

/// SpotResultPage の引数
class SpotResultPageArgs {
  /// SpotResultPageArgs のコンストラクタ
  const SpotResultPageArgs({
    required this.spotIndex,
    required this.totalCheckpointCount,
    required this.missionPoint,
    required this.checkpoint,
    this.fromResultPage = false,
    this.isDestinationMode = false,
    this.discovererDisplayName,
    this.closeLabel,
  });

  /// Spot のインデックス
  final int spotIndex;

  /// 全チェックポイント数
  final int totalCheckpointCount;

  /// 表示対象の地点情報
  final ImageCoordinate missionPoint;

  /// 表示対象の進捗情報
  final CheckpointProgress checkpoint;

  /// プレイ結果画面から遷移してきたかどうか
  final bool fromResultPage;

  /// 目的地指定モードのミッションかどうか
  final bool isDestinationMode;

  /// 協力プレイの発見者の表示名 (null なら発見時点のニックネームを使う)
  final String? discovererDisplayName;

  /// 画面を閉じるボタンの文言 (null なら戻り先に合わせる)
  ///
  /// 協力プレイの最後のスポットでは、閉じるとプレイ結果へ移るため、そのことを文言で示す。
  final String? closeLabel;
}

/// Spot単位の採点結果画面
class SpotResultPage extends StatelessWidget {
  /// SpotResultPageのコンストラクタ
  const SpotResultPage({required this.args, super.key});

  /// 画面引数
  final SpotResultPageArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      return _ErrorScaffold(message: '採点結果を表示できませんでした。', isGoal: isGoal);
    }

    final point = args.missionPoint;
    // 他の人の発見は、共有された発見者の採点を表示する (古いクリアには採点がない)
    final othersJudgement =
        isOthersDiscovery ? checkpoint.discovererJudgement : null;
    final hasJudgement = !isOthersDiscovery || othersJudgement != null;
    final rank =
        (isOthersDiscovery ? othersJudgement?.rank : checkpoint.judgeRank) ??
        PhotoJudgeRank.miss;
    final distanceErrorMeters =
        isOthersDiscovery
            ? othersJudgement?.distanceErrorMeters
            : checkpoint.distanceErrorMeters;
    final distanceErrorText =
        distanceErrorMeters == null
            ? '取得できませんでした'
            : '${distanceErrorMeters.toStringAsFixed(1)} m';
    final headingErrorText = _buildHeadingErrorText(
      isOthersDiscovery
          ? othersJudgement?.headingErrorDegrees
          : checkpoint.headingErrorDegrees,
    );
    // 地図には、撮影した人の位置と向きを出す
    final mapCheckpoint =
        isOthersDiscovery
            ? checkpoint.copyWith(
              guessPosition: othersJudgement?.guessPosition,
              capturedHeading: othersJudgement?.capturedHeading,
            )
            : checkpoint;
    final pointNameText =
        point.name ?? (isSelectedDestinationGoal ? '指定したゴール地点' : '取得できませんでした');
    final genreText =
        point.genre?.japaneseLabel ??
        (isSelectedDestinationGoal ? '目的地指定' : '取得できませんでした');

    return Scaffold(
      appBar: AppBar(
        title: Text(isGoal ? 'GOAL RESULT' : 'SPOT RESULT'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isGoal ? 'GOAL!' : 'Spot ${args.spotIndex + 1}',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    photoPath == null
                        // 発見者の写真をまだ取得できていない
                        ? const _PhotoPlaceholder()
                        : Image.file(
                          File(photoPath),
                          fit: BoxFit.contain,
                          // 協力プレイで共有に失敗すると、表示中に写真を捨てることがある
                          errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
                        ),
              ),
              const SizedBox(height: 16),
              if (isOthersDiscovery) ...[
                _InfoTile(
                  label: '発見者',
                  value: discovererLabel(
                    args.discovererDisplayName ?? checkpoint.discovererNickname,
                    isCleared: true,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (hasJudgement) _RankCard(rank: rank),
              const SizedBox(height: 16),
              _InfoTile(label: '名称', value: pointNameText),
              _InfoTile(label: 'ジャンル', value: genreText),
              if (hasJudgement) ...[
                _InfoTile(label: 'スポットまで残り', value: distanceErrorText),
                _InfoTile(label: '向きのずれ', value: headingErrorText),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: SpotResultMap(
                  missionPoint: point,
                  checkpoint: mapCheckpoint,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    point.googleMapsUrl == null
                        ? null
                        : () => _openGoogleMaps(context, point.googleMapsUrl!),
                child: const Text('Google Mapでスポットを確認する'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.pop(),
                child: Text(
                  args.closeLabel ??
                      (args.fromResultPage ? 'プレイ結果画面に戻る' : 'ミッション画面へ戻る'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildHeadingErrorText(double? degrees) {
    if (degrees == null) return '取得できませんでした';
    final abs = degrees.abs();
    if (abs < 0.05) return 'JUST!';
    final formatted = abs.toStringAsFixed(1);
    return degrees > 0 ? '右に$formatted度' : '左に$formatted度';
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

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) => const AspectRatio(
    aspectRatio: 4 / 3,
    child: ColoredBox(color: Colors.black12),
  );
}

class _RankCard extends StatelessWidget {
  const _RankCard({required this.rank});

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

    return Card(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('判定', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              rank.label,
              style: theme.textTheme.headlineMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(label), subtitle: Text(value)));
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.message, required this.isGoal});

  final String message;
  final bool isGoal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isGoal ? 'GOAL RESULT' : 'SPOT RESULT')),
      body: Center(child: Text(message)),
    );
  }
}
