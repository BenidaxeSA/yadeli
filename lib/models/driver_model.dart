/// Modèle chauffeur/livreur — profil complet Yadeli
class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String? photoPath;
  final String gender; // homme, femme
  final List<String> languages; // FR, EN, Lingala, Kituba
  final String vehicleType; // moto_classique, moto_electrique, auto_classique, auto_electrique, velo_classique, velo_electrique, bicyclette_classique, bicyclette_electrique, trotinette_classique, trotinette_electrique
  final String licensePlate;
  final String? companyLicensePlate;
  final bool hasYadeliBadge;
  final double rating;
  final int positiveReviewsCount;
  final double lat;
  final double lng;
  final String? address;
  final double? distanceKm;
  final String? personality;  // description personnalité
  final String? quote;        // citation

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    this.photoPath,
    this.gender = 'homme',
    this.languages = const ['FR', 'Lingala'],
    required this.vehicleType,
    required this.licensePlate,
    this.companyLicensePlate,
    this.hasYadeliBadge = true,
    this.rating = 4.5,
    this.positiveReviewsCount = 0,
    required this.lat,
    required this.lng,
    this.address,
    this.distanceKm,
    this.personality,
    this.quote,
  });

  String get vehicleLabel {
    const map = {
      'moto_classique': 'Moto (classique)',
      'moto_electrique': 'Moto (électrique)',
      'auto_classique': 'Voiture (classique)',
      'auto_electrique': 'Voiture (électrique)',
      'velo_classique': 'Vélo (classique)',
      'velo_electrique': 'Vélo (électrique)',
      'bicyclette_classique': 'Bicyclette (classique)',
      'bicyclette_electrique': 'Bicyclette (électrique)',
      'trotinette_classique': 'Trotinette (classique)',
      'trotinette_electrique': 'Trotinette (électrique)',
    };
    return map[vehicleType] ?? vehicleType;
  }

  String get genderLabel => gender == 'femme' ? 'Femme' : 'Homme';
}
