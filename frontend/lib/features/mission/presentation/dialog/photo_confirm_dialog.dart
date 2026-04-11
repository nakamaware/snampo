import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// 写真確認ダイアログの引数
class PhotoConfirmDialogArgs {
  /// PhotoConfirmDialogArgsのコンストラクタ
  const PhotoConfirmDialogArgs({
    required this.referenceImageBase64,
    required this.capturedPhotoPath,
  });

  /// 正解画像
  final String referenceImageBase64;

  /// 撮影画像のパス
  final String capturedPhotoPath;
}

/// 撮影写真の確認ダイアログ
class PhotoConfirmDialog extends StatelessWidget {
  /// PhotoConfirmDialogのコンストラクタ
  const PhotoConfirmDialog({required this.args, super.key});

  /// ダイアログ引数
  final PhotoConfirmDialogArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final referenceBytes = base64Decode(args.referenceImageBase64);

    return AlertDialog(
      insetPadding: const EdgeInsets.all(16),
      title: Text('撮り直しますか？', style: theme.textTheme.titleMedium),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Expanded(
              child: _PreviewCard(
                title: 'Mission Photo',
                child: Image.memory(referenceBytes, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _PreviewCard(
                title: 'Your Photo',
                child: Image.file(
                  File(args.capturedPhotoPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('撮り直す'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Guess'),
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(title, style: theme.textTheme.titleSmall),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
