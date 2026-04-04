import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 写真確認画面の引数
class PhotoConfirmPageArgs {
  /// PhotoConfirmPageArgsのコンストラクタ
  const PhotoConfirmPageArgs({
    required this.referenceImageBase64,
    required this.capturedPhotoPath,
  });

  /// 正解画像
  final String referenceImageBase64;

  /// 撮影画像のパス
  final String capturedPhotoPath;
}

/// 撮影写真の確認画面
class PhotoConfirmPage extends StatelessWidget {
  /// PhotoConfirmPageのコンストラクタ
  const PhotoConfirmPage({required this.args, super.key});

  /// 画面引数
  final PhotoConfirmPageArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final referenceBytes = base64Decode(args.referenceImageBase64);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PHOTO CHECK'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('撮り直しますか？', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              Expanded(
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
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.pop(false),
                child: const Text('撮り直す'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.pop(true),
                child: const Text('Guess'),
              ),
            ],
          ),
        ),
      ),
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
