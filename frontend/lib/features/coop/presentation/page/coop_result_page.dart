import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/coop/domain/entity/coop_checkpoint.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/component/mission_recap.dart';
import 'package:snampo/features/mission/presentation/page/result_page.dart';

/// 協力プレイの結果画面
///
/// 既存の結果画面に、メンバーごとの発見数と、写真を撮った人の名札を
/// [ResultPageExtension] で差し込む。
class CoopResultPage extends ConsumerWidget {
  /// [CoopResultPage] を作成する
  const CoopResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(coopSessionStoreProvider).value;
    final members =
        session == null
            ? const <RoomMember>[]
            : ref.watch(coopMembersProvider(session.roomCode)).value ??
                const [];
    return ResultPage(
      kind: MissionSessionKind.coop,
      extension: _CoopResultPageExtension(
        myUid: session?.uid,
        uidsInJoinOrder: [for (final m in members) m.uid],
        // 重複した名前には、表示するときだけ入室順に番号を付ける
        displayNames: displayNicknames([
          for (final m in members) (uid: m.uid, nickname: m.nickname),
        ]),
      ),
    );
  }
}

class _CoopResultPageExtension extends ResultPageExtension {
  const _CoopResultPageExtension({
    required this.myUid,
    required this.uidsInJoinOrder,
    required this.displayNames,
  });

  /// 自分の Auth uid (セッションがなければ null)
  final String? myUid;

  /// メンバーの uid (入室順。読めなければ空)
  final List<String> uidsInJoinOrder;

  /// uid ごとの表示名 (重複した名前には番号を付けたもの)
  final Map<String, String> displayNames;

  @override
  String get modeLabel => 'みんなで';

  /// 発見数の多い順 (同数なら入室順)。メンバーを読めない場合 (オフラインなど) は
  /// 発見時点のニックネームで表示する
  @override
  List<RecapMember> recapMembers(MissionProgressEntity progress) {
    final discoveries = [
      for (final cp in progress.checkpoints)
        if (cp?.discovererUid != null) cp!,
    ];
    final fallbackNames = {
      for (final cp in discoveries) cp.discovererUid!: cp.discovererNickname,
    };
    return [
      for (final rank in rankDiscoverers(
        discovererUids: [for (final cp in discoveries) cp.discovererUid!],
        uidsInJoinOrder: uidsInJoinOrder,
      ))
        (
          name: displayNames[rank.uid] ?? fallbackNames[rank.uid] ?? '???',
          count: rank.count,
          isMe: rank.uid == myUid,
        ),
    ];
  }

  @override
  String? spotOwnerLabel(CheckpointProgress? checkpoint) {
    final uid = checkpoint?.discovererUid;
    if (uid == null) return null;
    return uid == myUid ? 'あなた' : discovererName(checkpoint);
  }

  @override
  String? discovererName(CheckpointProgress? checkpoint) {
    final uid = checkpoint?.discovererUid;
    return uid == null
        ? null
        : displayNames[uid] ?? checkpoint?.discovererNickname;
  }

  /// 発見者の写真を表示する。同時に撮影して先着に負けたスポットでも、自分の写真ではなく
  /// 発見者のサムネを出す (サムネが届いていなければプレースホルダ)。
  /// 発見者のいないスポット (未クリア) は見本を出す
  @override
  String? spotThumbnailPath(CheckpointProgress? checkpoint) =>
      checkpoint?.discovererPhotoPath(myUid: myUid ?? '');

  /// 端末の「ルームに戻る」を消す (履歴の同期は続く)
  @override
  Future<void> onFinish(WidgetRef ref) async {
    ref.read(coopSessionStoreProvider.notifier).close();
  }
}
