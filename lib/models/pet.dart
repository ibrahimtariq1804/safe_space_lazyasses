class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String imageUrl;
  final List<VaccinationRecord> vaccinations;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.imageUrl,
    required this.vaccinations,
  });
}

class VaccinationRecord {
  final String name;
  final DateTime date;
  final bool completed;

  VaccinationRecord({
    required this.name,
    required this.date,
    required this.completed,
  });
}

