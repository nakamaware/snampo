import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/presentation/component/nickname_sheet.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';

/// ルーム情報のシートを開く (ゲーム中に、途中から入る人や抜けた人へ入り方を教える)
Future<void> showRoomInfoSheet(BuildContext context, RoomCode roomCode) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => _RoomInfoSheetConsumer(roomCode: roomCode),
    );

class _RoomInfoSheetConsumer extends ConsumerWidget {
  const _RoomInfoSheetConsumer({required this.roomCode});

  final RoomCode roomCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(coopRoomProvider(roomCode)).value;
    final members = ref.watch(coopMembersProvider(roomCode)).value ?? const [];
    final myUid = ref.watch(coopSessionStoreProvider).value?.uid;
    if (room == null || myUid == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return RoomInfoSheet(room: room, members: members, myUid: myUid);
  }
}

/// ルーム情報のシートの中身 (ルームコード・QR コードと、メンバーの一覧)
class RoomInfoSheet extends StatelessWidget {
  /// [RoomInfoSheet] を作成する
  const RoomInfoSheet({
    required this.room,
    required this.members,
    required this.myUid,
    super.key,
  });

  /// ルーム
  final Room room;

  /// メンバー (抜けた人も含む)
  final List<RoomMember> members;

  /// 自分の uid
  final String myUid;

  @override
  Widget build(BuildContext context) {
    // 画面の 8 割までの高さにし、入りきらなければスクロールする
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Text(
            'ルーム情報',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          RoomCodeCard(room: room),
          const SizedBox(height: 16),
          RoomMembersCard(members: members, hostId: room.hostId, myUid: myUid),
        ],
      ),
    );
  }
}

/// ルームコード・QR コードと、コピー・共有のボタン
class RoomCodeCard extends StatelessWidget {
  /// [RoomCodeCard] を作成する
  const RoomCodeCard({required this.room, super.key});

  /// ルーム
  final Room room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = room.code.value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('ルームコード', style: theme.textTheme.labelLarge),
            SelectableText(
              code,
              style: theme.textTheme.displaySmall?.copyWith(letterSpacing: 6),
            ),
            const SizedBox(height: 8),
            QrImageView(
              data: room.code.toQrPayload(),
              size: 180,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ルームコードをコピーしました')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('コピー'),
                ),
                TextButton.icon(
                  onPressed:
                      () => SharePlus.instance.share(
                        ShareParams(text: 'スナんぽで一緒に遊ぼう! ルームコード: $code'),
                      ),
                  icon: const Icon(Icons.share),
                  label: const Text('共有'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// メンバーの一覧 (ホストには星、抜けた人は薄く表示する)
///
/// [onEditMyNickname] を渡すと (ロビーの開始前)、自分の行から名前を変えられる。
class RoomMembersCard extends StatelessWidget {
  /// [RoomMembersCard] を作成する
  const RoomMembersCard({
    required this.members,
    required this.hostId,
    required this.myUid,
    this.isMyNicknameAuto = false,
    this.onEditMyNickname,
    super.key,
  });

  /// メンバー (抜けた人も含む)
  final List<RoomMember> members;

  /// ホストの uid
  final String hostId;

  /// 自分の uid
  final String myUid;

  /// 自分の名前がおまかせで付けた名前か
  final bool isMyNicknameAuto;

  /// 自分の名前を変える
  final VoidCallback? onEditMyNickname;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 重複した名前には、表示するときだけ番号を付ける (あとから同じ名前にした人に付く)
    final names = displayNicknames([for (final m in members) m.named]);
    final activeCount = members.where((m) => !m.hasLeft).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'メンバー $activeCount / ${Room.maxActiveMembers} 人',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final member in members)
              if (member.uid == myUid)
                _MyMemberTile(
                  name: names[member.uid] ?? member.nickname,
                  hint: switch ((
                    onEditMyNickname != null,
                    isNumberedNickname(names, member.named),
                    isMyNicknameAuto,
                  )) {
                    (false, _, _) => _MyNameHint.none,
                    (true, true, _) => _MyNameHint.duplicated,
                    (true, false, true) => _MyNameHint.auto,
                    (true, false, false) => _MyNameHint.none,
                  },
                  isHost: member.uid == hostId,
                  onEdit: onEditMyNickname,
                )
              else
                ListTile(
                  dense: true,
                  leading: Icon(
                    member.uid == hostId ? Icons.star : Icons.person,
                    color: member.hasLeft ? theme.colorScheme.outline : null,
                  ),
                  title: Text(
                    [
                      names[member.uid] ?? member.nickname,
                      if (member.hasLeft) '(抜けました)',
                    ].join(' '),
                    style:
                        member.hasLeft
                            ? TextStyle(color: theme.colorScheme.outline)
                            : null,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// 自分の行の名前の下に出す、名前を変えられることの案内
enum _MyNameHint {
  /// 出さない (変えられないときも)
  none,

  /// 同じ名前の人がいて、自分に番号が付いた。おまかせの名前でもこちらを出す
  duplicated,

  /// おまかせの名前のまま
  auto,
}

/// 自分の行。名前を変えられるときは、行全体と ✎ で変えられる
///
/// 変えたほうがよい名前なら、[hint] で名前の下に 1 行で示す (変えると消える)。
class _MyMemberTile extends StatelessWidget {
  const _MyMemberTile({
    required this.name,
    required this.hint,
    required this.isHost,
    required this.onEdit,
  });

  final String name;
  final _MyNameHint hint;
  final bool isHost;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final editable = onEdit != null;
    return ListTile(
      dense: true,
      tileColor: colors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.only(left: 16, right: 4),
      onTap: onEdit,
      leading: Icon(isHost ? Icons.star : Icons.person),
      title: Row(
        children: [
          Flexible(child: Text(name)),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'あなた',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      subtitle: switch (hint) {
        _MyNameHint.none => null,
        _MyNameHint.duplicated => const Row(
          children: [
            _DuplicatedNameBadge(),
            SizedBox(width: 4),
            Text('タップして変える'),
          ],
        ),
        _MyNameHint.auto => const Row(
          children: [
            AutoNicknameBadge(small: true),
            SizedBox(width: 4),
            Text('タップして変える'),
          ],
        ),
      },
      trailing:
          editable
              ? IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: '名前を変える',
                onPressed: onEdit,
              )
              : null,
    );
  }
}

/// 同じ名前の人がいて、自分に番号が付いたことを示す小さい表示
///
/// おまかせの表示 ([AutoNicknameBadge]) と同じ形で、色を変えて見分けられるようにする。
class _DuplicatedNameBadge extends StatelessWidget {
  const _DuplicatedNameBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        child: Text(
          '同じ名前',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}
