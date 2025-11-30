import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:snampo/app.dart';

void main() async {
  // runAppを呼び出す前にバインディングを初期化する.
  WidgetsFlutterBinding.ensureInitialized();
  // initStateの中には、書けないので、main関数の中で実行する.
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    await Geolocator.requestPermission();
  }
  runApp(const ProviderScope(child: MyApp()));
}
