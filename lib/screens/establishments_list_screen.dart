import 'package:flutter/material.dart';
import '../models/establishment_model.dart';
import '../services/demo_data_service.dart';
import 'establishment_profile_screen.dart';

/// Liste des établissements avec distance GPS, suggestions proches
class EstablishmentsListScreen extends StatefulWidget {
  const EstablishmentsListScreen({super.key});

  @override
  State<EstablishmentsListScreen> createState() => _EstablishmentsListScreenState();
}

class _EstablishmentsListScreenState extends State<EstablishmentsListScreen> {
  List<EstablishmentModel> _list = [];
  bool _loading = true;
  String? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await DemoDataService.getEstablishmentsNearby(category: _categoryFilter);
    if (mounted) setState(() {
      _list = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Établissements à proximité"),
        backgroundColor: Colors.green[700],
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) {
              setState(() {
                _categoryFilter = v == 'all' ? null : v;
                _load();
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'all', child: Text("Tous")),
              const PopupMenuItem(value: 'Pharmacie', child: Text("Pharmacies")),
              const PopupMenuItem(value: 'Restaurant', child: Text("Restaurants")),
              const PopupMenuItem(value: 'Commerce', child: Text("Commerces")),
              const PopupMenuItem(value: 'Hôpital', child: Text("Hôpitaux")),
              const PopupMenuItem(value: 'École', child: Text("Écoles / Formation")),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(child: Text("Aucun établissement à proximité"))
              : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Mieux notés (les mieux notés et avis positifs en premier)", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ),
            Expanded(
              child: RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _list.length,
                    itemBuilder: (context, i) {
                      final e = _list[i];
                      final leadingWidget = e.photoPath != null && e.photoPath!.startsWith('assets/')
                          ? Image.asset(e.photoPath!, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: Colors.green[100], child: Icon(Icons.store, color: Colors.green[700], size: 32)))
                          : Container(width: 56, height: 56, color: Colors.green[100], child: Icon(Icons.store, color: Colors.green[700], size: 32));
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: leadingWidget),
                          title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.address, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.straighten, size: 14, color: Colors.green[700]),
                                  const SizedBox(width: 4),
                                  Text("${e.distanceKm.toStringAsFixed(1)} km", style: TextStyle(fontSize: 12, color: Colors.green[700])),
                                  const SizedBox(width: 12),
                                  Icon(Icons.star, size: 14, color: Colors.amber[700]),
                                  const SizedBox(width: 2),
                                  Text("${e.rating.toStringAsFixed(1)} • ${e.positiveReviewsCount} avis", style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EstablishmentProfileScreen(establishment: e))),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      );
  }
}
