import 'package:freezed_annotation/freezed_annotation.dart';

part 'thumb_upload_task.freezed.dart';
part 'thumb_upload_task.g.dart';

/// サムネの再送タスク
@freezed
abstract class ThumbUploadTask with _$ThumbUploadTask {
  /// [ThumbUploadTask] を作成する
  const factory ThumbUploadTask({
    required String roomCode,
    required String spotId,

    /// 端末に保存したサムネのパス
    required String localPath,

    /// 遊べる期限。再送するのはここまで
    required DateTime expiresAt,
  }) = _ThumbUploadTask;

  /// JSON から [ThumbUploadTask] を生成する
  factory ThumbUploadTask.fromJson(Map<String, dynamic> json) =>
      _$ThumbUploadTaskFromJson(json);
}

/// サムネの再送キュー (端末に保存し、キルされても消えないようにする)
@freezed
abstract class ThumbUploadQueue with _$ThumbUploadQueue {
  /// [ThumbUploadQueue] を作成する
  const factory ThumbUploadQueue({
    @Default([]) @JsonKey(toJson: _tasksToJson) List<ThumbUploadTask> tasks,
  }) = _ThumbUploadQueue;

  const ThumbUploadQueue._();

  /// JSON から [ThumbUploadQueue] を生成する
  factory ThumbUploadQueue.fromJson(Map<String, dynamic> json) =>
      _$ThumbUploadQueueFromJson(json);

  /// タスクを積む。同じルームとスポットのタスクは置き換える
  ThumbUploadQueue enqueue(ThumbUploadTask task) =>
      copyWith(tasks: [...tasks.where((t) => !_sameTarget(t, task)), task]);

  /// 成功したタスクを取り除く
  ThumbUploadQueue remove(ThumbUploadTask task) =>
      copyWith(tasks: tasks.where((t) => !_sameTarget(t, task)).toList());

  /// 遊べる期限を過ぎたタスクを破棄する
  ThumbUploadQueue pruneExpired(DateTime now) =>
      copyWith(tasks: tasks.where((t) => now.isBefore(t.expiresAt)).toList());

  static bool _sameTarget(ThumbUploadTask a, ThumbUploadTask b) =>
      a.roomCode == b.roomCode && a.spotId == b.spotId;
}

List<Map<String, dynamic>> _tasksToJson(List<ThumbUploadTask> tasks) =>
    tasks.map((t) => t.toJson()).toList();
