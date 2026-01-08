import 'package:snampo/features/mission/application/interface/mission_repository_interface.dart';
import 'package:snampo/features/mission/application/usecase/get_current_location_use_case.dart';
import 'package:snampo/features/mission/domain/mission_model.dart';

/// ミッション情報を取得するユースケース
class GetMissionUseCase {
  /// GetMissionUseCaseのコンストラクタ
  ///
  /// [getCurrentLocationUseCase] は現在地を取得するユースケース
  /// [repository] はミッションリポジトリ
  GetMissionUseCase(
    this._getCurrentLocationUseCase,
    this._repository,
  );

  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final MissionRepositoryInterface _repository;

  /// ミッション情報を取得する
  ///
  /// [radius] はミッションの検索半径（キロメートル単位）
  Future<RouteEntity> call(double radius) async {
    // 現在位置を取得
    final position = await _getCurrentLocationUseCase.call();

    // ミッション情報を取得
    final missionInfo = await _repository.getMission(
      radius: radius,
      currentLat: position.latitude,
      currentLng: position.longitude,
    );

    return missionInfo;
  }
}
