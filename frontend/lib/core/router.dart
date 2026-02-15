import 'package:go_router/go_router.dart';
import 'package:snampo/core/shell/main_shell.dart';
import 'package:snampo/features/history/presentation/page/history_page.dart';
import 'package:snampo/features/map/presentation/page/map_page.dart';
import 'package:snampo/features/mission/presentation/page/camera_page.dart';
import 'package:snampo/features/mission/presentation/page/mission_page.dart';
import 'package:snampo/features/mission/presentation/page/result_page.dart';
import 'package:snampo/features/mission/presentation/page/setup_page.dart';
import 'package:snampo/features/profile/presentation/page/profile_page.dart';

/// ルーティング設定
final GoRouter appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder:
          (context, state, navigationShell) =>
              MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const SetupPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/map', builder: (context, state) => const MapPage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/mission/:radius',
      builder: (context, state) {
        final radius = int.parse(state.pathParameters['radius']!);
        return MissionPage(radius: radius);
      },
    ),
    GoRoute(path: '/camera', builder: (context, state) => const CameraPage()),
    GoRoute(
      path: '/mission/destination/:lat/:lng',
      builder: (context, state) {
        final lat = double.parse(state.pathParameters['lat']!);
        final lng = double.parse(state.pathParameters['lng']!);
        return MissionPage.withDestination(
          destinationLat: lat,
          destinationLng: lng,
        );
      },
    ),
    GoRoute(path: '/result', builder: (context, state) => const ResultPage()),
  ],
);
