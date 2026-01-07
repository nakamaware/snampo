import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/presentation/controllers/game_session_controller.dart';

/// アプリケーションのトップページ
class HomePage extends ConsumerWidget {
  /// HomePageのコンストラクタ
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSavedSession = ref.watch(hasSavedSessionProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: Image.asset('images/snampo.png', fit: BoxFit.contain),
            ),
            const SizedBox(
              height: 20,
            ),
            const StartButton(),
            const SizedBox(height: 10),
            // 保存されたセッションがある場合のみ「続きから」ボタンを表示
            hasSavedSession.when(
              data: (hasSession) =>
                  hasSession ? const ResumeButton() : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 10),
            const HistoryButton(),
          ],
        ),
      ),
    );
  }
}

/// スタートボタンウィジェット
class StartButton extends StatelessWidget {
  /// StartButtonのコンストラクタ
  const StartButton({
    super.key,
  });

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

/// 続きからボタンウィジェット
class ResumeButton extends StatelessWidget {
  /// ResumeButtonのコンストラクタ
  const ResumeButton({
    super.key,
  });

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
      onPressed: () {
        context.push('/mission/resume');
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('続きから', style: style),
      ),
    );
  }
}

/// 履歴ボタンウィジェット
class HistoryButton extends StatelessWidget {
  /// HistoryButtonのコンストラクタ
  const HistoryButton({
    super.key,
  });

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
