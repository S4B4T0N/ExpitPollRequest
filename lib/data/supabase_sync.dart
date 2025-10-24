import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:exit_poll_request/data/people_store.dart';

class SupaSync {
  static SupabaseClient get _sb => Supabase.instance.client;

  // Validácia UUID v4 podľa RFC4122
  static bool _isValid(String id) => Uuid.isValidUUID(
      fromString: id, validationMode: ValidationMode.strictRFC4122);

  /// Upsert jedného človeka podľa uuid.
  static Future<void> upsertOne(Person p) async {
    if (!_isValid(p.uuid)) {
      debugPrint('[SupaSync.upsertOne] SKIP invalid uuid="${p.uuid}"');
      return;
    }
    try {
      final res = await _sb.from('persons').upsert({
        'uuid': p.uuid,
        'meno': p.name,
        'priezvisko': p.surname,
        'vek': p.age,
        'strana': (p.party.trim().isEmpty) ? 'Nezadané' : p.party,
        'kraj': p.kraj,
        'okres': p.okres,
      }, onConflict: 'uuid').select('uuid');
      debugPrint('[SupaSync.upsertOne] ok ${(res as List).length} row');
    } on PostgrestException catch (e) {
      debugPrint('[SupaSync.upsertOne] PG ${e.code} ${e.message} ${e.details}');
      rethrow;
    }
  }

  /// Hromadný upsert všetkých lokálnych dát.
  static Future<int> upsertAll(List<Person> people) async {
    if (people.isEmpty) {
      debugPrint('[SupaSync.upsertAll] nothing to push');
      return 0;
    }

    final payload = <Map<String, dynamic>>[];
    int skipped = 0;

    for (final p in people) {
      if (_isValid(p.uuid)) {
        payload.add({
          'uuid': p.uuid,
          'meno': p.name,
          'priezvisko': p.surname,
          'vek': p.age,
          'strana': (p.party.trim().isEmpty) ? 'Nezadané' : p.party,
          'kraj': p.kraj,
          'okres': p.okres,
        });
      } else {
        skipped++;
      }
    }

    if (skipped > 0) {
      debugPrint('[SupaSync.upsertAll] skipped invalid uuid count=$skipped');
    }
    if (payload.isEmpty) return 0;

    try {
      final res = await _sb
          .from('persons')
          .upsert(payload, onConflict: 'uuid')
          .select('uuid');
      final n = (res as List).length;
      debugPrint('[SupaSync.upsertAll] upserted=$n of ${payload.length}');
      return n;
    } on PostgrestException catch (e) {
      debugPrint('[SupaSync.upsertAll] PG ${e.code} ${e.message} ${e.details}');
      rethrow;
    }
  }
}
