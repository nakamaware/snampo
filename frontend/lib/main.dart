import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snampo/setup_page.dart';

void main() async {
  // runAppを呼び出す前にバインディングを初期化する.
  WidgetsFlutterBinding.ensureInitialized();
  // initStateの中には、書けないので、main関数の中で実行する.
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    await Geolocator.requestPermission();
  }
  runApp(const ProviderScope(child: MyApp()));
}

/// アプリケーションのルートウィジェット
class MyApp extends StatelessWidget {
  /// MyAppのコンストラクタ
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNAMPO',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 34, 255, 38),
        ),
        textTheme:
            GoogleFonts.sawarabiGothicTextTheme(Theme.of(context).textTheme),
      ),
      home: const TopPage(),
    );
  }
}

/// アプリケーションのトップページ
class TopPage extends StatelessWidget {
  /// TopPageのコンストラクタ
  const TopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.secondary,
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'スナんぽ',
              style: style,
            ),
            const SizedBox(
              height: 20,
            ),
            const StartButton(),
            const SizedBox(height: 10), // 2つの間を空ける
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
        Navigator.push(
          context,
          MaterialPageRoute<Widget>(builder: (context) => const SetupPage()),
        );
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
