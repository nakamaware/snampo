import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/features/coop/application/coop_failure.dart';
import 'package:snampo/features/coop/application/usecase/join_coop_room_use_case.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/coop/presentation/coop_controller.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

/// ホームから入る参加画面。コード手入力と QR 読み取り。
class JoinCoopPage extends ConsumerStatefulWidget {
  /// [JoinCoopPage] を作成する。
  const JoinCoopPage({super.key});

  @override
  ConsumerState<JoinCoopPage> createState() => _JoinCoopPageState();
}

class _JoinCoopPageState extends ConsumerState<JoinCoopPage> {
  final _nickname = TextEditingController();
  final _code = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _nickname.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final scanned = await context.push<String>('/coop/scan');
    if (scanned == null || !mounted) {
      return;
    }
    _code.text = scanned;
  }

  Future<void> _join() async {
    if (!Nickname.canCreate(_nickname.text) ||
        !RoomCode.canCreate(_code.text)) {
      _message('ニックネームと数字 6 桁のコードを入れてください');
      return;
    }
    final backend = ref.read(coopBackendProvider);
    if (backend == null) {
      _message('Firebase の設定ファイルがまだありません');
      return;
    }
    final nickname = Nickname(_nickname.text);
    final roomCode = RoomCode(_code.text);

    setState(() => _busy = true);
    try {
      final joined = await const JoinCoopRoomUseCase().call(
        backend: backend,
        roomCode: roomCode,
        nickname: nickname,
        now: DateTime.now().toUtc(),
      );
      ref.read(persistedMissionProvider.notifier).setMission(joined.mission);
      ref
          .read(missionProgressStoreProvider.notifier)
          .startProgress(joined.room.spotCount);
      ref
          .read(coopSessionProvider.notifier)
          .setSession(
            CoopSession(
              room: joined.room,
              selfId: joined.member.playerId,
              nickname: nickname,
            ),
          );
      if (mounted) {
        context.go('/mission');
      }
    } on CoopRoomNotFound {
      _message('ルームが見つかりません');
    } on CoopRoomExpired {
      _message('このルームは期限切れです');
    } on Object {
      _message('参加できませんでした');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _message(String text) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('参加'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nickname,
              decoration: const InputDecoration(labelText: 'ニックネーム'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(labelText: 'ルームコード'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _busy ? null : _scan,
              child: const Text('QR を読む'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _join,
              child: const Text('参加する'),
            ),
          ],
        ),
      ),
    );
  }
}
