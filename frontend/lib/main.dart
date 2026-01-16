import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snampo/core/router.dart';

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
    return MaterialApp.router(
      title: 'SNAMPO',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 34, 255, 38),
        ),
        textTheme:
            GoogleFonts.sawarabiGothicTextTheme(Theme.of(context).textTheme),
      ),
      routerConfig: appRouter,
    );
  }
}
