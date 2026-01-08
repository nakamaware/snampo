import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/application/usecase/get_current_location_use_case.dart';
import 'package:snampo/features/mission/application/usecase/get_mission_use_case.dart';
import 'package:snampo/features/mission/data/location_service.dart';
import 'package:snampo/features/mission/data/mission_repository.dart';
import 'package:snampo/features/mission/domain/mission_model.dart';

part 'mission_store.g.dart';

// ============================================================================
// 依存関係プロバイダー（Dependency Providers）
// ============================================================================
// リポジトリやユースケースなどの依存関係を提供する関数プロバイダー

/// ミッションリポジトリのプロバイダー
@riverpod
MissionRepository missionRepository(Ref ref) {
  return MissionRepository();
}

/// 現在地を取得するユースケースのプロバイダー
@riverpod
GetCurrentLocationUseCase getCurrentLocationUseCase(Ref ref) {
  return GetCurrentLocationUseCase(LocationService());
}

/// ミッション情報を取得するユースケースのプロバイダー
@riverpod
GetMissionUseCase getMissionUseCase(Ref ref) {
  return GetMissionUseCase(
    ref.read(getCurrentLocationUseCaseProvider),
    ref.read(missionRepositoryProvider),
  );
}

// ============================================================================
// 状態管理（State Management）
// ============================================================================
// アプリケーションの状態を管理するNotifierクラス

/// ミッション情報を管理するストア
@riverpod
class MissionNotifier extends _$MissionNotifier {
  @override
  Future<RouteEntity> build() async {
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

// ============================================================================
// 計算プロバイダー（Computed Providers）
// ============================================================================
// 他のプロバイダーから値を計算して返す関数プロバイダー

/// 目的地を取得するプロバイダー
@riverpod
MidPointEntity? target(Ref ref) {
  final mission = ref.watch(missionProvider).value;
  return mission?.destination;
}

/// ルートのポリライン文字列を取得するプロバイダー
@riverpod
String? route(Ref ref) {
  final mission = ref.watch(missionProvider).value;
  return mission?.overviewPolyline;
}

/// 中間地点のリストを取得するプロバイダー
@riverpod
List<MidPointEntity>? midpointInfoList(Ref ref) {
  final mission = ref.watch(missionProvider).value;
  return mission?.midpoints;
}
