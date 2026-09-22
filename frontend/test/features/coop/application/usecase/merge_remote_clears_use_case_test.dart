import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/merge_remote_clears_use_case.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/clear_thumb.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/coop/domain/value_object/spot_id.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

void main() {
  const merge = MergeRemoteClearsUseCase();
  final clearedAt = DateTime.utc(2026, 9, 21, 7);

  MissionProgressEntity emptyProgress() {
    return MissionProgressEntity(
      startedAt: DateTime.utc(2026, 9, 21),
      checkpoints: const [null, null, null],
    );
  }

  SpotClear clearAt(int index) {
    return SpotClear.share(
      thumb: ClearThumb(
        roomCode: RoomCode('123456'),
        spotId: SpotId.fromIndex(index),
      ),
      clearedBy: PlayerId('uid-1'),
      nickname: Nickname('host'),
      clearedAt: clearedAt,
    );
  }

  test('空の slot に achievedAt だけ入れる', () {
    final result = merge(local: emptyProgress(), remoteClears: [clearAt(1)]);

    expect(result.checkpoints[0], isNull);
    expect(result.checkpoints[1]?.achievedAt, clearedAt);
    expect(result.checkpoints[1]?.userPhotoPath, isNull);
    expect(result.checkpoints[2], isNull);
  });

  test('埋まっている slot の写真パスを残す', () {
    const localPhoto = CheckpointProgress(userPhotoPath: '/tmp/a.jpg');
    final local = MissionProgressEntity(
      startedAt: DateTime.utc(2026, 9, 21),
      checkpoints: const [localPhoto, null],
    );

    final result = merge(local: local, remoteClears: [clearAt(0), clearAt(1)]);

    expect(result.checkpoints[0]?.userPhotoPath, '/tmp/a.jpg');
    expect(result.checkpoints[0]?.achievedAt, isNull);
    expect(result.checkpoints[1]?.achievedAt, clearedAt);
  });

  test('範囲外の spotId は無視する', () {
    final local = emptyProgress();
    final result = merge(local: local, remoteClears: [clearAt(9)]);

    expect(result.checkpoints, local.checkpoints);
  });

  test('リモートが空なら同じ進捗を返す', () {
    final local = emptyProgress();
    final result = merge(local: local, remoteClears: const []);

    expect(result.checkpoints, local.checkpoints);
    expect(result.startedAt, local.startedAt);
  });
}
