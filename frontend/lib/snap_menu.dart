// mission_pageで表示するsnapのメニュー
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snampo/provider.dart';
import 'package:snampo/result_page.dart';

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
      // 最大の表示割合
      maxChildSize: 0.6,
      // ドラッグを離した時に一番近いsnapSizeになるか
      snap: true,
      // snapで止める時の割合
      snapSizes: const [0.15, 0.6],
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
    final midpointInfoList = ref.read(midpointInfoListProvider.notifier).state;
    // print("snap_menu_image is");
    // print(GlobalVariables.midpointInfoList[0].imageUtf8);
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
            AnswerImage(imageUtf8: midpointInfoList![0].imageUtf8!),
            const TakeSnap(),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('- Spot2: '),
            SetTestImage(
              picture: 'images/test1.jpeg',
            ),
            TakeSnap(),
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
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (context) => const ResultPage()),
            );
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
