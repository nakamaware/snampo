import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/domain/entity/coop_checkpoint.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

void main() {
  group('CoopCheckpoint.discovererPhotoPath', () {
    test('自分が発見者なら自分の写真', () {
      const checkpoint = CheckpointProgress(
        userPhotoPath: '/mine.jpg',
        discovererUid: 'me',
        discovererThumbPath: '/thumb.jpg',
      );

      expect(checkpoint.discovererPhotoPath(myUid: 'me'), '/mine.jpg');
    });

    test('他の人が発見者なら、自分の写真があっても発見者のサムネ', () {
      const checkpoint = CheckpointProgress(
        userPhotoPath: '/mine.jpg',
        discovererUid: 'other',
        discovererThumbPath: '/thumb.jpg',
      );

      expect(checkpoint.discovererPhotoPath(myUid: 'me'), '/thumb.jpg');
    });

    test('他の人のサムネが届いていなければ null (プレースホルダを表示する)', () {
      const checkpoint = CheckpointProgress(
        userPhotoPath: '/mine.jpg',
        discovererUid: 'other',
      );

      expect(checkpoint.discovererPhotoPath(myUid: 'me'), isNull);
    });

    test('発見者がいなければ、共有に失敗した自分の写真があっても null (未クリア)', () {
      const checkpoint = CheckpointProgress(userPhotoPath: '/mine.jpg');

      expect(checkpoint.discovererPhotoPath(myUid: 'me'), isNull);
    });
  });
}
