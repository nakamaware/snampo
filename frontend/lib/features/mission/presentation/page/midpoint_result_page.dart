import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:url_launcher/url_launcher.dart';

/// MidPointResultPage の引数
class MidPointResultPageArgs {
  /// MidPointResultPageArgs のコンストラクタ
  const MidPointResultPageArgs({
    required this.midPointIndex,
    required this.totalCheckpointCount,
    required this.missionPoint,
    required this.checkpoint,
  });

  /// MidPoint のインデックス
  final int midPointIndex;

  /// 全チェックポイント数
  final int totalCheckpointCount;

  /// 表示対象の地点情報
  final ImageCoordinate missionPoint;

  /// 表示対象の進捗情報
  final CheckpointProgress checkpoint;
}

/// MidPoint単位の採点結果画面
class MidPointResultPage extends StatelessWidget {
  /// MidPointResultPageのコンストラクタ
  const MidPointResultPage({required this.args, super.key});

  /// 画面引数
  final MidPointResultPageArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkpoint = args.checkpoint;
    final isGoal = args.midPointIndex == args.totalCheckpointCount - 1;
    if (checkpoint.userPhotoPath == null) {
      return _ErrorScaffold(message: '採点結果を表示できませんでした。', isGoal: isGoal);
    }

    final point = args.missionPoint;
    final rank = checkpoint.judgeRank ?? PhotoJudgeRank.retry;
    final distanceErrorText =
        checkpoint.distanceErrorMeters == null
            ? '取得できませんでした'
            : '${checkpoint.distanceErrorMeters!.toStringAsFixed(1)} m';
    final headingErrorText =
        checkpoint.headingErrorDegrees == null
            ? '取得できませんでした'
            : '${checkpoint.headingErrorDegrees!.toStringAsFixed(1)} deg';

    return Scaffold(
      appBar: AppBar(
        title: Text(isGoal ? 'GOAL RESULT' : 'MIDPOINT RESULT'),
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
                isGoal ? 'GOAL!' : 'MidPoint ${args.midPointIndex + 1}',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(checkpoint.userPhotoPath!),
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              _RankCard(rank: rank),
              const SizedBox(height: 16),
              _InfoTile(label: '名称', value: point.name ?? '取得できませんでした'),
              _InfoTile(label: 'ジャンル', value: point.genre ?? '取得できませんでした'),
              _InfoTile(label: '位置誤差', value: distanceErrorText),
              _InfoTile(label: '方角誤差', value: headingErrorText),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        point.coordinate.latitude,
                        point.coordinate.longitude,
                      ),
                      zoom: 16,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('midpoint'),
                        position: LatLng(
                          point.coordinate.latitude,
                          point.coordinate.longitude,
                        ),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                  ),
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
                onPressed: () {
                  if (isGoal) {
                    context.go('/result');
                    return;
                  }
                  context.pop();
                },
                child: Text(isGoal ? 'プレイ全体の結果を見る' : 'ミッション画面へ戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google Map を開けませんでした')));
      }
    }
  }
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
      PhotoJudgeRank.retry => Colors.red,
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
      appBar: AppBar(title: Text(isGoal ? 'GOAL RESULT' : 'MIDPOINT RESULT')),
      body: Center(child: Text(message)),
    );
  }
}
