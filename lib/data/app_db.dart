import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'people_store.dart';

/// SQLite wrapper (singleton).
class AppDb {
  AppDb._(this._db);

  static AppDb? _instance;
  final Database _db;

  static AppDb get i {
    final inst = _instance;
    if (inst == null) {
      throw StateError(
        'AppDb nie je otvorená. Zavolaj await AppDb.open() v main().',
      );
    }
    return inst;
  }

  /// Otvor alebo vytvor databázu. Volaj raz pri štarte.
  static Future<AppDb> open() async {
    final dir = await getDatabasesPath();
    final dbPath = p.join(dir, 'exit_poll.db');

    final db = await openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
        // PRAGMA s návratovou hodnotou cez rawQuery
        await db.rawQuery('PRAGMA journal_mode=WAL');
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS persons(
            uuid       TEXT PRIMARY KEY,
            meno       TEXT NOT NULL,
            priezvisko TEXT NOT NULL,
            vek        INTEGER,
            strana     TEXT,
            kraj       TEXT,
            okres      TEXT,
            created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now'))
          );
        ''');

        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_persons_kraj_okres
          ON persons(kraj, okres);
        ''');
      },
    );

    _instance = AppDb._(db);
    return _instance!;
  }

  Future<void> close() async {
    await _db.close();
    _instance = null;
  }

  // ---------- QUERIES ----------

  Future<List<Person>> getAllPersons() async {
    final rows = await _db.query('persons', orderBy: 'created_at DESC');
    return rows.map(_rowToPerson).toList();
  }

  Future<void> insertPerson(Person p) async {
    await _db.insert('persons', {
      'uuid': p.uuid,
      'meno': p.name,
      'priezvisko': p.surname,
      'vek': p.age,
      'strana': p.party,
      'kraj': p.kraj,
      'okres': p.okres,
      // 'created_at' nenechávame, nastaví sa DEFAULT výrazom v DB
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteAll() => _db.delete('persons');

  // ---------- Mappers ----------

  Person _rowToPerson(Map<String, Object?> r) {
    return Person(
      uuid: (r['uuid'] as String?) ?? '',
      name: (r['meno'] as String?) ?? '',
      surname: (r['priezvisko'] as String?) ?? '',
      age: (r['vek'] as int?) ?? 0,
      party: (r['strana'] as String?) ?? 'Nezadané',
      kraj: (r['kraj'] as String?) ?? '',
      okres: (r['okres'] as String?) ?? '',
      // created_at ignorujeme, v modeli ho nemáš
    );
  }
}
