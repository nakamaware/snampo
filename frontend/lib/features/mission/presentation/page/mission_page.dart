import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';
import 'package:snampo/features/mission/presentation/store/camera_store.dart';
import 'package:snampo/features/mission/presentation/store/mission_store.dart';
import 'package:snampo/features/mission/presentation/util/polyline_util.dart';

/// ミッションページを表示するウィジェット
class MissionPage extends HookConsumerWidget {
  /// ミッションページを作成する
  ///
  /// [radius] はミッションの検索半径（メートル単位）
  MissionPage({required int radius, super.key})
    : _radius = Radius(meters: radius);

  /// ミッションの検索半径
  final Radius _radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('MissionPage build');
    final theme = Theme.of(context);
    final textstyle = (theme.textTheme.displaySmall ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.onPrimary);

    final missionAsyncValue = ref.watch(missionStoreProvider(_radius));

    return missionAsyncValue.when(
      data: (missionInfo) {
        return Scaffold(
          appBar: AppBar(
            title: Text('On MISSION', style: textstyle),
            centerTitle: true,
            backgroundColor: theme.colorScheme.primary,
          ),
          body: Stack(
            children: [
              MapView(currentLocation: missionInfo.departure, radius: _radius),
              SnapView(radius: _radius),
            ],
          ),
        );
      },
      loading:
          () => Scaffold(
            appBar: AppBar(
              title: Text('On MISSION', style: textstyle),
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
            title: Text('On MISSION', style: textstyle),
            centerTitle: true,
            backgroundColor: theme.colorScheme.primary,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const Text('エラーが発生しました'), Text('$error')],
            ),
          ),
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
  /// [radius] はミッションの検索半径
  const MapView({
    required this.currentLocation,
    required this.radius,
    super.key,
  });

  /// 現在位置の座標情報
  final Coordinate currentLocation;

  /// ミッションの検索半径
  final Radius radius;

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

/// MapViewの状態を管理するクラス
class _MapViewState extends ConsumerState<MapView> {
  /// マップの表示制御用
  late GoogleMapController mapController;

