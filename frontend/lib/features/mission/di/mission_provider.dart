import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/application/interface/mission_repository.dart';
import 'package:snampo/features/mission/application/usecase/create_destination_mission_use_case.dart';
import 'package:snampo/features/mission/application/usecase/create_random_mission_use_case.dart';
import 'package:snampo/features/mission/data/location_service.dart';
import 'package:snampo/features/mission/data/mission_repository.dart';
part 'mission_provider.g.dart';

/// 位置情報サービスのプロバイダー
@riverpod
ILocationService locationService(Ref ref) {
  return LocationService();
}

/// ミッションリポジトリのプロバイダー
@riverpod
IMissionRepository missionRepository(Ref ref) {
  return MissionRepository();
}

/// ランダムモードでミッション情報を取得するユースケースのプロバイダー
@riverpod
CreateRandomMissionUseCase createRandomMissionUseCase(Ref ref) {
  return CreateRandomMissionUseCase(
    ref.read(locationServiceProvider),
    ref.read(missionRepositoryProvider),
  );
}

/// 目的地指定モードでミッション情報を取得するユースケースのプロバイダー
@riverpod
CreateDestinationMissionUseCase createDestinationMissionUseCase(Ref ref) {
  return CreateDestinationMissionUseCase(
    ref.read(locationServiceProvider),
    ref.read(missionRepositoryProvider),
  );
}
