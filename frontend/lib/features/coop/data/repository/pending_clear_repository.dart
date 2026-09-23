import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:snampo/features/coop/application/interface/pending_clear_repository.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';

/// 共有しきれていない発見のキューを JSON ファイルとして端末に保存する (キルされても消えない)
class PendingClearRepository implements IPendingClearRepository {
  static const _fileName = 'coop_pending_clear_queue.json';

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }

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
  Future<void> save(PendingClearQueue queue) async {
    final file = await _file();
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode(queue.toJson()), flush: true);
  }
}
