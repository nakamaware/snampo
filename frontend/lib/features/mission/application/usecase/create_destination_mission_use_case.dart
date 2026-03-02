import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/application/interface/mission_repository.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';

/// 目的地指定モードでミッション情報を取得するユースケース
class CreateDestinationMissionUseCase {
  /// CreateDestinationMissionUseCaseのコンストラクタ
  ///
  /// [_locationService] は位置情報サービス
  /// [_repository] はミッションリポジトリ
  CreateDestinationMissionUseCase(this._locationService, this._repository);

  final ILocationService _locationService;
  final IMissionRepository _repository;

  /// 目的地指定モードでミッション情報を取得する
  ///
  /// [destination] は目的地の座標
  Future<MissionEntity> call(Coordinate destination) async {
    try {
      // 現在位置を取得
      final currentLocation = await _locationService.getCurrentPosition();

      // ミッション情報を取得
      final missionInfo = await _repository.createDestinationMission(
        currentLocation: currentLocation,
        destination: destination,
      );

      return missionInfo;
    } catch (e) {
      throw Exception('ミッション情報の取得に失敗しました: $e');
    }
  }
}
