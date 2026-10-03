import 'package:snampo/features/mission/application/interface/location_service.dart';

/// 現在地を取得できない理由を直すための、設定画面を開くユースケース
class OpenLocationSettingsUseCase {
  /// [OpenLocationSettingsUseCase] を作成する
  ///
  /// [_locationService] は位置情報サービス
  OpenLocationSettingsUseCase(this._locationService);

  final ILocationService _locationService;

  /// [reason] に合った設定画面を開く
  Future<void> call(LocationUnavailableReason reason) =>
      _locationService.openSettings(reason);
}
