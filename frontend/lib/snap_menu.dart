// mission_pageで表示するsnapのメニュー
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snampo/result_page.dart';
import 'package:snampo/provider.dart';
import 'dart:convert';
import 'dart:developer';

class SnapView extends StatelessWidget {
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
        return Container(
          color: theme.colorScheme.background,
          child: Stack(
            children: [
              Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        SnapViewState(),
                      ],
                    ),
                  )),
              IgnorePointer(
                child: Container(
                  color: theme.colorScheme.background,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        height: 10,
                        width: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey),
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

class SnapViewState extends StatelessWidget {
  const SnapViewState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titelTextstyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.secondary,
    );
    final buttonTextstyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    print("snap_menu_image is");
    print(GlobalVariables.midpointInfoList[0].imageUtf8);
    return Column(
      children: [
        Text(
          "MISSION",
          style: titelTextstyle,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("- Spot1: "),
            AnswerImage(
                imageUtf8: GlobalVariables.midpointInfoList[0].imageUtf8!),
            TakeSnap(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("- Spot2: "),
            SetTestImage(
              picture: "images/test1.jpeg",
            ),
            TakeSnap(),
          ],
        ),
        SizedBox(
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
              MaterialPageRoute(builder: (context) => ResultPage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('到着', style: buttonTextstyle),
          ),
        ),
      ],
    );
  }
}

class AnswerImage extends StatelessWidget {
  final String imageUtf8;
  const AnswerImage({
    required this.imageUtf8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    log("answer image utf8 is");
    log(imageUtf8);
    Uint8List imageUint8 = base64Decode(imageUtf8);
    print("imageUint8 is");
    print(imageUint8);
    return Container(
      child: FittedBox(
        fit: BoxFit.contain,
        // child: Image.asset(picture_name),
        child: Image.memory(
          imageUint8,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
      width: 150,
      height: 150,
    );
  }
}

class TakeSnap extends StatefulWidget {
  const TakeSnap({
    super.key,
  });

  @override
  State<TakeSnap> createState() => _TakeSnapState();
}

class _TakeSnapState extends State<TakeSnap> {
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
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
            child: Icon(Icons.add_a_photo),
          )
        : Container(
            child: SetImage(
              // picture_name: "images/test1.jpeg",
              picture: _image!,
            ),
            width: 150,
            height: 150,
          );
  }
}

class SetImage extends StatelessWidget {
  // final String picture_name;
  final File picture;
  const SetImage({
    // required this.picture_name,
    required this.picture,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      // child: Image.asset(picture_name),
      child: Image.file(picture),
    );
  }
}

class SetTestImage extends StatelessWidget {
  final String picture;
  // final File picture;
  const SetTestImage({
    // required this.picture_name,
    required this.picture,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FittedBox(
        fit: BoxFit.contain,
        // child: Image.asset(picture_name),
        child: Image.asset(picture),
      ),
      width: 150,
      height: 150,
    );
  }
}
