import 'package:go_router/go_router.dart';
import 'package:snampo/features/home/presentation/page/home_page.dart';
import 'package:snampo/features/mission/presentation/page/camera_page.dart';
import 'package:snampo/features/mission/presentation/page/mission_page.dart';
import 'package:snampo/features/mission/presentation/page/result_page.dart';
import 'package:snampo/features/mission/presentation/page/setup_page.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';

HomePage _homeWithError(String message) {
  return HomePage(errorMessage: message);
}

/// ルーティング設定
final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/setup', builder: (context, state) => const SetupPage()),
    GoRoute(
      path: '/mission/random/:radius',
      builder: (context, state) {
        final meters = int.tryParse(state.pathParameters['radius'] ?? '');
        if (meters == null) {
          return _homeWithError('無効なリンクです');
        }
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
          return _homeWithError('無効なリンクです');
        }
        return CameraPage(args: extra);
      },
    ),
    GoRoute(
      path: '/spot-result',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! SpotResultPageArgs) {
          return _homeWithError('無効なリンクです');
        }
        return SpotResultPage(args: extra);
      },
    ),
    GoRoute(
      path: '/mission/destination/:lat/:lng',
      builder: (context, state) {
        final lat = double.tryParse(state.pathParameters['lat'] ?? '');
        final lng = double.tryParse(state.pathParameters['lng'] ?? '');
        if (lat == null || lng == null) {
          return _homeWithError('無効なリンクです');
        }
        return MissionPage.withDestination(
          destinationLat: lat,
          destinationLng: lng,
        );
      },
    ),
    GoRoute(path: '/result', builder: (context, state) => const ResultPage()),
  ],
  errorBuilder: (context, state) {
    return _homeWithError('存在しないページです');
  },
);
