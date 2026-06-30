import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Street View 画像 (base64) をファイルとして永続化する
class StreetViewStorage {
  static const _directoryName = 'history_streetview';

  Future<Directory> _storageDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, _directoryName));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  /// base64 JPEG を `{historyId}_spot{sortOrder}.jpg` として保存し、絶対パスを返す
  Future<String> saveBase64Image({
    required String historyId,
    required int sortOrder,
    required String imageBase64,
  }) async {
    final dir = await _storageDirectory();
    final fileName = '${historyId}_spot$sortOrder.jpg';
    final file = File(p.join(dir.path, fileName));
    final bytes = base64Decode(imageBase64);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  /// [saveBase64Image] で保存した 1 ファイルをパスで削除する
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

  /// 履歴 id に紐づく Street View ファイルをすべて削除する
  Future<void> deleteForHistory(String historyId) async {
    final dir = await _storageDirectory();
    final prefix = '${historyId}_spot';
    final deleteErrors = <FileSystemException>[];
    for (final entity in dir.listSync()) {
      if (entity is! File) {
        continue;
      }
      final name = p.basename(entity.path);
      if (name.startsWith(prefix) && name.endsWith('.jpg')) {
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
