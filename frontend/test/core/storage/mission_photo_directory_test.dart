import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/storage/mission_photo_directory.dart';

void main() {
  group('MissionPhotoDirectory', () {
    test('ソロは solo/ に保存する', () {
      expect(const MissionPhotoDirectory.solo().segments, ['solo']);
    });

    test('協力プレイはルームごとに coop/{roomCode}/ に保存する', () {
      expect(MissionPhotoDirectory.coop('ABCD23').segments, ['coop', 'ABCD23']);
    });

    test('ルームコードがあれば協力プレイ、なければソロの保存先にする', () {
      expect(MissionPhotoDirectory.of(roomCode: null).segments, ['solo']);
      expect(MissionPhotoDirectory.of(roomCode: 'ABCD23').segments, [
        'coop',
        'ABCD23',
      ]);
    });

    test('パスとして不正なルームコードは ArgumentError', () {
      expect(() => MissionPhotoDirectory.coop('../x'), throwsArgumentError);
      expect(() => MissionPhotoDirectory.coop(''), throwsArgumentError);
    });
  });
}
