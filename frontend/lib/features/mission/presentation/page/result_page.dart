import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        backgroundColor: theme.colorScheme.primary, //ボタンの背景色
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      onPressed: () {
        context.go('/');
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('ホーム', style: textstyle),
      ),
    );
  }
}
