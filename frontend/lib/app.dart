import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snampo/core/routing/app_router.dart';

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