  /// ポリラインの座標リスト
  final List<LatLng> _polylineCoordinates = [];
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.watch(missionStoreProvider(widget.radius)).whenData((missionInfo) {
      final encodedPolyline = missionInfo.overviewPolyline;
      if (encodedPolyline.isNotEmpty && _polylineCoordinates.isEmpty) {
        final coordinates = decodePolyline(encodedPolyline);
        if (coordinates.isNotEmpty) {
          _polylineCoordinates.addAll(coordinates);

          if (mounted) {
            setState(() {
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId('poly'),
                  points: _polylineCoordinates,
                  color: Colors.blue,
                  width: 3,
                ),
              );
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 画面の幅と高さを決定する
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final missionAsyncValue = ref.watch(missionStoreProvider(widget.radius));
    final missionInfo = missionAsyncValue.value;
    if (missionInfo == null) {
      return const SizedBox.shrink();
    }

    final target = missionInfo.destination;
    final currentLat = widget.currentLocation.latitude;
    final currentLng = widget.currentLocation.longitude;

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
                    target.coordinate.latitude,
                    target.coordinate.longitude,
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

/// mission_pageで表示するsnapのメニューウィジェット
class SnapView extends StatelessWidget {
  /// SnapViewウィジェットのコンストラクタ
  const SnapView({required this.radius, super.key});

  /// ミッションの検索半径
  final Radius radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      // 初期の表示割合
      initialChildSize: 0.15,
      // 最小の表示割合
      minChildSize: 0.15,
      // snapで止める時の割合
      snapSizes: const [0.15, 0.6, 1.0],
      builder: (BuildContext context, ScrollController scrollController) {
        return ColoredBox(
          color: theme.colorScheme.surface,
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      SnapViewState(radius: radius),
                    ],
                  ),
                ),
              ),
              IgnorePointer(
                child: ColoredBox(
                  color: theme.colorScheme.surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        height: 10,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// SnapView内でミッション情報を表示するウィジェット
class SnapViewState extends ConsumerWidget {
  /// SnapViewStateウィジェットのコンストラクタ
  const SnapViewState({required this.radius, super.key});

  /// ミッションの検索半径
  final Radius radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final titelTextstyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.secondary,
    );
    final buttonTextstyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final missionAsyncValue = ref.watch(missionStoreProvider(radius));

    return missionAsyncValue.when(
      data: (missionInfo) {
        final midpointInfoList = missionInfo.waypoints;
        final destination = missionInfo.destination;

        return Column(
          children: [
            Text('MISSION', style: titelTextstyle),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('- Spot1: '),
                if (midpointInfoList.isNotEmpty)
                  AnswerImage(imageBase64: midpointInfoList[0].imageBase64)
                else
                  const SizedBox(width: 150, height: 150),
                const TakeSnap(spotIndex: 0),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('- Spot2: '),
                AnswerImage(imageBase64: destination.imageBase64),
                const TakeSnap(spotIndex: 1),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, // ボタンの背景色
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  // 形を変えるか否か
                  borderRadius: BorderRadius.circular(10), // 角の丸み
                ),
              ),
              onPressed: () {
                context.push('/result');
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('到着', style: buttonTextstyle),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('エラーが発生しました: $error')),
    );
  }
}

/// Base64エンコードされた画像データを表示するウィジェット
class AnswerImage extends StatelessWidget {
  /// AnswerImageウィジェットのコンストラクタ
  ///
  /// [imageBase64] Base64エンコードされた画像データの文字列
  const AnswerImage({required this.imageBase64, super.key});

  /// Base64エンコードされた画像データの文字列
  final String imageBase64;

  @override
  Widget build(BuildContext context) {
    final imageUint8 = base64Decode(imageBase64);
    return SizedBox(
      width: 150,
      height: 150,
      child: FittedBox(
        // child: Image.asset(picture_name),
        child: Image.memory(
          imageUint8,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// 写真を撮影するためのボタンを表示するウィジェット
class TakeSnap extends HookConsumerWidget {
  /// TakeSnapウィジェットのコンストラクタ
  ///
  /// [spotIndex] 写真を撮影するスポットのインデックス
  const TakeSnap({required this.spotIndex, super.key});

  /// 写真を撮影するスポットのインデックス
  final int spotIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // cameraStoreProvider を監視
    final cameraPath = ref.watch(
      cameraStoreProvider.select((map) => map[spotIndex]),
    );

    if (cameraPath == null) {
      return FloatingActionButton(
        heroTag: 'take_snap_spot_$spotIndex',
        onPressed: () => _handleCameraCapture(context, ref),
        child: const Icon(Icons.add_a_photo),
      );
    }

    return SizedBox(
      width: 150,
      height: 150,
      child: SetImage(picture: File(cameraPath)),
    );
  }

  Future<void> _handleCameraCapture(BuildContext context, WidgetRef ref) async {
    // カメラ画面へ遷移
    final capturedFile = await context.push<XFile?>('/camera');

    if (capturedFile != null && context.mounted) {
      final path = capturedFile.path;
      ref.read(cameraStoreProvider.notifier).savePhoto(spotIndex, path);
    }
  }
}

/// ファイルから読み込んだ画像を表示するウィジェット
class SetImage extends StatelessWidget {
  /// SetImageウィジェットのコンストラクタ
  ///
  /// [picture] 表示する画像ファイル
  const SetImage({
    // required this.picture_name,
    required this.picture,
    super.key,
  });
  // final String picture_name;
  /// 表示する画像ファイル
  final File picture;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      // child: Image.asset(picture_name),
      child: Image.file(picture),
    );
  }
}

/// アセットから読み込んだ画像を表示するウィジェット
class SetTestImage extends StatelessWidget {
  // final File picture;
  /// SetTestImageウィジェットのコンストラクタ
  ///
  /// [picture] 表示する画像のアセットパス
  const SetTestImage({
    // required this.picture_name,
    required this.picture,
    super.key,
  });

  /// 表示する画像のアセットパス
  final String picture;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: FittedBox(
        // child: Image.asset(picture_name),
        child: Image.asset(picture),
      ),
    );
  }
}
