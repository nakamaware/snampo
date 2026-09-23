import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';

void main() {
  final at = DateTime.utc(2026, 9, 23);
  CoopHistoryInfo coop(CoopSyncState state) => CoopHistoryInfo(
    roomCode: RoomCode.tryParse('ABCD23')!,
    syncState: state,
    isHost: true,
    members: const [
      CoopHistoryMember(uid: 'a', nickname: 'たろう'),
      CoopHistoryMember(uid: 'b', nickname: 'たろう'),
    ],
    expiresAt: at,
    deleteAt: at,
  );

  test('協力プレイの履歴には進行中かどうかを表示する', () {
    expect(formatCoopLabel(coop(CoopSyncState.inProgress)), 'みんなで (進行中)');
    expect(formatCoopLabel(coop(CoopSyncState.finalized)), 'みんなで');
  });

  test('メンバーは重複した名前に番号を付けて並べる', () {
    expect(
      formatCoopMembers(coop(CoopSyncState.finalized)),
      'メンバー: たろう、たろう(2)',
    );
  });

  test('サムネ一覧の代表には自分の写真がなければ発見者のサムネを使う', () {
    final spot = MissionHistorySpot(
      coordinate: Coordinate(latitude: 35, longitude: 139),
      sortOrder: 0,
      isDestination: true,
      streetViewImagePath: '/sv.jpg',
      discovererThumbPath: '/thumb.jpg',
    );

    expect(historyThumbnailPath([spot]), '/thumb.jpg');
  });
}
