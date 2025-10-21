// lib/data/world_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'people_store.dart'; // pre Person model (ak je inde, uprav import)

class WorldRepository {
  WorldRepository._();
  static final i = WorldRepository._();

  Future<List<Person>> fetchPeople() async {
    final sb = Supabase.instance.client;
    final res = await sb
        .from('persons')
        .select('uuid, meno, priezvisko, vek, strana, kraj, okres');

    // res je List<dynamic> (mapy)
    return (res as List)
        .map((e) => Person(
              uuid: e['uuid'] as String,
              name: e['meno'] as String,
              surname: e['priezvisko'] as String,
              age: e['vek'] as int,
              party: (e['strana'] as String?)?.trim().isEmpty ?? true
                  ? 'Nezadané'
                  : e['strana'] as String,
              kraj: e['kraj'] as String,
              okres: e['okres'] as String,
            ))
        .toList();
  }
}
