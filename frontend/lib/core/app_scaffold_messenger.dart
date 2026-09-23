import 'package:flutter/material.dart';

/// アプリ全体の [ScaffoldMessenger]
///
/// 画面に依存しない裏方の処理 (発見の送り直しなど) から、エラーを表示するために使う。
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
