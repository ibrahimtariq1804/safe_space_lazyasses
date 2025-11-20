class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String imageUrl;
  final double rating;
  final int experience;
  final String clinicLocation;
  final String about;
  final List<String> availableDays;
  final bool isAvailable;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.imageUrl,
    required this.rating,
    required this.experience,
    required this.clinicLocation,
    required this.about,
    required this.availableDays,
    this.isAvailable = true,
  });
}

