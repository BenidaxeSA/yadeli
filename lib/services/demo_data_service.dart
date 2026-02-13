import 'dart:math';
import '../models/driver_model.dart';
import '../models/establishment_model.dart';
import 'location_service.dart';

/// Données démo : chauffeurs, livreurs, établissements
class DemoDataService {
  static const brazzavilleCenterLat = -4.2634;
  static const brazzavilleCenterLng = 15.2832;

  static final List<DriverModel> drivers = [
    DriverModel(id: 'd1', name: 'Jean-Marc Okemba', phone: '+242 06 123 45 67', photoPath: 'assets/images/img3.jpg', gender: 'homme', languages: ['FR', 'Lingala'], vehicleType: 'moto_classique', licensePlate: 'CG-1234-A', companyLicensePlate: 'YAD-M01', hasYadeliBadge: true, rating: 4.8, positiveReviewsCount: 156, lat: -4.265, lng: 15.285, address: 'Poto-Poto', personality: 'Ponctuel, souriant, professionnel', quote: 'Sécurité et ponctualité avant tout'),
    DriverModel(id: 'd2', name: 'Marie Nkounkou', phone: '+242 06 234 56 78', photoPath: 'assets/images/img4.jpg', gender: 'femme', languages: ['FR', 'Kituba'], vehicleType: 'auto_classique', licensePlate: 'CG-5678-B', companyLicensePlate: 'YAD-A02', hasYadeliBadge: true, rating: 4.6, positiveReviewsCount: 89, lat: -4.260, lng: 15.280, address: 'Bacongo', personality: 'Accueillante, professionnelle', quote: 'Votre confort est ma priorité'),
    DriverModel(id: 'd3', name: 'Patrick Mbemba', phone: '+242 06 345 67 89', photoPath: 'assets/images/4k.jpg', gender: 'homme', languages: ['FR', 'EN', 'Lingala'], vehicleType: 'moto_electrique', licensePlate: 'CG-9012-C', companyLicensePlate: 'YAD-M01', hasYadeliBadge: true, rating: 4.9, positiveReviewsCount: 203, lat: -4.268, lng: 15.278, address: 'Ouenzé', personality: 'Rapide et fiable', quote: 'Livraison express, toujours à l\'heure'),
    DriverModel(id: 'd4', name: 'Grace Tchicaya', phone: '+242 06 456 78 90', photoPath: 'assets/images/img4.jpg', gender: 'femme', languages: ['FR'], vehicleType: 'velo_classique', licensePlate: '-', hasYadeliBadge: true, rating: 4.5, positiveReviewsCount: 67, lat: -4.262, lng: 15.286, address: 'Moungali', personality: 'Écologique, souriante', quote: 'Le vélo, c\'est la vie'),
    DriverModel(id: 'd5', name: 'David Nguesso', phone: '+242 06 567 89 01', photoPath: 'assets/images/img3.jpg', gender: 'homme', languages: ['FR', 'Lingala', 'Kituba'], vehicleType: 'auto_electrique', licensePlate: 'CG-3456-D', companyLicensePlate: 'YAD-001', hasYadeliBadge: true, rating: 4.7, positiveReviewsCount: 112, lat: -4.264, lng: 15.282, address: 'Ma Campagne', personality: 'Calme, expérimenté', quote: 'Conduire en toute sérénité'),
    DriverModel(id: 'd6', name: 'Fabrice Ngambou', phone: '+242 06 678 90 12', photoPath: 'assets/images/4k.jpg', gender: 'homme', languages: ['FR', 'Lingala'], vehicleType: 'trotinette_electrique', licensePlate: '-', hasYadeliBadge: true, rating: 4.4, positiveReviewsCount: 45, lat: -4.267, lng: 15.281, address: 'Poto-Poto', personality: 'Dynamique, agile', quote: 'Rapidité urbaine'),
    DriverModel(id: 'd7', name: 'Sylvie Mbombo', phone: '+242 06 789 01 23', photoPath: 'assets/images/img4.jpg', gender: 'femme', languages: ['FR', 'Kituba'], vehicleType: 'bicyclette_electrique', licensePlate: '-', hasYadeliBadge: true, rating: 4.6, positiveReviewsCount: 78, lat: -4.259, lng: 15.277, address: 'Bacongo', personality: 'Discrete et efficace', quote: 'Livraison en douceur'),
  ];

