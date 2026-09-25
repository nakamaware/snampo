import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snampo/features/history/presentation/component/history_fullscreen_image_viewer.dart';

/// 履歴の写真のサムネイル。タップで全画面表示する
///
/// 見本も撮った写真も正方形なので、列の幅に合わせた正方形で切らずに見せる。
class HistoryPhotoThumbnail extends StatelessWidget {
  /// [HistoryPhotoThumbnail] を作成する
  const HistoryPhotoThumbnail({this.path, super.key});

  /// 写真のパス。null や空なら、画像がないことを示す
  final String? path;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(builder: _buildContent),
    );
  }

  Widget _buildContent(BuildContext context, BoxConstraints constraints) {
    final theme = Theme.of(context);
    final resolvedPath = path;
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: theme.colorScheme.outline,
          size: 40,
        ),
      ),
    );
    if (resolvedPath == null || resolvedPath.isEmpty) return placeholder;

    final file = File(resolvedPath);
    // 幅だけを指定して縦横比を保つ (両方を指定すると、正方形でない写真が歪む)
    final cacheWidth =
        (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context)).round();

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              fullscreenDialog: true,
              builder:
                  (_) => HistoryFullscreenImageViewer(
                    child: Image.file(
                      file,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white54,
                            size: 64,
                          ),
                        );
                      },
                    ),
                  ),
            ),
          );
        },
        child: Image.file(
          file,
          fit: BoxFit.cover,
          cacheWidth: cacheWidth,
          errorBuilder: (_, __, ___) => placeholder,
        ),
      ),
    );
  }
}
