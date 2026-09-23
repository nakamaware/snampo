import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/coop/presentation/page/coop_entry_page.dart';
import 'package:snampo/features/coop/presentation/page/join_room_page.dart';
import 'package:snampo/features/coop/presentation/page/lobby_page.dart';
import 'package:snampo/features/coop/presentation/page/qr_scan_page.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/history/presentation/page/history_detail_page.dart';
import 'package:snampo/features/history/presentation/page/history_page.dart';
import 'package:snampo/features/home/presentation/page/home_page.dart';
import 'package:snampo/features/mission/domain/value_object/mission_session_kind.dart';
import 'package:snampo/features/mission/presentation/page/camera_page.dart';
import 'package:snampo/features/mission/presentation/page/mission_page.dart';
import 'package:snampo/features/mission/presentation/page/result_page.dart';
import 'package:snampo/features/mission/presentation/page/setup_page.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';
import 'package:snampo/features/settings/presentation/page/settings_page.dart';

/// ルーティング設定
final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
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
        GoRoute(path: 'lobby', builder: (context, state) => const LobbyPage()),
        GoRoute(
          path: 'mission',
          builder: (context, state) => const _CoopMissionRoute(),
        ),
        GoRoute(
          path: 'result',
          builder:
              (context, state) =>
                  const ResultPage(kind: MissionSessionKind.coop),
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

/// 端末で進行中のルームの Mission 画面
class _CoopMissionRoute extends ConsumerWidget {
  const _CoopMissionRoute();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(coopSessionStoreProvider).value;
    final code = session == null ? null : RoomCode.tryParse(session.roomCode);
    if (code == null) {
      return const LobbyPage();
    }
    return MissionPage.coop(roomCode: code.value);
  }
}
