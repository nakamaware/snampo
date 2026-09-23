import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:snampo/features/coop/application/interface/pending_clear_repository.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';

/// 共有しきれていない発見のキューを JSON ファイルとして端末に保存する (キルされても消えない)
class PendingClearRepository implements IPendingClearRepository {
  /// [PendingClearRepository] を作成する
  ///
  /// [file] は保存先のファイル (テスト用。既定はアプリのサポートディレクトリ)。
  PendingClearRepository({Future<File> Function()? file})
    : _file = file ?? _defaultFile;

  static const _fileName = 'coop_pending_clear_queue.json';

  static Future<File> _defaultFile() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }

  final Future<File> Function() _file;

  /// 実行中の更新 (更新を 1 つずつ順番に行うため)
  Future<void> _pending = Future.value();

  @override
  Future<PendingClearQueue> load() async {
    final file = await _file();
    if (!file.existsSync()) {
      return const PendingClearQueue();
    }
    try {
      return PendingClearQueue.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, dynamic>,
      );
    } on FormatException {
      return const PendingClearQueue();
    }
  }

  @override
  Future<PendingClearQueue> update(
    PendingClearQueue Function(PendingClearQueue queue) change,
  ) {
    final result = _pending.then((_) async {
      final updated = change(await load());
      final file = await _file();
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode(updated.toJson()), flush: true);
      return updated;
    });
    // 失敗しても次の更新は続ける
    _pending = result.then((_) {}, onError: (_) {});
    return result;
  }
}
