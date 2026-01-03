import 'package:go_router/go_router.dart';
import 'package:snampo/features/home/presentation/page/home_page.dart';
import 'package:snampo/features/mission/presentation/page/mission_page.dart';
import 'package:snampo/features/mission/presentation/page/result_page.dart';
import 'package:snampo/features/mission/presentation/page/setup_page.dart';

/// ルーティング設定
final GoRouter appRouter = GoRouter(
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
        final radius = double.parse(state.pathParameters['radius']!);
        return MissionPage(radius: radius);
      },
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) => const ResultPage(),
    ),
  ],
);
