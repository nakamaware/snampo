import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/features/mission/presentation/store/mission_store.dart';

/// アプリケーションのトップページ
class HomePage extends ConsumerWidget {
  /// HomePageのコンストラクタ
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionAsync = ref.watch(missionStoreProvider);
    final hasSavedMission = missionAsync.value != null;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: Image.asset('images/snampo.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 20),
            if (hasSavedMission) ...[
              const ResumeButton(),
              const SizedBox(height: 10),
            ],
            const StartButton(),
            const SizedBox(height: 10),
            const HistoryButton(),
          ],
        ),
      ),
    );
  }
}

/// 保存されたミッションを再開するボタン
class ResumeButton extends StatelessWidget {
  const ResumeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
      ),
      onPressed: () => context.push('/mission'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('再開', style: style),
      ),
    );
  }
}

/// スタートボタンウィジェット
class StartButton extends StatelessWidget {
  /// StartButtonのコンストラクタ
  const StartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary, //ボタンの背景色
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      onPressed: () {
        context.push('/setup');
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('START', style: style),
      ),
    );
  }
}

/// 履歴ボタンウィジェット
class HistoryButton extends StatelessWidget {
  /// HistoryButtonのコンストラクタ
  const HistoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary, // ボタンの背景色
        foregroundColor: theme.colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          // 形を変えるか否か
          borderRadius: BorderRadius.circular(10), // 角の丸み
        ),
      ),
      onPressed: () {
        // TODO(kawayama): 履歴機能を実装する
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('履歴', style: style),
      ),
    );
  }
}
