import 'package:snampo/features/mission/application/interface/heading_service.dart';

/// 現在方角を取得するユースケース
class GetCurrentHeadingUseCase {
  /// GetCurrentHeadingUseCaseのコンストラクタ
  GetCurrentHeadingUseCase(this._headingService);

  final IHeadingService _headingService;

  /// 現在方角を取得する
  Future<double?> call() async {
    return _headingService.getCurrentHeading();
  }
}
