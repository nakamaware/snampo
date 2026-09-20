import 'package:flutter/material.dart';

/// ピンチズーム付きで画像を全画面表示する
class HistoryFullscreenImageViewer extends StatelessWidget {
  /// [HistoryFullscreenImageViewer] を作成する
  const HistoryFullscreenImageViewer({required this.child, super.key});

  /// 表示する画像ウィジェット (例: [Image.file], [Image.memory])
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(minScale: 0.5, maxScale: 4, child: child),
        ),
      ),
    );
  }
}
