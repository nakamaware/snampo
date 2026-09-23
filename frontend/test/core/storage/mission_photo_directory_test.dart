import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/storage/mission_photo_directory.dart';

void main() {
  final code = RoomCode.tryParse('ABCD23')!;

  group('MissionPhotoDirectory', () {
    test('ソロは solo/ に保存する', () {
      expect(const MissionPhotoDirectory.solo().segments, ['solo']);
    });

    test('協力プレイはルームごとに coop/{roomCode}/ に保存する', () {
      expect(MissionPhotoDirectory.coop(code).segments, ['coop', 'ABCD23']);
    });

    test('ルームコードがあれば協力プレイ、なければソロの保存先にする', () {
      expect(MissionPhotoDirectory.of(roomCode: null).segments, ['solo']);
      expect(MissionPhotoDirectory.of(roomCode: code).segments, [
        'coop',
        'ABCD23',
      ]);
    });
  });
}
