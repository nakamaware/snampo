import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// App Check のデバッグトークン (dev ビルドのみ)
///
/// 端末ごとに UUID を 1 回だけ生成して端末に保存し、Debug provider に渡す。
/// 登録は人が Firebase コンソールで行う (docs/coop-play-setup.md)。
/// トークンをコードやリポジトリには置かない。
class AppCheckDebugToken {
  AppCheckDebugToken._();

  static const _fileName = 'app_check_debug_token.txt';

  /// 端末に保存したトークンを読み込む。なければ生成して保存する
  static Future<String> loadOrCreate() async {
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, _fileName));
    if (file.existsSync()) {
      final saved = file.readAsStringSync().trim();
      if (saved.isNotEmpty) {
        return saved;
      }
    }
    final token = const Uuid().v4();
    await file.create(recursive: true);
    await file.writeAsString(token, flush: true);
    return token;
  }
}
