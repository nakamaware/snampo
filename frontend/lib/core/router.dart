import 'package:go_router/go_router.dart';
import 'package:snampo/features/coop/presentation/page/coop_entry_page.dart';
import 'package:snampo/features/coop/presentation/page/coop_mission_page.dart';
import 'package:snampo/features/coop/presentation/page/coop_result_page.dart';
import 'package:snampo/features/coop/presentation/page/join_room_page.dart';
import 'package:snampo/features/coop/presentation/page/lobby_page.dart';
import 'package:snampo/features/coop/presentation/page/qr_scan_page.dart';
import 'package:snampo/features/history/presentation/page/history_detail_page.dart';
import 'package:snampo/features/history/presentation/page/history_page.dart';
import 'package:snampo/features/home/presentation/page/home_page.dart';
import 'package:snampo/features/mission/presentation/page/camera_page.dart';
import 'package:snampo/features/mission/presentation/page/mission_page.dart';
import 'package:snampo/features/mission/presentation/page/result_page.dart';
import 'package:snampo/features/mission/presentation/page/setup_page.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';
import 'package:snampo/features/settings/presentation/page/settings_page.dart';

/// ルーティング設定
final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      // 協力プレイのルームの画面は、ホームの上に積む。「みんなで」の上に積むと、戻ったときに
      // 下に画面がなく、戻るボタンが消えて Android の戻るでアプリが閉じてしまう
      routes: [
        GoRoute(
          path: 'coop/lobby',
          builder: (context, state) => const LobbyPage(),
        ),
        GoRoute(
          path: 'coop/mission',
          builder: (context, state) => const CoopMissionPage(),
        ),
        GoRoute(
          path: 'coop/result',
          builder: (context, state) => const CoopResultPage(),
        ),
      ],
    ),
    GoRoute(path: '/setup', builder: (context, state) => const SetupPage()),
    GoRoute(
      path: '/mission/random/:radius',
      builder: (context, state) {
        final meters = int.parse(state.pathParameters['radius']!);
        return MissionPage(radius: meters);
      },
    ),
    GoRoute(
      path: '/mission',
      builder: (context, state) => const MissionPage.resume(),
    ),
    GoRoute(
      path: '/camera',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! CameraPageArgs) {
          return const HomePage();
        }
        return CameraPage(args: extra);
      },
    ),
    GoRoute(
      path: '/spot-result',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! SpotResultPageArgs) {
          return const HomePage();
        }
        return SpotResultPage(args: extra);
      },
    ),
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
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    // 協力プレイ (deep link は #270 で扱う)
    GoRoute(
      path: '/coop',
      builder: (context, state) => const CoopEntryPage(),
      routes: [
        GoRoute(
          path: 'join',
          builder: (context, state) => const JoinRoomPage(),
          routes: [
            GoRoute(
              path: 'scan',
              builder: (context, state) => const QrScanPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return HistoryDetailPage(recordId: id);
          },
        ),
      ],
    ),
  ],
);
