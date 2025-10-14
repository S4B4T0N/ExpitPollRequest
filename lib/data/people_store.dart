class Person {
  final String name, surname, party;
  final int age;
  Person({
    required this.name,
    required this.surname,
    required this.party,
    required this.age,
  });
}

class PeopleStore {
  PeopleStore._();
  static final i = PeopleStore._();
  final List<Person> people = [];
}
