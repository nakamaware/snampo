import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snampo/setup_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // runAppを呼び出す前にバインディングを初期化する.
  WidgetsFlutterBinding.ensureInitialized();
  // initStateの中には、書けないので、main関数の中で実行する.
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    await Geolocator.requestPermission();
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNAMPO',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 34, 255, 38)),
        textTheme:
            GoogleFonts.sawarabiGothicTextTheme(Theme.of(context).textTheme),
      ),
      home: const TopPage(),
    );
  }
}

class TopPage extends StatelessWidget {
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

class StartButton extends StatelessWidget {
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
          MaterialPageRoute(builder: (context) => SetupPage()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('START', style: style),
      ),
    );
  }
}

class HistoryButton extends StatelessWidget {
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
        print('button pressed!');
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('履歴', style: style),
      ),
    );
  }
}
