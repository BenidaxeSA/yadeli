import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../services/demo_data_service.dart';
import '../services/user_activity_service.dart';
import '../services/favorites_service.dart';
import '../widgets/avatar_widget.dart';

/// Profil complet chauffeur/livreur — nom, coordonnées, position, véhicule, badge Yadeli
class DriverProfileScreen extends StatefulWidget {
  final DriverModel? driver;
  final String? driverId;

  const DriverProfileScreen({super.key, this.driver, this.driverId});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  bool _favRefresh = false;

  @override
  void initState() {
    super.initState();
    final d = widget.driver ?? (widget.driverId != null ? DemoDataService.getDriverById(widget.driverId!) : null);
    if (d != null) UserActivityService.logDriverViewed(d.id, d.name);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.driver ?? (widget.driverId != null ? DemoDataService.getDriverById(widget.driverId!) : null);
    if (d == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chauffeur"), backgroundColor: Colors.green[700]),
        body: const Center(child: Text("Chauffeur introuvable")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil chauffeur"),
        backgroundColor: Colors.green[700],
        actions: [
          FutureBuilder<bool>(
            future: FavoritesService.isFavoriteDriver(d.id),
            builder: (context, snap) => IconButton(
              icon: Icon(snap.data == true ? Icons.favorite : Icons.favorite_border, color: snap.data == true ? Colors.red : null),
              onPressed: () async {
                final wasFav = snap.data == true;
                if (wasFav) {
                  await FavoritesService.removeFavoriteDriver(d.id);
                } else {
                  await FavoritesService.addFavoriteDriver({'id': d.id, 'name': d.name, 'phone': d.phone});
                }
                if (mounted) {
                  setState(() => _favRefresh = !_favRefresh);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(wasFav ? "Retiré des favoris" : "Ajouté aux favoris"), behavior: SnackBarBehavior.floating));
                }
              },
            ),
          ),
          IconButton(icon: const Icon(Icons.phone), onPressed: () => _call(context, d.phone)),
          IconButton(icon: const Icon(Icons.share), onPressed: () => _share(context)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                AvatarWidget(photoPath: d.photoPath, gender: d.gender, radius: 50),
                if (d.hasYadeliBadge)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.verified, color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(d.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          if (d.hasYadeliBadge) Center(child: Chip(label: const Text("Chauffeur Yadeli vérifié"), backgroundColor: Colors.green[100], avatar: Icon(Icons.check_circle, color: Colors.green[700], size: 18))),
          const SizedBox(height: 24),
          _buildCard("Coordonnées", [
            _row(Icons.phone, "Téléphone", d.phone, onTap: () => _call(context, d.phone)),
            _row(Icons.location_on, "Position", d.address ?? "Brazzaville"),
          ]),
          const SizedBox(height: 16),
          if (d.personality != null || d.quote != null) ...[
            _buildCard("Personnalité", [
              if (d.personality != null) _row(Icons.person, "Description", d.personality!),
              if (d.quote != null) _row(Icons.format_quote, "Citation", '"${d.quote}"'),
            ]),
            const SizedBox(height: 16),
          ],
          _buildCard("Profil", [
            _row(Icons.wc, "Genre", d.genderLabel),
            _row(Icons.translate, "Langues parlées", d.languages.join(", ")),
            _row(Icons.star, "Note", "${d.rating.toStringAsFixed(1)} (${d.positiveReviewsCount} avis positifs)"),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Icon(Icons.security, color: Colors.orange[800]), const SizedBox(width: 8), Text("Vérifier l'identité", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900]))]),
                const SizedBox(height: 8),
                Text("Avant d'accepter : vérifiez que la personne, la plaque (${d.licensePlate}) et le badge Yadeli sur le véhicule correspondent. En cas de doute, refusez et contactez le support.", style: TextStyle(fontSize: 13, color: Colors.orange[900])),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCard("Véhicule", [
            _row(Icons.directions_car, "Type", d.vehicleLabel),
            _row(Icons.confirmation_number, "Plaque", d.licensePlate),
            if (d.companyLicensePlate != null) _row(Icons.business, "Plaque entreprise", d.companyLicensePlate!),
            if (d.hasYadeliBadge) _row(Icons.verified, "Badge Yadeli", "Véhicule étiqueté Yadeli"),
          ]),
        ],
      ),
    );
  }

  void _call(BuildContext context, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Appel: $phone"), behavior: SnackBarBehavior.floating));
  }

  void _share(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lien partagé !"), behavior: SnackBarBehavior.floating));
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700])),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.green[700], size: 22),
            const SizedBox(width: 12),
            Text("$label : ", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}
