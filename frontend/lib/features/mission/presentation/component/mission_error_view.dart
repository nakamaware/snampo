import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snampo/features/mission/presentation/component/map_top_bar.dart';

/// ミッションを読み込めなかったときの画面
///
/// 読み込み中の画面と同じく AppBar は置かず、戻るボタンとモードのボタンを浮かべる。
class MissionErrorView extends StatelessWidget {
  /// [MissionErrorView] を作成する
  const MissionErrorView({
    required this.onRetry,
    this.locationUnavailable = false,
    this.detail,
    this.actions = const [],
    super.key,
  });

  /// もう一度読み込む
  final VoidCallback onRetry;

  /// 現在地を取得できなかったか (位置情報をオンにする案内を出す)
  final bool locationUnavailable;

  /// エラーの詳細 (開発用。null なら出さない)
  final String? detail;

  /// 右上に並べるボタン (協力プレイのメニューなど)
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final detail = this.detail;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // AppBar がないので、明るい背景に合わせてステータスバーの文字を濃くする
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  32,
                  MapTopBar.height,
                  32,
                  32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      locationUnavailable
                          ? Icons.location_off_outlined
                          : Icons.cloud_off_outlined,
                      size: 56,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ミッションを始められませんでした',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      locationUnavailable
                          ? '端末の位置情報をオンにして、\nもう一度お試しください'
                          : '電波の良い場所で、もう一度お試しください',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: onRetry,
                      child: const Text('もう一度試す'),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        detail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            MapTopBar(actions: actions),
          ],
        ),
      ),
    );
  }
}
