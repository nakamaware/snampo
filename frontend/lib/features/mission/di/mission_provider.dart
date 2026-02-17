import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_sqflite/riverpod_sqflite.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/application/interface/mission_repository.dart';
import 'package:snampo/features/mission/application/usecase/get_mission_use_case.dart';
import 'package:snampo/features/mission/data/location_service.dart';
import 'package:snampo/features/mission/data/mission_repository.dart';
import 'package:sqflite/sqflite.dart';

part 'mission_provider.g.dart';

/// SQLite ストレージのプロバイダー (keepAlive で DB 接続を維持)
@Riverpod(keepAlive: true)
Future<JsonSqFliteStorage> storage(Ref ref) async {
  final databasesPath = await getDatabasesPath();
  final dbPath = join(databasesPath, 'snampo.db');
  final storage = await JsonSqFliteStorage.open(dbPath);
  ref.onDispose(storage.close);
  return storage;
}

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

/// ミッション情報を取得するユースケースのプロバイダー
@riverpod
GetMissionUseCase getMissionUseCase(Ref ref) {
  return GetMissionUseCase(
    ref.read(locationServiceProvider),
    ref.read(missionRepositoryProvider),
  );
}
