import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snampo/features/mission/application/interface/photo_storage.dart';

/// 写真ストレージの実装
///
/// アプリのドキュメントディレクトリに写真をコピーして永続化する。
/// カメラ撮影後は一時ディレクトリに保存されるため、アプリ再起動時に削除されないようここにコピーする。
class PhotoStorage implements IPhotoStorage {
  @override
  Future<String> savePhoto(String sourcePath, int checkpointIndex) async {
    // アプリのドキュメントディレクトリを取得（OS が削除しない永続領域）
    final dir = await getApplicationDocumentsDirectory();
    final ext = extension(sourcePath);
    // ファイル名: snampo_cp{インデックス}_{タイムスタンプ}.{拡張子}
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'snampo_cp${checkpointIndex}_$timestamp$ext';
    final savedPath = '${dir.path}/$fileName';
    await File(sourcePath).copy(savedPath);
    return savedPath;
  }

  @override
  Future<void> deletePhoto(String path) async {
    // ミッション完了時に保存した写真を削除してストレージを解放する
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
