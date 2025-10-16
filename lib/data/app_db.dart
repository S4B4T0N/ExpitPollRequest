import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:postgres/postgres.dart';

import 'people_store.dart';

/// Konfigurácia NAS Postgresu.
class NasConfig {
  static const host = '192.168.1.107';
  static const port = 5432;
  static const dbName = 'exitpoll';
  static const user = 'exitpoll';
  static const password = 'exitpoll123';

  /// TLS podľa potreby. Ak máš čisto LAN bez TLS, nechaj false.
  static const useTLS = false;

  /// Timeout pripojenia.
  static const timeoutSeconds = 6;
}

/// Klient pre Postgres 3.x (otvorený iba počas syncu).
class PpDbRemote {
  Connection? _conn;

  Future<void> open() async {
    if (_conn != null) return;
    final endpoint = Endpoint(
      host: NasConfig.host,
      port: NasConfig.port,
      database: NasConfig.dbName,
      username: NasConfig.user,
      password: NasConfig.password,
    );

    // Pozn.: názov poľa môže byť `sslMode` alebo `tlsMode` podľa verzie 3.x.
    // Ak IDE hlási chybu, zmeň na druhý názov.
    final settings = ConnectionSettings(
      connectTimeout: Duration(seconds: NasConfig.timeoutSeconds),
      // sslMode/tlsMode vypni pre čistú LAN
      // ignore: deprecated_member_use
      sslMode: NasConfig.useTLS ? SslMode.require : SslMode.disable,
    );

    _conn = await Connection.open(endpoint, settings: settings);
  }

  Future<void> close() async {
    final c = _conn;
    _conn = null;
    if (c != null) {
      await c.close();
    }
  }

  Future<void> upsertPerson(Person p) async {
    final c = _conn;
    if (c == null) {
      throw StateError('Remote connection is not open');
    }

    await c.execute(
      Sql.named('''
        INSERT INTO public.persons
          (uuid, meno, priezvisko, vek, strana, kraj, okres)
        VALUES
          (@uuid, @meno, @priezvisko, @vek, @strana, @kraj, @okres)
        ON CONFLICT (uuid) DO UPDATE SET
          meno=@meno,
          priezvisko=@priezvisko,
          vek=@vek,
          strana=@strana,
          kraj=@kraj,
          okres=@okres;
      '''),
      parameters: {
        'uuid': p.uuid,
        'meno': p.name,
        'priezvisko': p.surname,
        'vek': p.age,
        'strana': p.party,
        'kraj': p.kraj,
        'okres': p.okres,
      },
    );
  }
}

/// SQLite wrapper (singleton) + sync na NAS Postgres.
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

  /// Otvor alebo vytvor lokálnu SQLite. Volaj raz pri štarte.
  static Future<AppDb> open() async {
    final dir = await getDatabasesPath();
    final dbPath = p.join(dir, 'exit_poll.db');

    final db = await openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
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

  // ---------- Lokálne QUERIES (SQLite) ----------

  Future<List<Person>> getAllPersons() async {
    final rows = await _db.query('persons', orderBy: 'created_at DESC');
    return rows.map(_rowToPerson).toList();
  }

  Future<void> insertPerson(Person p) async {
    await _db.insert(
      'persons',
      {
        'uuid': p.uuid,
        'meno': p.name,
        'priezvisko': p.surname,
        'vek': p.age,
        'strana': p.party,
        'kraj': p.kraj,
        'okres': p.okres,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteAll() => _db.delete('persons');

  // ---------- Sync na NAS Postgres ----------

  /// Pošle všetky lokálne osoby do Postgresu (upsert podľa uuid).
  /// Vráti počet úspešne synchronizovaných riadkov.
  Future<int> syncToNas() async {
    final remote = PpDbRemote();
    int ok = 0;

    final rows = await _db.query('persons');

    try {
      await remote.open();
      for (final r in rows) {
        final p = _rowToPerson(r);
        await remote.upsertPerson(p);
        ok++;
      }
    } finally {
      await remote.close();
    }
    return ok;
  }

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
    );
  }
}
