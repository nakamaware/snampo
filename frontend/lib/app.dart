import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snampo/presentation/pages/history_detail_page.dart';
import 'package:snampo/presentation/pages/history_list_page.dart';
import 'package:snampo/presentation/pages/home_page.dart';
import 'package:snampo/presentation/pages/mission_page.dart';
import 'package:snampo/presentation/pages/result_page.dart';
import 'package:snampo/presentation/pages/setup_page.dart';

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
      routerConfig: _router,
    );
  }
}

/// ルーティング設定
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupPage(),
    ),
    GoRoute(
      path: '/mission/:radius',
      builder: (context, state) {
        final radiusParam = state.pathParameters['radius']!;
        // 「resume」の場合は保存データから復元
        if (radiusParam == 'resume') {
          return const MissionPage(radius: 0, isResume: true);
        }
        final radius = double.parse(radiusParam);
        return MissionPage(radius: radius);
      },
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) => const ResultPage(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryListPage(),
    ),
    GoRoute(
      path: '/history/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return HistoryDetailPage(historyId: id);
      },
    ),
  ],
);
