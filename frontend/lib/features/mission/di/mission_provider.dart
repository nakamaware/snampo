import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/application/interface/mission_repository.dart';
import 'package:snampo/features/mission/application/usecase/get_mission_use_case.dart';
import 'package:snampo/features/mission/data/location_service.dart';
import 'package:snampo/features/mission/data/mission_repository.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';

part 'mission_provider.g.dart';

/// 位置情報サービスのプロバイダー
@riverpod
ILocationService locationService(Ref ref) {
  return LocationService();
}

/// 現在位置を取得するプロバイダー
@riverpod
Future<Coordinate> currentPosition(Ref ref) async {
  final locationService = ref.read(locationServiceProvider);
  return locationService.getCurrentPosition();
}

/// ミッションリポジトリのプロバイダー
@riverpod
IMissionRepository missionRepository(Ref ref) {
  return MissionRepository();
}

/// ミッション情報を取得するユースケースのプロバイダー
@riverpod
GetMissionUseCase getMissionUseCase(Ref ref) {
  return GetMissionUseCase(
    ref.read(locationServiceProvider),
    ref.read(missionRepositoryProvider),
  );
}
