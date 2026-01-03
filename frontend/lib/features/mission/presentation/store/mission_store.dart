import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/application/usecase/get_current_location_use_case.dart';
import 'package:snampo/features/mission/application/usecase/get_mission_use_case.dart';
import 'package:snampo/features/mission/data/location_service.dart';
import 'package:snampo/features/mission/data/mission_repository.dart';
import 'package:snampo/features/mission/domain/mission_model.dart';

part 'mission_store.g.dart';

/// ミッションリポジトリのプロバイダー
@riverpod
MissionRepository missionRepository(MissionRepositoryRef ref) {
  return MissionRepository();
}

/// 現在地を取得するユースケースのプロバイダー
@riverpod
GetCurrentLocationUseCase getCurrentLocationUseCase(
  GetCurrentLocationUseCaseRef ref,
) {
  return GetCurrentLocationUseCase(LocationService());
}

/// ミッション情報を取得するユースケースのプロバイダー
@riverpod
GetMissionUseCase getMissionUseCase(GetMissionUseCaseRef ref) {
  return GetMissionUseCase(
    ref.read(getCurrentLocationUseCaseProvider),
    ref.read(missionRepositoryProvider),
  );
}

/// ミッション情報を管理するストア
@riverpod
class MissionNotifier extends _$MissionNotifier {
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
      final useCase = ref.read(getMissionUseCaseProvider);
      final missionInfo = await useCase.call(radius);
      state = AsyncValue.data(missionInfo);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// 目的地を取得するプロバイダー
@riverpod
MidPointEntity? target(TargetRef ref) {
  final mission = ref.watch(missionNotifierProvider).value;
  return mission?.destination;
}

/// ルートのポリライン文字列を取得するプロバイダー
@riverpod
String? route(RouteRef ref) {
  final mission = ref.watch(missionNotifierProvider).value;
  return mission?.overviewPolyline;
}

/// 中間地点のリストを取得するプロバイダー
@riverpod
List<MidPointEntity>? midpointInfoList(MidpointInfoListRef ref) {
  final mission = ref.watch(missionNotifierProvider).value;
  return mission?.midpoints;
}
