import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Obtient la position GPS actuelle et convertit en adresse lisible
  static Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(success: false, message: "Service de localisation désactivé. Activez-le dans les paramètres.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return LocationResult(success: false, message: "Permission refusée définitivement.");
      }
      if (permission == LocationPermission.denied) {
        return LocationResult(success: false, message: "Permission de localisation refusée.");
      }

      final position = await Geolocator.getCurrentPosition();
      final lat = position.latitude;
      final lng = position.longitude;

      // Géocodage inverse : coordonnées -> adresse
      String address = "Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}";
      try {
        final places = await placemarkFromCoordinates(lat, lng);
        if (places.isNotEmpty) {
          final p = places.first;
          final parts = [
            if (p.street != null && p.street!.isNotEmpty) p.street,
            if (p.subLocality != null && p.subLocality!.isNotEmpty) p.subLocality,
            if (p.locality != null && p.locality!.isNotEmpty) p.locality,
            if (p.country != null && p.country!.isNotEmpty) p.country,
          ].whereType<String>().toList();
          if (parts.isNotEmpty) address = parts.join(", ");
        }
      } catch (_) {}

      return LocationResult(
        success: true,
        latitude: lat,
        longitude: lng,
        message: address,
      );
    } catch (e) {
      return LocationResult(success: false, message: "Impossible d'obtenir la position: ${e.toString().split('\n').first}");
    }
  }
}

class LocationResult {
  final bool success;
  final double? latitude;
  final double? longitude;
  final String message;

  LocationResult({required this.success, this.latitude, this.longitude, required this.message});
}
