import 'package:exit_poll_request/data/people_store.dart' show Person;
import 'package:exit_poll_request/data/pp_db.dart';

/// Jednoduchý repo pre "World" zdroj = PostgreSQL (NAS).
class WorldRepository {
  WorldRepository._();
  static final WorldRepository i = WorldRepository._();

  final _remote = PpDbRemote();

  /// Vráti osoby z Postgresu a premenuje stĺpce na lokálny model.
  Future<List<Person>> fetchPeople() async {
    final res = await _remote.selectPersons();

    // postgres:^3.0.0 -> Result iteruje Row; Row.toColumnMap() dá mapu "názovStĺpca" -> hodnota
    final people = <Person>[];
    for (final row in res) {
      final m = row.toColumnMap();

      people.add(
        Person(
          uuid: (m['uuid'] ?? '') as String,
          name: (m['meno'] ?? '') as String,
          surname: (m['priezvisko'] ?? '') as String,
          age: (m['vek'] ?? 0) as int,
          party: (m['strana'] ?? 'Nezadané') as String,
          kraj: (m['kraj'] ?? '') as String,
          okres: (m['okres'] ?? '') as String,
        ),
      );
    }
    return people;
  }
}
