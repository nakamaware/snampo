import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:snampo/features/mission/domain/mission_model.dart';
import 'package:snampo/features/mission/presentation/store/mission_store.dart';

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

    final missionAsync = ref.watch(missionProvider);

    // radiusが変更されたときにミッションを読み込む（ビルド後に実行）
    useEffect(
      () {
        Future.microtask(() {
          ref.read(missionProvider.notifier).loadMission(radius);
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
  final LocationEntity currentLocation;

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

/// mission_pageで表示するsnapのメニューウィジェット
class SnapView extends StatelessWidget {
  /// SnapViewウィジェットのコンストラクタ
  const SnapView({
    super.key,
  });

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
                  child: const Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      SnapViewState(),
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
  const SnapViewState({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final titelTextstyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.secondary,
    );
    final buttonTextstyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final midpointInfoList = ref.watch(midpointInfoListProvider);
    final destination = ref.watch(targetProvider);

    // データがまだ読み込まれていない場合はローディング表示
    if (midpointInfoList == null || midpointInfoList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Text(
          'MISSION',
          style: titelTextstyle,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('- Spot1: '),
            if (midpointInfoList.isNotEmpty &&
                midpointInfoList[0].imageUtf8 != null)
              AnswerImage(imageUtf8: midpointInfoList[0].imageUtf8!)
            else
              const SizedBox(width: 150, height: 150),
            const TakeSnap(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('- Spot2: '),
            if (destination != null && destination.imageUtf8 != null)
              AnswerImage(imageUtf8: destination.imageUtf8!)
            else
              const SizedBox(width: 150, height: 150),
            const TakeSnap(),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
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
  }
}

/// Base64エンコードされた画像データを表示するウィジェット
class AnswerImage extends StatelessWidget {
  /// AnswerImageウィジェットのコンストラクタ
  ///
  /// [imageUtf8] Base64エンコードされた画像データの文字列
  const AnswerImage({
    required this.imageUtf8,
    super.key,
  });

  /// Base64エンコードされた画像データの文字列
  final String imageUtf8;

  @override
  Widget build(BuildContext context) {
    log('answer image utf8 is');
    log(imageUtf8);
    final imageUint8 = base64Decode(imageUtf8);
    log('imageUint8 is');
    log(imageUint8.toString());
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
class TakeSnap extends StatefulWidget {
  /// TakeSnapウィジェットのコンストラクタ
  const TakeSnap({
    super.key,
  });

  @override
  State<TakeSnap> createState() => _TakeSnapState();
}

class _TakeSnapState extends State<TakeSnap> {
  File? _image;
  final picker = ImagePicker();

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _image == null
        ? FloatingActionButton(
            onPressed: getImage,
            child: const Icon(Icons.add_a_photo),
          )
        : SizedBox(
            width: 150,
            height: 150,
            child: SetImage(
              // picture_name: "images/test1.jpeg",
              picture: _image!,
            ),
          );
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
