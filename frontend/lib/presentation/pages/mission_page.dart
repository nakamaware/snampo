import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:snampo/models/location_entity.dart';
import 'package:snampo/presentation/controllers/mission_controller.dart';
import 'package:snampo/presentation/controllers/mission_page_widgets.dart';

/// ミッションページを表示するウィジェット
class MissionPage extends HookConsumerWidget {
  /// ミッションページを作成する
  ///
  /// [radius] はミッションの検索半径（キロメートル単位）
  const MissionPage({required this.radius, super.key});

  /// ミッションの検索半径（キロメートル単位）
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('MissionPage build');
    final theme = Theme.of(context);
    final textstyle = (theme.textTheme.displaySmall ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(
      color: theme.colorScheme.onPrimary,
    );

    final missionAsync = ref.watch(missionControllerProvider);

    // radiusが変更されたときにミッションを読み込む（ビルド後に実行）
    useEffect(
      () {
        Future.microtask(() {
          ref.read(missionControllerProvider.notifier).loadMission(radius);
        });
        return null;
      },
      [radius],
    );

    return missionAsync.when(
      data: (missionInfo) {
        if (missionInfo.departure == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'On MISSION',
                style: textstyle,
              ),
              centerTitle: true,
              backgroundColor: theme.colorScheme.primary,
            ),
            body: const Center(child: Text('出発地点の情報が取得できませんでした')),
          );
        }

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
      },
      loading: () => Scaffold(
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
      ),
      error: (error, stackTrace) {
        log('error: $error');
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'On MISSION',
              style: textstyle,
            ),
            centerTitle: true,
            backgroundColor: theme.colorScheme.primary,
          ),
          body: const Center(child: Text('error occurred')),
        );
      },
    );
  }
}

/// Googleマップを表示するウィジェット
class MapView extends ConsumerStatefulWidget {
  /// MapViewを作成する
  ///
  /// [currentLocation] は現在位置の座標情報
  const MapView({required this.currentLocation, super.key});

  /// 現在位置の座標情報
  final LocationPointEntity currentLocation;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final encodedPolyline = ref.read(routeProvider);
    if (encodedPolyline != null && polylineCoordinates.isEmpty) {
      _decodePolyline(encodedPolyline);
    }
  }

  Future<void> _decodePolyline(String encodedPolyline) async {
    final result = PolylinePoints().decodePolyline(encodedPolyline);
    if (result.isNotEmpty) {
      for (final point in result) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    // 画面の幅と高さを決定する
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final target = ref.watch(targetProvider);
    final currentLat = widget.currentLocation.latitude;
    final currentLng = widget.currentLocation.longitude;

    // 必要な値がnullの場合はローディング表示
    if (target == null ||
        currentLat == null ||
        currentLng == null ||
        target.latitude == null ||
        target.longitude == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
                  currentLat,
                  currentLng,
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
