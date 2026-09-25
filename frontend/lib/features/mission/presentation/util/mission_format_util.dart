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

/// 向きのずれの表示 (「右に12.3度」など)
String formatHeadingErrorText(double degrees) {
  final abs = degrees.abs();
  if (abs < 0.05) return 'JUST!';
  final formatted = abs.toStringAsFixed(1);
  return degrees > 0 ? '右に$formatted度' : '左に$formatted度';
}
