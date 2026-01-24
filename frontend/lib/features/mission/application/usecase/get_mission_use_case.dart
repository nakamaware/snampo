import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/application/interface/mission_repository.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

/// ミッション情報を取得するユースケース
class GetMissionUseCase {
  /// GetMissionUseCaseのコンストラクタ
  ///
  /// [_locationService] は位置情報サービス
  /// [_repository] はミッションリポジトリ
  GetMissionUseCase(this._locationService, this._repository);

  final ILocationService _locationService;
  final IMissionRepository _repository;

  /// ミッション情報を取得する
  ///
  /// [radius] はミッションの検索半径 (ランダムモード用、目的地指定時は null)
  /// [destination] は目的地の座標 (目的地指定モード用、ランダムモード時は null)
  Future<MissionEntity> call({Radius? radius, Coordinate? destination}) async {
    try {
      // 現在位置を取得
      final currentLocation = await _locationService.getCurrentPosition();

      // ミッション情報を取得
      final missionInfo = await _repository.getMission(
        radius: radius,
        currentLocation: currentLocation,
        destination: destination,
      );

      return missionInfo;
    } catch (e) {
      throw Exception('ミッション情報の取得に失敗しました: $e');
    }
  }
}
