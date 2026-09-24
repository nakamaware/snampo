import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:snampo/features/mission/presentation/component/map_top_bar.dart';

/// ミッションを読み込んでいる間の画面
///
/// ミッションの画面と同じく AppBar は置かず、戻るボタンだけを浮かべる。
class MissionLoadingView extends StatelessWidget {
  /// [MissionLoadingView] を作成する
  const MissionLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // AppBar がないので、明るい背景に合わせてステータスバーの文字を濃くする
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: colorScheme.primary,
                      size: 56,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ミッションを準備しています',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ルートとスポットを探しています',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const MapTopBar(),
          ],
        ),
      ),
    );
  }
}
