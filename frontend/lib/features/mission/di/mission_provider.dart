import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_sqflite/riverpod_sqflite.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/application/interface/mission_repository.dart';
import 'package:snampo/features/mission/application/interface/photo_storage.dart';
import 'package:snampo/features/mission/application/usecase/create_destination_mission_use_case.dart';
import 'package:snampo/features/mission/application/usecase/create_random_mission_use_case.dart';
import 'package:snampo/features/mission/application/usecase/get_current_position_use_case.dart';
import 'package:snampo/features/mission/application/usecase/save_photo_use_case.dart';
import 'package:snampo/features/mission/data/location_service.dart';
import 'package:snampo/features/mission/data/mission_repository.dart';
import 'package:snampo/features/mission/data/photo_storage.dart';
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

/// 現在位置を取得するユースケースのプロバイダー
@riverpod
GetCurrentPositionUseCase getCurrentPositionUseCase(Ref ref) {
  return GetCurrentPositionUseCase(ref.read(locationServiceProvider));
}

/// 写真ストレージのプロバイダー
@riverpod
IPhotoStorage photoStorage(Ref ref) {
  return PhotoStorage();
}

/// 写真を保存するユースケースのプロバイダー
@riverpod
SavePhotoUseCase savePhotoUseCase(Ref ref) {
  return SavePhotoUseCase(ref.read(photoStorageProvider));
}
