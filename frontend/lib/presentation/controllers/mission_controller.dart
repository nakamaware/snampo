import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/data/repositories/mission_repository_impl.dart';
import 'package:snampo/domain/entities/location_entity.dart';
import 'package:snampo/domain/repositories/mission_repository.dart';

part 'mission_controller.g.dart';

/// ミッションリポジトリのプロバイダー
@riverpod
MissionRepository missionRepository(MissionRepositoryRef ref) {
  return MissionRepositoryImpl();
}

/// ミッション情報を管理するコントローラー
@riverpod
class MissionController extends _$MissionController {
  @override
  Future<LocationEntity> build() async {
    throw UnimplementedError('loadMission を呼び出してください');
  }

  /// ミッション情報を取得する
  ///
  /// [radius] はミッションの検索半径（キロメートル単位）
  Future<void> loadMission(double radius) async {
    state = const AsyncValue.loading();

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final repository = ref.read(missionRepositoryProvider);
      final missionInfo = await repository.getMission(
        radius: radius,
        currentLat: position.latitude,
        currentLng: position.longitude,
      );
      state = AsyncValue.data(missionInfo);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// 目的地を取得するプロバイダー
@riverpod
LocationPointEntity? target(TargetRef ref) {
  final mission = ref.watch(missionControllerProvider).value;
  return mission?.destination;
}

/// ルートのポリライン文字列を取得するプロバイダー
@riverpod
String? route(RouteRef ref) {
  final mission = ref.watch(missionControllerProvider).value;
  return mission?.overviewPolyline;
}

/// 中間地点のリストを取得するプロバイダー
@riverpod
List<MidPointEntity>? midpointInfoList(MidpointInfoListRef ref) {
  final mission = ref.watch(missionControllerProvider).value;
  return mission?.midpoints;
}
