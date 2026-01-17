import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/models/game_session.dart';
import 'package:snampo/models/walk_history.dart';
import 'package:snampo/presentation/controllers/game_session_controller.dart';
import 'package:snampo/presentation/controllers/walk_history_controller.dart';

/// ミッション完了後の結果を表示するページ
///
/// resultpageに遷移する時にバグるので要修正
class ResultPage extends StatelessWidget {
  /// ResultPageのコンストラクタ
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleTextstyle = (theme.textTheme.displayMedium ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final textstyleLarge = (theme.textTheme.displayLarge ??
            theme.textTheme.headlineLarge ??
            const TextStyle())
        .copyWith(
      color: theme.colorScheme.primary,
    );
    final textstyleMid = (theme.textTheme.bodyLarge ??
            theme.textTheme.bodyMedium ??
            const TextStyle())
        .copyWith(
      color: theme.colorScheme.primary,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RESULT',
          style: titleTextstyle,
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GOAL!!',
              style: textstyleLarge,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Congratulations!',
              style: textstyleMid,
            ),
            const SizedBox(
              height: 20,
            ),
            const HomeButton(),
          ],
        ),
      ),
    );
  }
}

/// ホームに戻るボタンウィジェット
class HomeButton extends ConsumerWidget {
  /// HomeButtonのコンストラクタ
  const HomeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textstyle = (theme.textTheme.displayMedium ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary, //ボタンの背景色
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      onPressed: () async {
        // ゲームセッションを取得して履歴に保存
        final session = await ref.read(gameSessionControllerProvider.future);
        if (session != null && session.status == GameStatus.completed) {
          try {
            final history = WalkHistory.fromGameSession(session);
            await ref
                .read(walkHistoryControllerProvider.notifier)
                .addHistory(history);
          } catch (_) {
            // 履歴の保存に失敗しても続行
          }
        }

        // ゲームセッションと写真状態をクリア
        await ref.read(gameSessionControllerProvider.notifier).clearSession();
        ref.invalidate(hasSavedSessionProvider);
        if (context.mounted) {
          context.go('/');
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('ホーム', style: textstyle),
      ),
    );
  }
}
