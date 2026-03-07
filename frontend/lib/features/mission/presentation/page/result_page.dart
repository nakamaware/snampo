import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/mission/presentation/store/mission_store.dart';

/// ミッション完了後の結果を表示するページ
///
/// resultpageに遷移する時にバグるので要修正
class ResultPage extends HookConsumerWidget {
  /// ResultPageのコンストラクタ
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 到着画面が初めて表示されたタイミングで1回だけ missionStore をクリアする（ビルド完了後に遅延実行）
    useEffect(() {
      Future(() {
        ref.read(missionStoreProvider.notifier).clearMission();
      });
      return null;
    }, const []);

    final theme = Theme.of(context);
    final titleTextstyle = (theme.textTheme.displayMedium ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.onPrimary);
    final textstyleLarge = (theme.textTheme.displayLarge ??
            theme.textTheme.headlineLarge ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.primary);
    final textstyleMid = (theme.textTheme.bodyLarge ??
            theme.textTheme.bodyMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.primary);

    return Scaffold(
      appBar: AppBar(
        title: Text('RESULT', style: titleTextstyle),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('GOAL!!', style: textstyleLarge),
            const SizedBox(height: 20),
            Text('Congratulations!', style: textstyleMid),
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
    final textstyle = (theme.textTheme.displayMedium ??
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
        child: Text('ホーム', style: textstyle),
      ),
    );
  }
}
