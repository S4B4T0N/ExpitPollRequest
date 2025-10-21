import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:exit_poll_request/data/people_store.dart';

class SupaSync {
  static SupabaseClient get _sb => Supabase.instance.client;

  /// Upsert jedného človeka podľa uuid.
  static Future<void> upsertOne(Person p) async {
    await _sb.from('persons').upsert({
      'uuid': p.uuid,
      'meno': p.name,
      'priezvisko': p.surname,
      'vek': p.age,
      'strana': p.party,
      'kraj': p.kraj,
      'okres': p.okres,
    }, onConflict: 'uuid');
  }

  /// Hromadný upsert všetkých lokálnych dát.
  static Future<int> upsertAll(List<Person> people) async {
    if (people.isEmpty) return 0;
    final payload = people
        .map((p) => {
              'uuid': p.uuid,
              'meno': p.name,
              'priezvisko': p.surname,
              'vek': p.age,
              'strana': (p.party.trim().isEmpty) ? 'Nezadané' : p.party,
              'kraj': p.kraj,
              'okres': p.okres,
            })
        .toList();

    final res = await _sb
        .from('persons')
        .upsert(payload, onConflict: 'uuid')
        .select('uuid');
    return (res as List).length;
  }
}
