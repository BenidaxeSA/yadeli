/// Estimation du prix selon le service et la distance — Uber, Bolt, Citymapper
class PriceEstimatorService {
  static const _baseMoto = 800.0;
  static const _perKmMoto = 350.0;
  static const _baseAuto = 1500.0;
  static const _perKmAuto = 500.0;
  static const _basePharmacie = 2000.0;
  static const _perKmPharmacie = 400.0;
  static const _baseLivraison = 1200.0;
  static const _perKmLivraison = 300.0;

  /// Estime la distance en km entre deux lieux (simplifié : zones Brazzaville)
  static double estimateDistanceKm(String from, String to) {
    if (from == to) return 0;
    final zones = ['Poto-Poto', 'Bacongo', 'Ouenzé', 'Moungali', 'Ma Campagne', 'Centre-ville', 'Talangaï', 'Djiri', 'Mfilou', 'Aéroport'];
    int iFrom = zones.indexWhere((z) => from.toLowerCase().contains(z.toLowerCase())) >= 0 ? 1 : 0;
    int iTo = zones.indexWhere((z) => to.toLowerCase().contains(z.toLowerCase())) >= 0 ? 1 : 0;
    final fromIdx = zones.indexWhere((z) => from.toLowerCase().contains(z.toLowerCase()));
    final toIdx = zones.indexWhere((z) => to.toLowerCase().contains(z.toLowerCase()));
    if (fromIdx < 0 || toIdx < 0) return 5.0;
    final diff = (fromIdx - toIdx).abs();
    return (diff * 2.5).clamp(1.0, 15.0);
  }

  static double estimate(String category, String pickup, String delivery) {
    final km = estimateDistanceKm(pickup, delivery);
    switch (category) {
      case 'Moto':
        return _baseMoto + (km * _perKmMoto);
      case 'Auto':
        return _baseAuto + (km * _perKmAuto);
      case 'Pharmacie':
        return _basePharmacie + (km * _perKmPharmacie);
      case 'Alimentaire':
        return 1500 + (km * 350);
      case 'Boutique':
        return 1200 + (km * 300);
      case 'Cosmétique':
        return 1300 + (km * 320);
      case 'Marché':
        return 1000 + (km * 280);
      case 'Livraison':
        return _baseLivraison + (km * _perKmLivraison);
      default:
        return _baseMoto + (km * _perKmMoto);
    }
  }

  /// ETA en minutes (Citymapper)
  static int estimateEtaMinutes(String pickup, String delivery) {
    final km = estimateDistanceKm(pickup, delivery);
    return (km * 4).round().clamp(3, 45);
  }
}
