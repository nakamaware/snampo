import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:snampo/features/coop/application/coop_backend.dart';
import 'package:snampo/features/coop/domain/entity/coop_member.dart';
import 'package:snampo/features/coop/domain/entity/coop_room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/clear_thumb.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/coop/domain/value_object/spot_id.dart';

/// Firestore と Cloud Storage への協力プレイ実装。
class FirebaseCoopBackend implements CoopBackend {
  /// [options] で Firebase を初期化して作る。
  FirebaseCoopBackend({
    required FirebaseOptions options,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _options = options,
       _auth = auth,
       _firestore = firestore,
       _storage = storage;

  final FirebaseOptions _options;
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;

  Future<FirebaseAuth> _ensureAuth() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: _options);
    }
    return _auth ?? FirebaseAuth.instance;
  }

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  FirebaseStorage get _bucket => _storage ?? FirebaseStorage.instance;

  @override
  Future<PlayerId> signIn() async {
    final auth = await _ensureAuth();
    final current = auth.currentUser;
    if (current != null) {
      return PlayerId(current.uid);
    }
    final credential = await auth.signInAnonymously();
    final uid = credential.user?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('匿名サインインに失敗しました');
    }
    return PlayerId(uid);
  }

  @override
  Future<bool> createRoom(CoopRoom room) async {
    final ref = _db.collection('rooms').doc(room.roomCode.value);
    try {
      final existing = await ref.get();
      if (existing.exists) {
        return false;
      }
      await ref.set({
        'hostId': room.hostId.value,
        'hostNickname': room.hostNickname.value,
        'createdAt': Timestamp.fromDate(room.createdAt),
        'expiresAt': Timestamp.fromDate(room.expiresAt),
        'missionRef': room.missionRef,
        'spotCount': room.spotCount,
      });
      return true;
    } on FirebaseException catch (error) {
      if (_codeTaken(error)) {
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<CoopRoom?> findRoom(RoomCode roomCode) async {
    final snapshot = await _db.collection('rooms').doc(roomCode.value).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }
    return _roomFromData(roomCode, data);
  }

  @override
  Future<void> joinRoom({
    required RoomCode roomCode,
    required CoopMember member,
  }) async {
    await _db
        .collection('rooms')
        .doc(roomCode.value)
        .collection('members')
        .doc(member.playerId.value)
        .set({
          'nickname': member.nickname.value,
          'joinedAt': Timestamp.fromDate(member.joinedAt),
        });
  }

  @override
  Future<void> putBytes({
    required String objectPath,
    required Uint8List bytes,
  }) async {
    await _bucket.ref(objectPath).putData(bytes);
  }

  @override
  Future<Uint8List?> getBytes(String objectPath) async {
    try {
      return await _bucket.ref(objectPath).getData();
    } on FirebaseException catch (error) {
      if (error.code == 'object-not-found') {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<bool> createClear({
    required RoomCode roomCode,
    required SpotClear clear,
  }) async {
    final ref = _db
        .collection('rooms')
        .doc(roomCode.value)
        .collection('clears')
        .doc(clear.spotId.value);
    try {
      final existing = await ref.get();
      if (existing.exists) {
        return false;
      }
      await ref.set({
        'clearedBy': clear.clearedBy.value,
        'nickname': clear.nickname.value,
        'clearedAt': Timestamp.fromDate(clear.clearedAt),
        'thumbPath': clear.thumbPath,
      });
      return true;
    } on FirebaseException catch (error) {
      if (_codeTaken(error)) {
        return false;
      }
      rethrow;
    }
  }

  bool _codeTaken(FirebaseException error) {
    return error.code == 'permission-denied' || error.code == 'already-exists';
  }

  @override
  Stream<List<SpotClear>> watchClears(RoomCode roomCode) {
    return _db
        .collection('rooms')
        .doc(roomCode.value)
        .collection('clears')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => _clearFromData(roomCode, doc.id, doc.data()))
              .whereType<SpotClear>()
              .toList(growable: false);
        });
  }

  CoopRoom _roomFromData(RoomCode roomCode, Map<String, dynamic> data) {
    final createdAt = _time(data['createdAt']);
    return CoopRoom.open(
      roomCode: roomCode,
      hostId: PlayerId(data['hostId'] as String),
      hostNickname: Nickname(data['hostNickname'] as String),
      createdAt: createdAt,
      missionRef: data['missionRef'] as String,
      spotCount: data['spotCount'] as int,
    );
  }

  SpotClear? _clearFromData(
    RoomCode roomCode,
    String spotId,
    Map<String, dynamic> data,
  ) {
    final clearedBy = data['clearedBy'];
    final nickname = data['nickname'];
    final clearedAt = data['clearedAt'];
    if (clearedBy is! String || nickname is! String || clearedAt == null) {
      return null;
    }
    return SpotClear.share(
      thumb: ClearThumb(roomCode: roomCode, spotId: SpotId.parse(spotId)),
      clearedBy: PlayerId(clearedBy),
      nickname: Nickname(nickname),
      clearedAt: _time(clearedAt),
    );
  }

  DateTime _time(Object? raw) {
    if (raw is Timestamp) {
      return raw.toDate().toUtc();
    }
    if (raw is DateTime) {
      return raw.toUtc();
    }
    throw ArgumentError.value(raw, 'timestamp', '時刻がありません');
  }
}
