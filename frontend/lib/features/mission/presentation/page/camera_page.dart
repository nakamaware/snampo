import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// カメラページウィジェット。
class CameraPage extends StatefulWidget {
  /// [CameraPage] ウィジェットを作成します。
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  // エラーを表示する共通メソッド
  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 枠外をタップしても閉じないようにする
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('エラー'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('戻る'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
                Navigator.of(context).pop(); // カメラ画面も閉じる
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        await _showErrorDialog('カメラが見つかりませんでした。');
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false, // 音声録音をしない
      );

      await _controller!.initialize();

      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      var message = 'カメラの起動に失敗しました。';
      if (e.code == 'CameraAccessDenied') {
        message = 'カメラへのアクセスが拒否されています。設定から許可してください。';
      }
      await _showErrorDialog(message);
    } catch (e) {
      if (!mounted) return;
      // その他の予期せぬエラー
      await _showErrorDialog('予期せぬエラーが発生しました: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final textstyle = (theme.textTheme.displaySmall ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.onPrimary);

    return Scaffold(
      appBar: AppBar(
        title: Text('Take SNAP', style: textstyle),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        // カメラプレビューを表示
        child: CameraPreview(_controller!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final image = await _controller!.takePicture();
            if (!context.mounted) return;
            Navigator.pop(context, image); // 撮影した画像を返す
          } catch (e) {
            await _showErrorDialog('写真の撮影に失敗しました。');
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
      // 撮影ボタンの位置を中央に設定
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
