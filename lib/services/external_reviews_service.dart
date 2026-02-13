import '../models/establishment_model.dart';

/// Avis externes Google / Trustpilot — API tierces
/// En production : Google Places API, Trustpilot API
class ExternalReviewsService {
  /// Récupère les avis Google pour un établissement
  /// Nécessite une clé API Google Places
  static Future<List<ExternalReview>> getGoogleReviews(EstablishmentModel establishment) async {
    // Mode démo : avis simulés basés sur les données existantes
    return _mockReviews(establishment, 'Google');
  }

  /// Récupère les avis Trustpilot
  static Future<List<ExternalReview>> getTrustpilotReviews(EstablishmentModel establishment) async {
    return _mockReviews(establishment, 'Trustpilot');
  }

  /// Combine avis Yadeli + Google + Trustpilot
  static Future<AggregatedReviews> getAggregatedReviews(EstablishmentModel establishment) async {
    final google = await getGoogleReviews(establishment);
    final trustpilot = await getTrustpilotReviews(establishment);
    final all = [...google, ...trustpilot];
    final avg = all.isEmpty ? establishment.rating : all.map((r) => r.rating).reduce((a, b) => a + b) / all.length;
    return AggregatedReviews(
      averageRating: avg,
      totalCount: establishment.positiveReviewsCount + all.length,
      googleReviews: google,
      trustpilotReviews: trustpilot,
      yadeliRating: establishment.rating,
      yadeliCount: establishment.positiveReviewsCount,
    );
  }

  static List<ExternalReview> _mockReviews(EstablishmentModel e, String source) {
    return [
      ExternalReview(author: 'Client $source', rating: e.rating.clamp(4.0, 5.0), text: 'Très bon service, livraison rapide.', date: DateTime.now().subtract(const Duration(days: 2)), source: source),
      ExternalReview(author: 'Utilisateur', rating: (e.rating - 0.2).clamp(3.5, 5.0), text: 'Correct, un peu d\'attente.', date: DateTime.now().subtract(const Duration(days: 5)), source: source),
      ExternalReview(author: 'Avis vérifié', rating: (e.rating + 0.1).clamp(4.0, 5.0), text: 'Je recommande ${e.name}.', date: DateTime.now().subtract(const Duration(days: 10)), source: source),
    ];
  }
}

class ExternalReview {
  final String author;
  final double rating;
  final String text;
  final DateTime date;
  final String source;

  ExternalReview({required this.author, required this.rating, required this.text, required this.date, required this.source});
}

class AggregatedReviews {
  final double averageRating;
  final int totalCount;
  final List<ExternalReview> googleReviews;
  final List<ExternalReview> trustpilotReviews;
  final double yadeliRating;
  final int yadeliCount;

  AggregatedReviews({
    required this.averageRating,
    required this.totalCount,
    required this.googleReviews,
    required this.trustpilotReviews,
    required this.yadeliRating,
    required this.yadeliCount,
  });
}
