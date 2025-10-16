import 'package:postgres/postgres.dart';

class PpDbRemote {
  // Konfigurácia pripojenia
  static const _host = '192.168.1.107'; // <- správna IP NAS
  static const _port = 5432;
  static const _db = 'exitpoll';
  static const _user = 'exitpoll';
  static const _pass = 'exitpoll123';
  static const _useTLS = false; // LAN, bez TLS
  static const _timeoutSec = 10; // daj radšej 10

  Connection? _conn;

  Future<void> open() async {
    if (_conn != null) return;

    final endpoint = Endpoint(
      host: _host,
      port: _port,
      database: _db,
      username: _user,
      password: _pass,
    );

    final settings = ConnectionSettings(
      connectTimeout: const Duration(seconds: _timeoutSec),
      // Ak tvoja verzia používa tlsMode namiesto sslMode, prehoď riadok:
      // tlsMode: _useTLS ? TlsMode.require : TlsMode.disable,
      // ignore: deprecated_member_use
      sslMode: _useTLS ? SslMode.require : SslMode.disable,
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

  Future<void> upsertPerson({
    required String uuid,
    required String meno,
    required String priezvisko,
    required int vek,
    required String strana,
    required String kraj,
    required String okres,
  }) async {
    await open();
    final c = _conn!;
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
        'uuid': uuid,
        'meno': meno,
        'priezvisko': priezvisko,
        'vek': vek,
        'strana': strana,
        'kraj': kraj,
        'okres': okres,
      },
    );
  }
}
