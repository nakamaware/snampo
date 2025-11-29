import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:snampo/config/env.dart';
import 'package:snampo/location_model.dart';
import 'package:snampo/provider.dart';
import 'package:snampo/snap_menu.dart';

/// ミッションページを表示するウィジェット
class MissionPage extends HookConsumerWidget {
  /// ミッションページを作成する
  ///
  /// [radius] はミッションの検索半径（キロメートル単位）
  const MissionPage({required this.radius, super.key});

  /// ミッションの検索半径（キロメートル単位）
  final double radius;

  /// 現在位置を取得し、APIからミッション情報を取得する
  ///
  /// 現在の位置情報を取得し、指定された半径内でミッション情報を
  /// サーバーから取得して[LocationModel]として返す
  Future<LocationModel> makeMission() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final dio = Dio();
    final radiusString =
        (radius * 1000).toInt().toString(); // km から m にし整数値の文字列に
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.apiBaseUrl}/route/',
      queryParameters: {
        'currentLat': position.latitude.toString(),
        'currentLng': position.longitude.toString(),
        'radius': radiusString,
      },
    );
    final jsonData = response.data!;
    final missionInfo = LocationModel.fromJson(jsonData);
    return missionInfo;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textstyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    // final future = useMemoized(getCurrentLocation);
    final future = useMemoized(makeMission);
    final snapshot = useFuture(future);

    if (snapshot.hasData && snapshot.data != null) {
      final missionInfo = snapshot.data!;
      ref.read(targetProvider.notifier).state = missionInfo.destination;
      ref.read(routeProvider.notifier).state = missionInfo.overviewPolyline;
      ref.read(midpointInfoListProvider.notifier).state = missionInfo.midpoints;

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'On MISSION',
            style: textstyle,
          ),
          centerTitle: true,
          backgroundColor: theme.colorScheme.primary,
        ),
        body: Stack(
          children: [
            MapView(currentLocation: missionInfo.departure!),
            const SnapView(),
          ],
        ),
      );
    } else if (snapshot.hasError) {
      return const Center(
        child: Text('error occurred'),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'On MISSION',
            style: textstyle,
          ),
          centerTitle: true,
          backgroundColor: theme.colorScheme.primary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.blue,
                size: 100,
              ),
              const Text('NOW LOADING'),
            ],
          ),
        ),
      );
    }
  }
}

/// Googleマップを表示するウィジェット
class MapView extends ConsumerStatefulWidget {
  /// MapViewを作成する
  ///
  /// [currentLocation] は現在位置の座標情報
  const MapView({required this.currentLocation, super.key});

  /// 現在位置の座標情報
  final LocationPoint currentLocation;

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

/// MapViewの状態を管理するクラス
class _MapViewState extends ConsumerState<MapView> {
  /// マップの表示制御用
  late GoogleMapController mapController;

  /// ポリラインの座標リスト
  List<LatLng> polylineCoordinates = [];
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    final encodedPolyline = ref.read(routeProvider.notifier).state!;
    _decodePolyline(encodedPolyline);
  }

  Future<void> _decodePolyline(String encodedPolyline) async {
    final result = PolylinePoints().decodePolyline(encodedPolyline);
    if (result.isNotEmpty) {
      for (final point in result) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('poly'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 3,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 画面の幅と高さを決定する
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final target = ref.read(targetProvider.notifier).state!;

    return SizedBox(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                //マップの初期位置を指定
                zoom: 17, //ズーム
                target: LatLng(
                  //緯度, 経度
                  widget.currentLocation.latitude!,
                  widget.currentLocation.longitude!,
                ),
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('marker_1'),
                  position: LatLng(
                    target.latitude!,
                    target.longitude!,
                  ),
                ),
              },
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
          ],
        ),
      ),
    );
  }
}
