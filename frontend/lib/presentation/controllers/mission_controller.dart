import 'package:geolocator/geolocator.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/models/game_session.dart';
import 'package:snampo/models/location_entity.dart';
import 'package:snampo/presentation/controllers/game_session_controller.dart';
import 'package:snampo/repositories/mission_repository.dart';

part 'mission_controller.g.dart';

/// ミッションリポジトリのプロバイダー
@riverpod
MissionRepository missionRepository(Ref ref) {
  return MissionRepository();
}

/// ミッション情報を管理するコントローラー
@riverpod
class MissionController extends _$MissionController {
  @override
  Future<LocationEntity> build() async {
    throw UnimplementedError('loadMission または loadSavedSession を呼び出してください');
  }

  /// ミッション情報を取得する
  ///
  /// [radius] はミッションの検索半径（キロメートル単位）
  Future<void> loadMission(double radius) async {
    state = const AsyncValue.loading();

    try {
      // 新規ゲームなので既存のセッションと写真をクリア
      await ref.read(gameSessionControllerProvider.notifier).clearSession();

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final repository = ref.read(missionRepositoryProvider);
      final missionInfo = await repository.getMission(
        radius: radius,
        currentLat: position.latitude,
        currentLng: position.longitude,
      );

      // ゲームセッションを保存
      final session = GameSession(
        locationEntity: missionInfo,
        radius: radius,
        startedAt: DateTime.now(),
        status: GameStatus.inProgress,
      );
      await ref
          .read(gameSessionControllerProvider.notifier)
          .saveSession(session);

      state = AsyncValue.data(missionInfo);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 保存されたセッションからミッション情報を復元する
  Future<void> loadSavedSession() async {
    state = const AsyncValue.loading();

    try {
      final session = await ref.read(gameSessionControllerProvider.future);

      if (session == null || session.status != GameStatus.inProgress) {
        throw Exception('再開可能なゲームがありません');
      }

      state = AsyncValue.data(session.locationEntity);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// 目的地を取得するプロバイダー
@riverpod
MidPointEntity? target(Ref ref) {
  final mission = ref.watch(missionControllerProvider).value;
  return mission?.destination;
}

/// ルートのポリライン文字列を取得するプロバイダー
@riverpod
String? route(Ref ref) {
  final mission = ref.watch(missionControllerProvider).value;
  return mission?.overviewPolyline;
}

/// 中間地点のリストを取得するプロバイダー
@riverpod
List<MidPointEntity>? midpointInfoList(Ref ref) {
  final mission = ref.watch(missionControllerProvider).value;
  return mission?.midpoints;
}
