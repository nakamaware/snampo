import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// [start] から [end] までの経過時間を日本語の表記にする
String formatMissionDuration(DateTime start, DateTime end) {
  final d = end.difference(start);
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);
  if (hours > 0) {
    return '$hours時間$minutes分$seconds秒';
  }
  if (minutes > 0) {
    return '$minutes分$seconds秒';
  }
  return '$seconds秒';
}

/// チェックポイント一覧から最初のユーザー写真パスを返す
String? firstUserPhotoPath(List<CheckpointProgress?> checkpoints) {
  for (final cp in checkpoints) {
    final p = cp?.userPhotoPath;
    if (p != null && p.isNotEmpty) {
      return p;
    }
  }
  return null;
}
