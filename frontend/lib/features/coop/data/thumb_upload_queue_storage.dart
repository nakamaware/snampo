import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:snampo/features/coop/application/interface/thumb_upload_queue_store.dart';
import 'package:snampo/features/coop/domain/entity/thumb_upload_task.dart';

/// サムネの再送キューを JSON ファイルとして端末に保存する (キルされても消えない)
class ThumbUploadQueueStorage implements IThumbUploadQueueStore {
  static const _fileName = 'coop_thumb_upload_queue.json';

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, _fileName));
  }

  @override
  Future<ThumbUploadQueue> load() async {
    final file = await _file();
    if (!file.existsSync()) {
      return const ThumbUploadQueue();
    }
    try {
      return ThumbUploadQueue.fromJson(
        jsonDecode(await file.readAsString()) as Map<String, dynamic>,
      );
    } on FormatException {
      return const ThumbUploadQueue();
    }
  }

  @override
  Future<void> save(ThumbUploadQueue queue) async {
    final file = await _file();
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode(queue.toJson()), flush: true);
  }
}
