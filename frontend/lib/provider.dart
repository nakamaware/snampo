import 'package:snampo/location_model.dart';

/// アプリケーション全体で使用するグローバル変数
class GlobalVariables {
  /// 目標地点
  static late LocationPoint target;

  /// ルート情報
  static late String route;

  /// 中間地点情報のリスト
  static late List<MidPoint> midpointInfoList;
}