  static final List<EstablishmentModel> establishments = [
    EstablishmentModel(id: 'e1', name: 'Pharmacie du Centre', address: 'Poto-Poto Centre', photoPath: 'assets/images/img3.jpg', lat: -4.264, lng: 15.283, category: 'Pharmacie', rating: 4.5, positiveReviewsCount: 89, visitsCount: 1200, openingHours: '07:00', closingHours: '21:00', personality: 'Établissement de confiance, service rapide', quote: 'Votre santé, notre priorité'),
    EstablishmentModel(id: 'e2', name: 'Pharmacie Bacongo', address: 'Bacongo Sud', photoPath: 'assets/images/img4.jpg', lat: -4.258, lng: 15.278, category: 'Pharmacie', rating: 4.3, positiveReviewsCount: 56, visitsCount: 890, openingHours: '08:00', closingHours: '20:00', personality: 'Proximité et qualité', quote: 'Votre pharmacie de quartier'),
    EstablishmentModel(id: 'e3', name: 'Restaurant Le Congolais', address: 'Ouenzé 1', photoPath: 'assets/images/jeux-4k.jpg', lat: -4.270, lng: 15.275, category: 'Restaurant', rating: 4.6, positiveReviewsCount: 134, visitsCount: 2100, openingHours: '10:00', closingHours: '22:00', personality: 'Cuisine traditionnelle authentique', quote: 'Le goût du Congo'),
    EstablishmentModel(id: 'e4', name: 'Super Marché Total', address: 'Marché Total', photoPath: 'assets/images/4k.jpg', lat: -4.262, lng: 15.288, category: 'Commerce', rating: 4.2, positiveReviewsCount: 78, visitsCount: 3400, openingHours: '07:00', closingHours: '21:00', personality: 'Grand choix, prix bas', quote: 'Tout pour votre quotidien'),
    EstablishmentModel(id: 'e5', name: 'Pharmacie Mongali', address: 'Moungali 2', photoPath: 'assets/images/img3.jpg', lat: -4.266, lng: 15.290, category: 'Pharmacie', rating: 4.7, positiveReviewsCount: 112, visitsCount: 1560, openingHours: '07:30', closingHours: '20:30', personality: 'Conseils et disponibilité', quote: 'Votre santé, notre engagement'),
    EstablishmentModel(id: 'e6', name: 'Snack Ma Campagne', address: 'Ma Campagne', photoPath: 'assets/images/img4.jpg', lat: -4.268, lng: 15.280, category: 'Restaurant', rating: 4.4, positiveReviewsCount: 67, visitsCount: 980, openingHours: '06:00', closingHours: '23:00', personality: 'Rapide et savoureux', quote: 'Snack à toute heure'),
    EstablishmentModel(id: 'e7', name: 'Hôpital Central', address: 'Poto-Poto', photoPath: 'assets/images/image.png', lat: -4.263, lng: 15.284, category: 'Hôpital', rating: 4.6, positiveReviewsCount: 201, visitsCount: 5200, openingHours: '00:00', closingHours: '23:59', personality: 'Soins d\'urgence 24h/24', quote: 'Votre santé, notre priorité'),
    EstablishmentModel(id: 'e8', name: 'Université Marien Ngouabi', address: 'Plateau des 15 ans', photoPath: 'assets/images/image1.jpg', lat: -4.261, lng: 15.279, category: 'École', rating: 4.5, positiveReviewsCount: 156, visitsCount: 8900, openingHours: '07:00', closingHours: '17:00', personality: 'Excellence académique', quote: 'Former les leaders de demain'),
  ];

