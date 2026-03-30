import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';

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

/// スポット行一覧から最初のユーザー写真パスを返す
String? firstUserPhotoPath(List<MissionHistorySpot> spots) {
  for (final line in spots) {
    final p = line.userPhotoPath;
    if (p != null && p.isNotEmpty) {
      return p;
    }
  }
  return null;
}
