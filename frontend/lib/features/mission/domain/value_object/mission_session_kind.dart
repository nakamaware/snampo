/// ミッションのセッション種別
///
/// 保存枠はソロ 1 枠 + 協力プレイ 1 枠。ミッションと進捗のストアはこの種別で保存キーを分ける。
enum MissionSessionKind {
  /// ひとりで
  solo(persistKeySuffix: ''),

  /// みんなで (協力プレイ)
  coop(persistKeySuffix: '.coop');

  const MissionSessionKind({required this.persistKeySuffix});

  /// 保存キーの接尾辞。ソロの既存データをそのまま読めるように、ソロは付けない
  final String persistKeySuffix;

  /// [baseKey] をもとにした、この種別の保存キー
  String persistKey(String baseKey) => '$baseKey$persistKeySuffix';
}