  static double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) + cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRad(double deg) => deg * pi / 180;

  static Future<List<DriverModel>> getDriversNearby({double? userLat, double? userLng, double radiusKm = 100}) async {
    double lat = userLat ?? brazzavilleCenterLat;
    double lng = userLng ?? brazzavilleCenterLng;
    try {
      final loc = await LocationService.getCurrentLocation();
      if (loc.success && loc.latitude != null && loc.longitude != null) {
        final locLat = loc.latitude!;
        final locLng = loc.longitude!;
        if (locLat.abs() < 90 && locLng.abs() < 180) {
          lat = locLat;
          lng = locLng;
        }
      }
    } catch (_) {}
    final result = <DriverModel>[];
    for (final d in drivers) {
      final km = _haversineKm(lat, lng, d.lat, d.lng);
      if (km <= radiusKm) result.add(DriverModel(id: d.id, name: d.name, phone: d.phone, photoPath: d.photoPath, gender: d.gender, languages: d.languages, vehicleType: d.vehicleType, licensePlate: d.licensePlate, companyLicensePlate: d.companyLicensePlate, hasYadeliBadge: d.hasYadeliBadge, rating: d.rating, positiveReviewsCount: d.positiveReviewsCount, lat: d.lat, lng: d.lng, address: d.address, distanceKm: km));
    }
    if (result.isEmpty) {
      for (final d in drivers) {
        final km = _haversineKm(brazzavilleCenterLat, brazzavilleCenterLng, d.lat, d.lng);
        result.add(DriverModel(id: d.id, name: d.name, phone: d.phone, photoPath: d.photoPath, gender: d.gender, languages: d.languages, vehicleType: d.vehicleType, licensePlate: d.licensePlate, companyLicensePlate: d.companyLicensePlate, hasYadeliBadge: d.hasYadeliBadge, rating: d.rating, positiveReviewsCount: d.positiveReviewsCount, lat: d.lat, lng: d.lng, address: d.address, distanceKm: km, personality: d.personality, quote: d.quote));
      }
    }
    result.sort((a, b) {
      final scoreA = a.rating * 10 + a.positiveReviewsCount * 0.01;
      final scoreB = b.rating * 10 + b.positiveReviewsCount * 0.01;
      return scoreB.compareTo(scoreA);
    });
    return result;
  }

  static Future<List<EstablishmentModel>> getEstablishmentsNearby({double? userLat, double? userLng, String? category, double radiusKm = 100}) async {
    double lat = userLat ?? brazzavilleCenterLat;
    double lng = userLng ?? brazzavilleCenterLng;
    try {
      final loc = await LocationService.getCurrentLocation();
      if (loc.success && loc.latitude != null && loc.longitude != null) {
        final locLat = loc.latitude!;
        final locLng = loc.longitude!;
        if (locLat.abs() < 90 && locLng.abs() < 180) {
          lat = locLat;
          lng = locLng;
        }
      }
    } catch (_) {}
    final result = <EstablishmentModel>[];
    for (final e in establishments) {
      if (category != null && e.category != category) continue;
      final km = _haversineKm(lat, lng, e.lat, e.lng);
      if (km <= radiusKm) result.add(EstablishmentModel(id: e.id, name: e.name, address: e.address, photoPath: e.photoPath, lat: e.lat, lng: e.lng, distanceKm: km, category: e.category, rating: e.rating, positiveReviewsCount: e.positiveReviewsCount, visitsCount: e.visitsCount, openingHours: e.openingHours, closingHours: e.closingHours, personality: e.personality, quote: e.quote));
    }
    if (result.isEmpty) {
      for (final e in establishments) {
        if (category != null && e.category != category) continue;
        final km = _haversineKm(brazzavilleCenterLat, brazzavilleCenterLng, e.lat, e.lng);
        result.add(EstablishmentModel(id: e.id, name: e.name, address: e.address, photoPath: e.photoPath, lat: e.lat, lng: e.lng, distanceKm: km, category: e.category, rating: e.rating, positiveReviewsCount: e.positiveReviewsCount, visitsCount: e.visitsCount, openingHours: e.openingHours, closingHours: e.closingHours, personality: e.personality, quote: e.quote));
      }
    }
    result.sort((a, b) {
      final scoreA = a.rating * 10 + (a.positiveReviewsCount * 0.01);
      final scoreB = b.rating * 10 + (b.positiveReviewsCount * 0.01);
      return scoreB.compareTo(scoreA);
    });
    return result;
  }

  static DriverModel? getDriverById(String id) {
    try {
      return drivers.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  static EstablishmentModel? getEstablishmentById(String id) {
    try {
      return establishments.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
