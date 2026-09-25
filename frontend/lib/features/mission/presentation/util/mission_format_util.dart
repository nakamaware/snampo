/// [start] から [end] までの経過時間を日本語の表記にする
///
/// [omitSeconds] なら秒を省く (一覧など。1 分未満なら秒を出す)。
String formatMissionDuration(
  DateTime start,
  DateTime end, {
  bool omitSeconds = false,
}) {
  final d = end.difference(start);
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);
  final secondsText = omitSeconds ? '' : '$seconds秒';
  if (hours > 0) {
    return '$hours時間$minutes分$secondsText';
  }
  if (minutes > 0) {
    return '$minutes分$secondsText';
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
