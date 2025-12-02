class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String imageUrl;
  final List<VaccinationRecord> vaccinations;
  final String? ownerId;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? weight;
  final List<String>? medicalConditions;
  final List<String>? allergies;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.imageUrl,
    required this.vaccinations,
    this.ownerId,
    this.dateOfBirth,
    this.gender,
    this.weight,
    this.medicalConditions,
    this.allergies,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'imageUrl': imageUrl,
      'vaccinations': vaccinations.map((v) => v.toMap()).toList(),
      'ownerId': ownerId,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'weight': weight,
      'medicalConditions': medicalConditions ?? [],
      'allergies': allergies ?? [],
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      breed: map['breed'] ?? '',
      age: map['age'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      vaccinations: (map['vaccinations'] as List<dynamic>?)
              ?.map((v) => VaccinationRecord.fromMap(v as Map<String, dynamic>))
              .toList() ??
          [],
      ownerId: map['ownerId'],
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      gender: map['gender'],
      weight: map['weight']?.toDouble(),
      medicalConditions: (map['medicalConditions'] as List<dynamic>?)?.cast<String>() ?? [],
      allergies: (map['allergies'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Pet copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    int? age,
    String? imageUrl,
    List<VaccinationRecord>? vaccinations,
    String? ownerId,
    DateTime? dateOfBirth,
    String? gender,
    double? weight,
    List<String>? medicalConditions,
    List<String>? allergies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      imageUrl: imageUrl ?? this.imageUrl,
      vaccinations: vaccinations ?? this.vaccinations,
      ownerId: ownerId ?? this.ownerId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'completed': completed,
    };
  }

  factory VaccinationRecord.fromMap(Map<String, dynamic> map) {
    return VaccinationRecord(
      name: map['name'] ?? '',
      date: DateTime.parse(map['date']),
      completed: map['completed'] ?? false,
    );
  }
}

