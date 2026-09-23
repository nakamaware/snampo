import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/data/mapper/room_mapper.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/mission/domain/value_object/spot_id.dart';

/// Firestore 上のルーム
class RoomRepository implements IRoomRepository {
  /// [RoomRepository] を作成する
  RoomRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _room(RoomCode code) =>
      _firestore.collection('rooms').doc(code.value);

  CollectionReference<Map<String, dynamic>> _members(RoomCode code) =>
      _room(code).collection('members');

  CollectionReference<Map<String, dynamic>> _clears(RoomCode code) =>
      _room(code).collection('clears');

  static bool _isPermissionDenied(Object e) =>
      e is FirebaseException && e.code == 'permission-denied';

  Future<T> _mapDenied<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (e) {
      if (_isPermissionDenied(e)) {
        throw CoopPermissionDeniedException(e.message);
      }
      rethrow;
    }
  }

  @override
  Future<bool> createRoom(Room room) => _mapDenied(
    () => _firestore.runTransaction((transaction) async {
      final ref = _room(room.code);
      final snapshot = await transaction.get(ref);
      if (snapshot.exists) {
        return false;
      }
      transaction.set(ref, RoomMapper.roomToFirestore(room));
      return true;
    }),
  );

  static const _server = GetOptions(source: Source.server);

  @override
  Future<Room?> fetchRoom(RoomCode code) async {
    final snapshot = await _room(code).get(_server);
    final data = snapshot.data();
    return data == null ? null : RoomMapper.roomFromFirestore(code.value, data);
  }

  @override
  Stream<Room?> watchRoom(RoomCode code) => _room(code).snapshots().map((s) {
    final data = s.data();
    return data == null ? null : RoomMapper.roomFromFirestore(code.value, data);
  });

  @override
  Future<void> joinRoom(
    Room room, {
    required String uid,
    required String nickname,
  }) => _mapDenied(() async {
    final ref = _members(room.code).doc(uid);
    var exists = false;
    try {
      exists = (await ref.get()).exists;
    } on FirebaseException catch (e) {
      // メンバーでなければ自分のドキュメントも読めない (= まだ入室していない)
      if (!_isPermissionDenied(e)) {
        rethrow;
      }
    }
    if (exists) {
      await ref.update({'nickname': nickname, 'leftAt': null});
      return;
    }
    await ref.set({
      'nickname': nickname,
      'joinedAt': FieldValue.serverTimestamp(),
      'deleteAt': Timestamp.fromDate(room.deleteAt),
    });
  });

  @override
  Future<void> leaveRoom(RoomCode code, String uid) => _mapDenied(
    () => _members(
      code,
    ).doc(uid).update({'leftAt': FieldValue.serverTimestamp()}),
  );

  @override
  Future<List<RoomMember>> fetchMembers(RoomCode code) async {
    final snapshot = await _members(code).orderBy('joinedAt').get(_server);
    return [
      for (final doc in snapshot.docs)
        RoomMapper.memberFromFirestore(doc.id, doc.data()),
    ];
  }

  @override
  Stream<List<RoomMember>> watchMembers(RoomCode code) =>
      _members(code).snapshots().map((snapshot) {
        final members = [
          for (final doc in snapshot.docs)
            RoomMapper.memberFromFirestore(doc.id, doc.data()),
        ]..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
        return members;
      });

  @override
  Future<void> updateSettings(RoomCode code, RoomSettings settings) =>
      _mapDenied(
        () => _room(
          code,
        ).update({'settings': RoomMapper.settingsToFirestore(settings)}),
      );

  @override
  Future<void> markGenerating(RoomCode code) => _mapDenied(
    () => _room(
      code,
    ).update({'status': RoomStatus.generating.name, 'generationError': null}),
  );

  @override
  Future<void> markGenerationFailed(RoomCode code, String reason) => _mapDenied(
    () => _room(
      code,
    ).update({'status': RoomStatus.waiting.name, 'generationError': reason}),
  );

  @override
  Future<void> markPlaying(
    RoomCode code, {
    required String missionRef,
    required List<SpotId> spotIds,
  }) => _mapDenied(
    () => _room(code).update({
      'status': RoomStatus.playing.name,
      'missionRef': missionRef,
      'spotIds': [for (final id in spotIds) id.value],
      'generationError': null,
      'startedAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Future<void> finish(RoomCode code, FinishReason reason) => _mapDenied(
    () => _room(code).update({
      'status': RoomStatus.finished.name,
      'finishReason': reason.name,
      'finishedAt': FieldValue.serverTimestamp(),
    }),
  );

  @override
  Future<CreateClearResult> createClear(
    Room room, {
    required SpotId spotId,
    required String uid,
    required String nickname,
    required String? thumbPath,
  }) async {
    final ref = _clears(room.code).doc(spotId.value);
    try {
      // オフラインの間は SDK が端末に溜めておき、復帰したら送信する
      await ref.set({
        'clearedBy': uid,
        'nickname': nickname,
        'clearedAt': FieldValue.serverTimestamp(),
        'thumbPath': thumbPath,
        'deleteAt': Timestamp.fromDate(room.deleteAt),
      });
      return ClearCreated(thumbPathSaved: thumbPath != null);
    } on FirebaseException catch (e) {
      if (!_isPermissionDenied(e)) {
        rethrow;
      }
      // 先着勝ち: 既にあれば作成は拒否される
      final existing = await ref.get(const GetOptions(source: Source.server));
      final data = existing.data();
      if (data == null) {
        throw CoopPermissionDeniedException(e.message);
      }
      // 自分の送信待ちのクリア (キルされる前の書き込み) が先に届いていた場合
      if (data['clearedBy'] == uid) {
        return ClearCreated(thumbPathSaved: data['thumbPath'] != null);
      }
      return ClearAlreadyExists(
        RoomMapper.clearFromFirestore(spotId.value, data),
      );
    }
  }

  @override
  Future<void> fillThumbPath(RoomCode code, SpotId spotId, String thumbPath) =>
      _mapDenied(
        () => _clears(code).doc(spotId.value).update({'thumbPath': thumbPath}),
      );

  @override
  Future<List<SpotClear>> fetchClears(RoomCode code) async {
    final snapshot = await _clears(code).get(_server);
    return [
      for (final doc in snapshot.docs)
        RoomMapper.clearFromFirestore(doc.id, doc.data()),
    ];
  }

  @override
  Stream<List<SpotClear>> watchClears(RoomCode code) =>
      _clears(code).snapshots().map(
        (snapshot) => [
          for (final doc in snapshot.docs)
            RoomMapper.clearFromFirestore(doc.id, doc.data()),
        ],
      );
}
