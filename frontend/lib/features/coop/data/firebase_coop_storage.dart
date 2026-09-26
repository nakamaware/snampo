import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/data/mapper/mission_bundle_mapper.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';

/// Cloud Storage 上のミッションバンドルとサムネ
class FirebaseCoopStorage implements ICoopStorage {
  /// [FirebaseCoopStorage] を作成する
  FirebaseCoopStorage(this._storage);

  final FirebaseStorage _storage;

  // Storage の Rules のサイズの上限に合わせる
  static const _maxMissionFileBytes = 5 * 1024 * 1024;
  static const _maxThumbBytes = 1024 * 1024;

  static final _jpeg = SettableMetadata(contentType: 'image/jpeg');
  static final _json = SettableMetadata(contentType: 'application/json');

  @override
  Future<String> uploadMissionBundle(
    RoomCode code,
    MissionEntity mission,
  ) async {
    final bundle = MissionBundleMapper.toBundle(code, mission);
    // 同じパスに上書きするので、途中で失敗しても再試行できる
    // (playing になるまで参加者は読まないため、不整合は起きない)
    await Future.wait([
      for (final MapEntry(key: path, value: bytes) in bundle.images.entries)
        _storage.ref(path).putData(bytes, _jpeg),
    ]);
    final bundlePath = MissionBundleMapper.bundlePath(code);
    await _storage
        .ref(bundlePath)
        .putData(utf8.encode(jsonEncode(bundle.json)), _json);
    return bundlePath;
  }

  @override
  Future<MissionEntity> downloadMissionBundle(String missionRef) async {
    final bytes = await _storage.ref(missionRef).getData(_maxMissionFileBytes);
    if (bytes == null) {
      throw StateError('バンドルを取得できませんでした: $missionRef');
    }
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    final paths = MissionBundleMapper.imagePaths(json);
    final images = await Future.wait(
      paths.map((path) => _storage.ref(path).getData(_maxMissionFileBytes)),
    );
    return MissionBundleMapper.fromBundle(json, {
      for (final (i, path) in paths.indexed)
        path: images[i] ?? (throw StateError('画像を取得できませんでした: $path')),
    });
  }

  /// サムネの Storage パス (発見者ごとにパスを分けて上書きを防ぐ)
  static String thumbPath(RoomCode code, SpotId spotId, String uid) =>
      'rooms/${code.value}/thumbs/${spotId.pathSegment}/$uid.jpg';

  @override
  Future<String> uploadThumb({
    required RoomCode code,
    required SpotId spotId,
    required String uid,
    required String localPath,
  }) async {
    final path = thumbPath(code, spotId, uid);
    await _storage.ref(path).putFile(File(localPath), _jpeg);
    return path;
  }

  @override
  Future<String> downloadThumb(String thumbPath) async {
    final bytes = await _storage.ref(thumbPath).getData(_maxThumbBytes);
    if (bytes == null) {
      throw StateError('サムネを取得できませんでした: $thumbPath');
    }
    final dir = await getTemporaryDirectory();
    final file = File(
      p.join(
        dir.path,
        'coop_thumb_${DateTime.now().microsecondsSinceEpoch}.jpg',
      ),
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
