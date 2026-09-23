import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';
import 'package:snampo/features/mission/presentation/component/mission_settings_inputs.dart';

/// ミッションの設定。ホストは編集でき、メンバーはリアルタイムで閲覧のみ
///
/// 入力部品は Setup 画面と同じもの ([RadiusSlider] / [DestinationMap]) を使う。
class LobbySettingsCard extends HookConsumerWidget {
  /// [LobbySettingsCard] を作成する
  const LobbySettingsCard({
    required this.room,
    required this.editable,
    super.key,
  });

  /// 表示するルーム
  final Room room;

  /// 編集できるか (ホストで、生成中でないとき)
  final bool editable;

  Future<void> _update(
    BuildContext context,
    WidgetRef ref,
    RoomSettings settings,
  ) async {
    try {
      await ref.read(updateRoomSettingsUseCaseProvider)(room.code, settings);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('設定を変更できませんでした')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = room.settings;
    // スライダー操作中の値 (離したときに保存する)
    final draftRadius = useState<Radius?>(null);
    // 目的地指定に切り替えたが、まだ目的地を選んでいない
    final choosingDestination = useState(false);
    final isDestination =
        settings is RoomSettingsDestination || choosingDestination.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ミッションの設定', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('ランダム')),
                ButtonSegment(value: true, label: Text('目的地指定')),
              ],
              selected: {isDestination},
              onSelectionChanged:
                  !editable
                      ? null
                      : (selection) async {
                        final toDestination = selection.first;
                        choosingDestination.value =
                            toDestination &&
                            settings is! RoomSettingsDestination;
                        if (!toDestination &&
                            settings is RoomSettingsDestination) {
                          await _update(
                            context,
                            ref,
                            RoomSettings.random(radius: Radius(meters: 1000)),
                          );
                        }
                      },
            ),
            const SizedBox(height: 16),
            switch (settings) {
              RoomSettingsRandom(:final radius) when !isDestination =>
                RadiusSlider(
                  radius: draftRadius.value ?? radius,
                  textStyle: theme.textTheme.headlineMedium,
                  onChanged:
                      editable ? (radius) => draftRadius.value = radius : null,
                  onChangeEnd:
                      editable
                          ? (radius) async {
                            await _update(
                              context,
                              ref,
                              RoomSettings.random(radius: radius),
                            );
                            draftRadius.value = null;
                          }
                          : null,
                ),
              _ => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (settings is! RoomSettingsDestination)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('地図をタップして目的地を選んでください'),
                    ),
                  SizedBox(
                    height: 240,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DestinationMap(
                        destination: switch (settings) {
                          RoomSettingsDestination(:final destination) =>
                            destination,
                          RoomSettingsRandom() => null,
                        },
                        insideScrollable: true,
                        onPick:
                            editable
                                ? (coordinate) async {
                                  await _update(
                                    context,
                                    ref,
                                    RoomSettings.destination(
                                      destination: coordinate,
                                    ),
                                  );
                                  choosingDestination.value = false;
                                }
                                : null,
                      ),
                    ),
                  ),
                ],
              ),
            },
          ],
        ),
      ),
    );
  }
}
