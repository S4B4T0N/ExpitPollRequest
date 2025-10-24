import 'package:supabase_flutter/supabase_flutter.dart';
import 'people_store.dart';

class WorldRepository {
  WorldRepository._();
  static final i = WorldRepository._();

  Future<List<Person>> fetchPeople() async {
    final sb = Supabase.instance.client;
    final res = await sb
        .from('persons')
        .select('uuid, meno, priezvisko, vek, strana, kraj, okres');

    return (res as List).map((e) {
      final ageRaw = e['vek'];
      final age = ageRaw is int ? ageRaw : (ageRaw is num ? ageRaw.toInt() : 0);
      final party = (e['strana'] as String?)?.trim();
      return Person(
        uuid: (e['uuid'] as String?) ?? '',
        name: (e['meno'] as String?) ?? '',
        surname: (e['priezvisko'] as String?) ?? '',
        age: age,
        party: (party == null || party.isEmpty) ? 'Nezadané' : party,
        kraj: (e['kraj'] as String?) ?? '',
        okres: (e['okres'] as String?) ?? '',
      );
    }).toList();
  }
}
