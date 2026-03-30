import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// ローカルファイルの画像をピンチズーム付きで全画面表示する
void openHistoryFullscreenImageFromFile(BuildContext context, String path) {
  if (!File(path).existsSync()) {
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder:
          (ctx) => _HistoryFullscreenImageScaffold(
            child: Image.file(File(path), fit: BoxFit.contain),
          ),
    ),
  );
}

/// メモリ上の画像をピンチズーム付きで全画面表示する
void openHistoryFullscreenImageFromBytes(
  BuildContext context,
  Uint8List bytes,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder:
          (ctx) => _HistoryFullscreenImageScaffold(
            child: Image.memory(bytes, fit: BoxFit.contain),
          ),
    ),
  );
}

class _HistoryFullscreenImageScaffold extends StatelessWidget {
  const _HistoryFullscreenImageScaffold({required this.child});

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
