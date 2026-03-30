import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/history/presentation/store/history_store.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

/// ミッション完了後の結果を表示するページ
///
/// resultpageに遷移する時にバグるので要修正
class ResultPage extends HookConsumerWidget {
  /// ResultPageのコンストラクタ
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 到着画面が初めて表示されたタイミングで1回だけ
    // 履歴保存・永続ミッションと進捗をクリアする
    useEffect(() {
      Future(() async {
        final mission = await ref.read(persistedMissionProvider.future);
        final progress = await ref.read(missionProgressStoreProvider.future);
        final historyNotifier = ref.read(historyStoreProvider.notifier);
        final progressNotifier = ref.read(
          missionProgressStoreProvider.notifier,
        );
        final persistedNotifier = ref.read(persistedMissionProvider.notifier);
        try {
          if (mission != null && progress != null) {
            historyNotifier.addHistory(mission, progress);
          }
        } finally {
          progressNotifier.resetState();
          persistedNotifier.clearMission();
        }
      });
      return null;
    }, const []);

    final theme = Theme.of(context);
    final titleTextStyle = (theme.textTheme.displayMedium ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.onPrimary);
    final textStyleLarge = (theme.textTheme.displayLarge ??
            theme.textTheme.headlineLarge ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.primary);
    final textStyleMid = (theme.textTheme.bodyLarge ??
            theme.textTheme.bodyMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.primary);

    return Scaffold(
      appBar: AppBar(
        title: Text('RESULT', style: titleTextStyle),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('GOAL!!', style: textStyleLarge),
            const SizedBox(height: 20),
            Text('Congratulations!', style: textStyleMid),
            const SizedBox(height: 20),
            const HomeButton(),
          ],
        ),
      ),
    );
  }
}

/// ホームに戻るボタンウィジェット
class HomeButton extends StatelessWidget {
  /// HomeButtonのコンストラクタ
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = (theme.textTheme.displayMedium ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.onPrimary);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      onPressed: () => context.go('/'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('ホーム', style: textStyle),
      ),
    );
  }
}
