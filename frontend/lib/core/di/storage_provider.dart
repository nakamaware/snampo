import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_sqflite/riverpod_sqflite.dart';
import 'package:sqflite/sqflite.dart';

part 'storage_provider.g.dart';

/// SQLite ストレージのプロバイダー (keepAlive で DB 接続を維持)
@Riverpod(keepAlive: true)
Future<JsonSqFliteStorage> storage(Ref ref) async {
  final databasesPath = await getDatabasesPath();
  final dbPath = join(databasesPath, 'snampo.db');
  final storage = await JsonSqFliteStorage.open(dbPath);
  ref.onDispose(storage.close);
  return storage;
}
