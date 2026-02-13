/// Modèle établissement (pharmacie, restaurant, etc.)
class EstablishmentModel {
  final String id;
  final String name;
  final String address;
  final String? photoPath;
  final double lat;
  final double lng;
  final double distanceKm;
  final String category;
  final double rating;
  final int positiveReviewsCount;
  final int visitsCount;
  final String? openingHours;   // ex: "08:00"
  final String? closingHours;   // ex: "20:00"
  final String? personality;    // description personnalité
  final String? quote;          // citation

  EstablishmentModel({
    required this.id,
    required this.name,
    required this.address,
    this.photoPath,
    required this.lat,
    required this.lng,
    this.distanceKm = 0,
    this.category = 'Établissement',
    this.rating = 4.0,
    this.positiveReviewsCount = 0,
    this.visitsCount = 0,
    this.openingHours,
    this.closingHours,
    this.personality,
    this.quote,
  });
}
