import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snampo/features/coop/application/usecase/open_coop_room_use_case.dart';
import 'package:snampo/features/coop/application/usecase/share_spot_clear_use_case.dart';
import 'package:snampo/features/coop/application/usecase/sync_remote_clears_use_case.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/spot_id.dart';
import 'package:snampo/features/coop/presentation/coop_controller.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';

/// 協力ホストなら、生成済みミッションでルームを開く。
Future<void> publishCoopRoomIfDraft({
  required BuildContext context,
  required WidgetRef ref,
  required MissionEntity mission,
}) async {
  final nickname = ref.read(coopHostDraftProvider);
  final backend = ref.read(coopBackendProvider);
  if (nickname == null || backend == null) {
    return;
  }
  if (ref.read(coopSessionProvider) != null) {
    return;
  }
  if (!ref.read(coopPublishGuardProvider.notifier).tryStart()) {
    return;
  }
  try {
    final playerId = await backend.signIn();
    final room = await const OpenCoopRoomUseCase().call(
      backend: backend,
      nickname: nickname,
      mission: mission,
      now: DateTime.now().toUtc(),
    );
    ref.read(coopHostDraftProvider.notifier).clear();
    ref
        .read(coopSessionProvider.notifier)
        .setSession(
          CoopSession(room: room, selfId: playerId, nickname: nickname),
        );
    if (context.mounted) {
      await context.push('/coop/room');
    }
  } on Object {
    ref.read(coopPublishGuardProvider.notifier).reset();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ルームを作れませんでした')));
    }
  }
}

/// 受け付けた写真を Storage と `clears` に載せる。
Future<void> shareAcceptedPhoto({
  required WidgetRef ref,
  required int spotIndex,
  required CheckpointProgress checkpoint,
}) async {
  final session = ref.read(coopSessionProvider);
  final backend = ref.read(coopBackendProvider);
  final path = checkpoint.userPhotoPath;
  if (session == null || backend == null || path == null) {
    return;
  }
  final bytes = await File(path).readAsBytes();
  await const ShareSpotClearUseCase().call(
    backend: backend,
    roomCode: session.room.roomCode,
    spotId: SpotId.fromIndex(spotIndex),
    clearedBy: session.selfId,
    nickname: session.nickname,
    clearedAt: DateTime.now().toUtc(),
    jpeg: bytes,
  );
}

/// 他端末のクリアを進捗と発見者名へ反映する。
Future<void> syncCoopClears(
  WidgetRef ref, {
  required List<SpotClear> clears,
}) async {
  final session = ref.read(coopSessionProvider);
  final backend = ref.read(coopBackendProvider);
  if (session == null || backend == null) {
    return;
  }
  final local = ref.read(missionProgressStoreProvider).value;
  if (local == null) {
    return;
  }
  final directory = await getApplicationDocumentsDirectory();
  final photoDirectory = Directory(
    '${directory.path}/coop_thumbs/${session.room.roomCode.value}',
  );
  await photoDirectory.create(recursive: true);
  final result = await const SyncRemoteClearsUseCase().call(
    backend: backend,
    local: local,
    clears: clears,
    photoDirectory: photoDirectory,
  );
  ref
      .read(missionProgressStoreProvider.notifier)
      .replaceProgress(result.progress);
  ref.read(coopDiscovererProvider.notifier).replace(result.discoverers);
}
