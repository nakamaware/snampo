import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snampo/core/storage/photo_storage.dart';

/// 写真ストレージの実装
///
/// アプリのドキュメントディレクトリ配下の専用サブディレクトリに写真をコピーして永続化する。
/// カメラ撮影後は一時ディレクトリに保存されるため、アプリ再起動時に削除されないようここにコピーする。
/// 削除時は保存用ディレクトリ配下のパスのみを対象とし、想定外のパスによる誤削除を防ぐ。
class PhotoStorage implements IPhotoStorage {
  static const _photoDirectoryName = 'mission_photos';

  /// 写真保存用の専用ディレクトリを取得する。
  ///
  /// アプリのドキュメントディレクトリ配下に `mission_photos` サブディレクトリを用意し、
  /// 存在しない場合は作成してから返す。
  Future<Directory> _photoDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/$_photoDirectoryName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  @override
  Future<String> savePhoto(String sourcePath, int checkpointIndex) async {
    final dir = await _photoDirectory();
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
    // 保存用ディレクトリ配下のパスのみ削除対象とする（壊れた進捗データ等による誤削除を防ぐ）
    // normalize + absolute で `.../mission_photos/../` などのパストラバーサルを潰してから判定する
    final dir = await _photoDirectory();
    final dirPath = normalize(absolute(dir.path));
    final targetPath = normalize(absolute(path));
    final expectedPrefix = '$dirPath${Platform.pathSeparator}';
    if (!targetPath.startsWith(expectedPrefix)) {
      return;
    }
    final file = File(targetPath);
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } on FileSystemException {
      // 削除失敗は無視（clearProgress が他ファイルの削除を続けられる）
    }
  }
}
