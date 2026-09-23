import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_clear_task.freezed.dart';
part 'pending_clear_task.g.dart';

/// 共有しきれていない発見 (クリアの作成と、サムネの再送)
@freezed
abstract class PendingClearTask with _$PendingClearTask {
  /// [PendingClearTask] を作成する
  const factory PendingClearTask({
    required String roomCode,
    required String spotId,

    /// 発見時点の自分のニックネーム (クリアを作り直すときに使う)
    required String nickname,

    /// 端末に保存したサムネのパス
    required String localThumbPath,

    /// 遊べる期限。再送するのはここまで
    required DateTime expiresAt,

    /// クリアを作成済みか (true ならサムネの再送だけが残っている)
    @Default(false) bool clearCreated,
  }) = _PendingClearTask;

  /// JSON から [PendingClearTask] を生成する
  factory PendingClearTask.fromJson(Map<String, dynamic> json) =>
      _$PendingClearTaskFromJson(json);
}

/// 共有しきれていない発見のキュー (端末に保存し、キルされても消えないようにする)
@freezed
abstract class PendingClearQueue with _$PendingClearQueue {
  /// [PendingClearQueue] を作成する
  const factory PendingClearQueue({
    @Default([]) @JsonKey(toJson: _tasksToJson) List<PendingClearTask> tasks,
  }) = _PendingClearQueue;

  const PendingClearQueue._();

  /// JSON から [PendingClearQueue] を生成する
  factory PendingClearQueue.fromJson(Map<String, dynamic> json) =>
      _$PendingClearQueueFromJson(json);

  /// タスクを積む。同じルームとスポットのタスクは置き換える
  PendingClearQueue enqueue(PendingClearTask task) =>
      copyWith(tasks: [...tasks.where((t) => !_sameTarget(t, task)), task]);

  /// 片付いたタスクを取り除く
  PendingClearQueue remove(PendingClearTask task) =>
      copyWith(tasks: tasks.where((t) => !_sameTarget(t, task)).toList());

  /// クリアを作成済みにする (サムネの再送だけを残す)。タスクがなければ何もしない
  PendingClearQueue markClearCreated(PendingClearTask task) => copyWith(
    tasks: [
      for (final t in tasks)
        _sameTarget(t, task) ? t.copyWith(clearCreated: true) : t,
    ],
  );

  /// 遊べる期限を過ぎたタスクを破棄する
  PendingClearQueue pruneExpired(DateTime now) =>
      copyWith(tasks: tasks.where((t) => now.isBefore(t.expiresAt)).toList());

  static bool _sameTarget(PendingClearTask a, PendingClearTask b) =>
      a.roomCode == b.roomCode && a.spotId == b.spotId;
}

List<Map<String, dynamic>> _tasksToJson(List<PendingClearTask> tasks) =>
    tasks.map((t) => t.toJson()).toList();
