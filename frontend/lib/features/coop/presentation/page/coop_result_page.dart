import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/discoverer_rank.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/domain/entity/coop_checkpoint.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_store.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/component/mission_recap.dart';
import 'package:snampo/features/mission/presentation/page/result_page.dart';

/// 協力プレイの結果画面
///
/// 既存の結果画面に、メンバーごとの発見数と、写真を撮った人の名札を
/// [ResultPageExtension] で差し込む。
///
/// ホームの「結果を見る」から開いたとき (Mission 画面を通らない) も、ルームの監視を始めて
/// (`CoopMissionStore`)、アプリを終了していた間の発見を反映し、共有の途中で終了した撮影の
/// 扱いを決める。
class CoopResultPage extends HookConsumerWidget {
  /// [CoopResultPage] を作成する
  const CoopResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(coopSessionStoreProvider).value;
    final roomCode = session?.roomCode;
    final watching = useRef<ProviderSubscription<void>?>(null);
    useEffect(() {
      if (roomCode == null) return null;
      final subscription = ref.listenManual(
        coopMissionStoreProvider(roomCode).select((_) => null),
        (_, _) {},
      );
      watching.value = subscription;
      return () {
        subscription.close();
        watching.value = null;
      };
    }, [roomCode]);
    final members =
        session == null
            ? const <RoomMember>[]
            : ref.watch(coopMembersProvider(session.roomCode)).value ??
                const [];
    return ResultPage(
      kind: MissionSessionKind.coop,
      extension: _CoopResultPageExtension(
        roomCode: roomCode,
        // 「ホームへ戻る」でセッションを閉じると監視 (ストア) を invalidate するので、その前に
        // 購読をやめる (購読したままだと、終わったルームの監視と進捗を作り直してしまう)
        stopWatching: () => watching.value?.close(),
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
    required this.roomCode,
    required this.stopWatching,
    required this.myUid,
    required this.uidsInJoinOrder,
    required this.displayNames,
  });

  /// 端末で進行中のルームのコード (セッションがなければ null)
  final RoomCode? roomCode;

  /// ルームの監視 (`CoopMissionStore`) の購読をやめる
  final VoidCallback stopWatching;

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

  /// 共有の途中で終了した撮影の扱いを決め終えていれば片付けてよい
  /// (決められなければ、サーバに届いていた撮影の写真を消さないよう片付けない)
  @override
  Future<bool> canClearProgress(WidgetRef ref) async {
    final roomCode = this.roomCode;
    if (roomCode == null) return true;
    return ref
        .read(coopMissionStoreProvider(roomCode).notifier)
        .settleUnsharedCaptures();
  }

  /// 端末の「ルームに戻る」を消す (履歴の同期は続く)
  @override
  Future<void> onFinish(WidgetRef ref) async {
    stopWatching();
    ref.read(coopSessionStoreProvider.notifier).close();
  }
}
