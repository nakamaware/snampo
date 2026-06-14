import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 履歴用ユーザー写真をファイルとして永続化する
class HistoryPhotoStorage {
  static const _directoryName = 'history_photos';

  Future<Directory> _storageDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, _directoryName));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  /// ミッション進行中の写真を `{historyId}_spot{sortOrder}{ext}` としてコピーし、絶対パスを返す
  ///
  /// コピー元が存在しない場合は null を返す。
  Future<String?> copyUserPhoto({
    required String historyId,
    required int sortOrder,
    required String sourcePath,
  }) async {
    final source = File(sourcePath);
    if (!source.existsSync()) {
      return null;
    }
    final dir = await _storageDirectory();
    final ext = p.extension(sourcePath);
    final fileName = '${historyId}_spot$sortOrder$ext';
    final dest = File(p.join(dir.path, fileName));
    await source.copy(dest.path);
    return dest.path;
  }

  /// [copyUserPhoto] で保存した 1 ファイルをパスで削除する
  Future<void> delete(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    } on FileSystemException {
      // 続行
    }
  }

  /// 履歴 id に紐づくユーザー写真ファイルをすべて削除する
  Future<void> deleteForHistory(String historyId) async {
    final dir = await _storageDirectory();
    final prefix = '${historyId}_spot';
    final deleteErrors = <FileSystemException>[];
    for (final entity in dir.listSync()) {
      if (entity is! File) {
        continue;
      }
      final name = p.basename(entity.path);
      if (name.startsWith(prefix)) {
        try {
          await entity.delete();
        } on FileSystemException catch (e) {
          deleteErrors.add(e);
        }
      }
    }
    if (deleteErrors.isNotEmpty) {
      throw deleteErrors.first;
    }
  }
}
