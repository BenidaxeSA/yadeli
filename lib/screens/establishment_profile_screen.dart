import 'package:flutter/material.dart';
import '../models/establishment_model.dart';
import '../services/demo_data_service.dart';
import '../services/external_reviews_service.dart';
import '../services/cart_service.dart';
import '../services/user_activity_service.dart';
import '../services/favorites_service.dart';

/// Profil établissement — photos, infos, distance, avis Google/Trustpilot
class EstablishmentProfileScreen extends StatefulWidget {
  final EstablishmentModel? establishment;
  final String? establishmentId;

  const EstablishmentProfileScreen({super.key, this.establishment, this.establishmentId});

  @override
  State<EstablishmentProfileScreen> createState() => _EstablishmentProfileScreenState();
}

class _EstablishmentProfileScreenState extends State<EstablishmentProfileScreen> {
  AggregatedReviews? _reviews;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final e = widget.establishment ?? (widget.establishmentId != null ? DemoDataService.getEstablishmentById(widget.establishmentId!) : null);
    if (e == null) return;
    UserActivityService.logEstablishmentViewed(e.id, e.name, e.category);
    final r = await ExternalReviewsService.getAggregatedReviews(e);
    if (mounted) {
      setState(() => _reviews = r);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.establishment ?? (widget.establishmentId != null ? DemoDataService.getEstablishmentById(widget.establishmentId!) : null);
    if (e == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Établissement"), backgroundColor: Colors.green[700]),
        body: const Center(child: Text("Établissement introuvable")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(e.name),
        backgroundColor: Colors.green[700],
        actions: [
          FutureBuilder<bool>(
            future: FavoritesService.isFavoriteEstablishment(e.id),
            builder: (context, snap) => IconButton(
              icon: Icon(snap.data == true ? Icons.favorite : Icons.favorite_border, color: snap.data == true ? Colors.red : null),
              onPressed: () async {
                final wasFav = snap.data == true;
                if (wasFav) {
                  await FavoritesService.removeFavoriteEstablishment(e.id);
                } else {
                  await FavoritesService.addFavoriteEstablishment({'id': e.id, 'name': e.name, 'category': e.category, 'address': e.address});
                }
                if (mounted) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(wasFav ? "Retiré des favoris" : "Ajouté aux favoris"), behavior: SnackBarBehavior.floating));
                }
              },
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: 180,
            color: Colors.grey[300],
            child: e.photoPath != null && e.photoPath!.startsWith('assets/')
                ? Image.asset(e.photoPath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Icon(Icons.store, size: 80, color: Colors.grey[500])))
                : Center(child: Icon(Icons.store, size: 80, color: Colors.grey[500])),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(label: Text(e.category), backgroundColor: Colors.green[100]),
                    const SizedBox(width: 8),
                    Row(children: [Icon(Icons.star, size: 18, color: Colors.amber[700]), const SizedBox(width: 4), Text(e.rating.toStringAsFixed(1))]),
                    if (e.positiveReviewsCount > 0) ...[const SizedBox(width: 8), Text("${e.positiveReviewsCount} avis Yadeli", style: TextStyle(fontSize: 12, color: Colors.grey[600]))],
                  ],
                ),
                if (_reviews != null) ...[
                  const SizedBox(height: 8),
                  Text("Avis agrégés (Yadeli + Google + Trustpilot): ${_reviews!.averageRating.toStringAsFixed(1)} ★ (${_reviews!.totalCount} avis)", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
                const SizedBox(height: 12),
                Text(e.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [Icon(Icons.location_on, size: 20, color: Colors.green[700]), const SizedBox(width: 8), Expanded(child: Text(e.address))]),
                if (e.openingHours != null && e.closingHours != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [Icon(Icons.schedule, size: 20, color: Colors.green[700]), const SizedBox(width: 8), Text("Ouvert ${e.openingHours} - ${e.closingHours}", style: TextStyle(color: Colors.grey[700]))]),
                ],
                if (e.personality != null) ...[
                  const SizedBox(height: 8),
                  Text(e.personality!, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700])),
                ],
                if (e.quote != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8), border: Border(left: BorderSide(color: Colors.green[700]!, width: 4))),
                    child: Text('"${e.quote}"', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.green[900])),
                  ),
                ],
                if (e.distanceKm > 0) ...[
                  const SizedBox(height: 8),
                  Row(children: [Icon(Icons.straighten, size: 20, color: Colors.green[700]), const SizedBox(width: 8), Text("${e.distanceKm.toStringAsFixed(1)} km de vous")]),
                ],
                if (_reviews != null && (_reviews!.googleReviews.isNotEmpty || _reviews!.trustpilotReviews.isNotEmpty)) ...[
                  const SizedBox(height: 16),
                  const Text("Avis Google / Trustpilot", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...(_reviews!.googleReviews.take(2).map((r) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.star, color: Colors.amber[700], size: 20),
                      title: Text(r.text, style: const TextStyle(fontSize: 13)),
                      subtitle: Text("${r.source} • ${r.rating.toStringAsFixed(1)} ★", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ),
                  ))),
                  ...(_reviews!.trustpilotReviews.take(2).map((r) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.star, color: Colors.amber[700], size: 20),
                      title: Text(r.text, style: const TextStyle(fontSize: 13)),
                      subtitle: Text("${r.source} • ${r.rating.toStringAsFixed(1)} ★", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ),
                  ))),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await CartService.addItem(CartItem(id: e.id, category: e.category, name: e.name, price: 2000, establishmentId: e.id));
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ajouté au panier : ${e.name}"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("Au panier"),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.green[700], side: BorderSide(color: Colors.green[700]!)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Commander chez ${e.name}"), behavior: SnackBarBehavior.floating)),
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("Commander"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
