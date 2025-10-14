class Person {
  final String name;
  final String surname;
  final int age;
  final String party;
  final String kraj;
  final String okres;

  Person({
    required this.name,
    required this.surname,
    required this.age,
    required this.party,
    required this.kraj,
    required this.okres,
  });
}

class PeopleStore {
  PeopleStore._();
  static final i = PeopleStore._();

  final List<Person> people = [];
}
