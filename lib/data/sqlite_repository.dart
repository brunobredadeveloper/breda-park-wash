import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../domain/models.dart';
import '../domain/parking_policy.dart';

class SqliteParkRepository implements ParkRepository {
  Database? _db;
  Future<Database> get database async => _db ??= await openDatabase(
    '${await getDatabasesPath()}/breda_park_wash.db',
    version: 1,
    onCreate: (db, _) => db.execute(
      'CREATE TABLE state (id INTEGER PRIMARY KEY CHECK(id=1), payload TEXT NOT NULL)',
    ),
  );
  @override
  Future<ParkState> load() async {
    final rows = await (await database).query(
      'state',
      where: 'id = ?',
      whereArgs: [1],
    );
    return rows.isEmpty
        ? const ParkState()
        : ParkState.fromJson(jsonDecode(rows.first['payload'] as String));
  }

  @override
  Future<void> save(ParkState state) async =>
      (await database).transaction((tx) async {
        await tx.insert('state', {
          'id': 1,
          'payload': jsonEncode(state.toJson()),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      });
}
