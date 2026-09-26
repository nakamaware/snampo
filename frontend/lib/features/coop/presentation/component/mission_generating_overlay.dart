import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// ミッション生成中のローディング演出 (Tips で待ち時間を補う)
class MissionGeneratingOverlay extends HookWidget {
  /// [MissionGeneratingOverlay] を作成する
  const MissionGeneratingOverlay({required this.message, super.key});

  static const _tips = [
    'スポットの写真と同じ場所・同じ向きで撮ると高評価!',
    '誰かがスポットを見つけると、全員の画面でクリアになります',
    '手分けして探すと早く見つかるかも',
    '電波が途切れても、復帰したら発見を送信します',
    '途中で抜けても、見つけたスポットは履歴に残ります',
  ];

  /// 表示する文言
  final String message;

  @override
  Widget build(BuildContext context) {
    final tipIndex = useState(0);
    useEffect(() {
      final timer = Timer.periodic(
        const Duration(seconds: 4),
        (_) => tipIndex.value = (tipIndex.value + 1) % _tips.length,
      );
      return timer.cancel;
    }, const []);
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface.withValues(alpha: 0.92),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingAnimationWidget.staggeredDotsWave(
                color: theme.colorScheme.primary,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(message, style: theme.textTheme.titleLarge),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  'Tips: ${_tips[tipIndex.value]}',
                  key: ValueKey(tipIndex.value),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
