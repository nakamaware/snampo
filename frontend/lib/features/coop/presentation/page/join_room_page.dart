import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/usecase/join_room_use_case.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/component/coop_room_dialogs.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';

/// 「ルームに入る」: コード入力と QR スキャン
class JoinRoomPage extends HookConsumerWidget {
  /// [JoinRoomPage] を作成する
  const JoinRoomPage({super.key});

  static String _errorMessage(JoinRoomError error) => switch (error) {
    JoinRoomError.notFound => 'ルームが見つかりません。コードを確認してください',
    JoinRoomError.expired => 'このルームは期限切れです',
    JoinRoomError.finished => 'このルームは終了しています',
    JoinRoomError.full => 'このルームは満員です (最大 ${Room.maxActiveMembers} 人)',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final isJoining = useState(false);
    final error = useState<String?>(null);

    Future<void> join(RoomCode code) async {
      error.value = null;
      final name = await ensureNickname(context, ref);
      if (name == null || !context.mounted) return;
      if (!await confirmLeaveCurrentRoom(context, ref, nextCode: code)) return;
      isJoining.value = true;
      try {
        final uid = await ref.read(ensureCoopSignInUseCaseProvider)();
        final result = await ref.read(joinRoomUseCaseProvider)(
          code: code,
          uid: uid,
          nickname: name,
        );
        switch (result) {
          case JoinRoomJoined():
            ref
                .read(coopSessionStoreProvider.notifier)
                .enter(CoopSession(roomCode: code, uid: uid));
            if (context.mounted) context.go('/coop/lobby');
          case JoinRoomFailed(error: final e):
            error.value = _errorMessage(e);
        }
      } on Object {
        error.value = '入室できませんでした。電波の良い場所で再度お試しください';
      } finally {
        if (context.mounted) isJoining.value = false;
      }
    }

    void submit() {
      final code = RoomCode.tryParse(controller.text);
      if (code == null) {
        error.value = 'ルームコードは英数字 ${RoomCode.length} 文字です';
        return;
      }
      join(code);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ルームに入る')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                enabled: !isJoining.value,
                textCapitalization: TextCapitalization.characters,
                maxLength: RoomCode.length,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                ],
                decoration: InputDecoration(
                  labelText: 'ルームコード',
                  errorText: error.value,
                ),
                onSubmitted: (_) => submit(),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: isJoining.value ? null : submit,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('参加する'),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed:
                    isJoining.value
                        ? null
                        : () async {
                          final code = await context.push<RoomCode>(
                            '/coop/join/scan',
                          );
                          if (code != null) {
                            controller.text = code.value;
                            await join(code);
                          }
                        },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('QR を読み取る'),
                ),
              ),
              if (isJoining.value) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
