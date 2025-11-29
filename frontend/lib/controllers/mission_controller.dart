import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/config/env.dart';
import 'package:snampo/location_model.dart';

part 'mission_controller.g.dart';

/// ミッション情報を管理するコントローラー
@riverpod
class MissionController extends _$MissionController {
  @override
  Future<LocationModel> build() async {
    throw UnimplementedError('loadMission を呼び出してください');
  }

  /// ミッション情報を取得する
  ///
  /// [radius] はミッションの検索半径（キロメートル単位）
  Future<void> loadMission(double radius) async {
    state = const AsyncValue.loading();

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final dio = Dio();
      final radiusString =
          (radius * 1000).toInt().toString(); // km から m にし整数値の文字列に
      final url = '${Env.apiBaseUrl}/route/';
      final response = await dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {
          'currentLat': position.latitude.toString(),
          'currentLng': position.longitude.toString(),
          'radius': radiusString,
        },
      );
      final jsonData = response.data!;
      final missionInfo = LocationModel.fromJson(jsonData);
      state = AsyncValue.data(missionInfo);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// 目的地を取得するプロバイダー
@riverpod
LocationPoint? target(TargetRef ref) {
  final mission = ref.watch(missionControllerProvider).value;
  return mission?.destination;
}

/// ルートのポリライン文字列を取得するプロバイダー
@riverpod
String? route(RouteRef ref) {
  final mission = ref.watch(missionControllerProvider).value;
  return mission?.overviewPolyline;
}

/// 中間地点のリストを取得するプロバイダー
@riverpod
List<MidPoint>? midpointInfoList(MidpointInfoListRef ref) {
  final mission = ref.watch(missionControllerProvider).value;
  return mission?.midpoints;
}
