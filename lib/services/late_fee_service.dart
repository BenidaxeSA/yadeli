/// Frais de retard client / réduction chauffeur en retard
class LateFeeService {
  /// Frais par 5 min de retard du client (en attente du chauffeur)
  static const double clientLateFeePer5Min = 200.0;

  /// Réduction par 5 min de retard du chauffeur/livreur
  static const double driverLateDiscountPer5Min = 150.0;

  /// Calcule les frais si le client est en retard
  static double clientLateFee(int minutesLate) {
    if (minutesLate <= 0) return 0;
    final blocks = (minutesLate / 5).ceil();
    return blocks * clientLateFeePer5Min;
  }

  /// Calcule la réduction si le chauffeur/livreur est en retard
  static double driverLateDiscount(int minutesLate) {
    if (minutesLate <= 0) return 0;
    final blocks = (minutesLate / 5).ceil();
    return blocks * driverLateDiscountPer5Min;
  }

  /// Génère un code promo en cas de retard du chauffeur
  static String generateDelayPromoCode(int minutesLate) {
    if (minutesLate <= 0) return '';
    final discount = driverLateDiscount(minutesLate).round();
    return 'RETARD${minutesLate}MIN-$discount';
  }
}
