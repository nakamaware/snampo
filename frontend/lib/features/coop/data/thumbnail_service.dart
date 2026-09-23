import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:snampo/features/coop/application/interface/thumbnail_service.dart';

/// 撮影した写真から長辺 480px の JPEG のサムネを作る
///
/// 一時ディレクトリに作る (アップロードして履歴にコピーしたら使わないため)。
class ThumbnailService implements IThumbnailService {
  /// サムネの長辺 (px)
  static const longSide = 480;

  static const _directoryName = 'coop_thumbs';

  @override
  Future<String> createThumbnail(String photoPath) async {
    final root = await getTemporaryDirectory();
    final dir = Directory(p.join(root.path, _directoryName));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final destination = p.join(
      dir.path,
      'thumb_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await Isolate.run(() => _resize(photoPath, destination));
    return destination;
  }

  static void _resize(String source, String destination) {
    final decoded = img.decodeImage(File(source).readAsBytesSync());
    if (decoded == null) {
      throw StateError('写真を読み込めませんでした: $source');
    }
    final oriented = img.bakeOrientation(decoded);
    final resized =
        oriented.width >= oriented.height
            ? img.copyResize(
              oriented,
              width: oriented.width > longSide ? longSide : oriented.width,
            )
            : img.copyResize(
              oriented,
              height: oriented.height > longSide ? longSide : oriented.height,
            );
    File(destination).writeAsBytesSync(img.encodeJpg(resized, quality: 80));
  }
}
