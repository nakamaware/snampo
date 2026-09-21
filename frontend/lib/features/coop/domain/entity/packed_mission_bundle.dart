import 'dart:typed_data';

/// Storage に置くミッション一式。JSON に画像バイナリは入れない。
class PackedMissionBundle {
  /// [PackedMissionBundle] を作成する。
  const PackedMissionBundle({required this.bundleJson, required this.images});

  /// `rooms/{roomCode}/mission/bundle.json` の本文。
  final String bundleJson;

  /// `images/{n}.jpg` からバイト列。
  final Map<String, Uint8List> images;
}
