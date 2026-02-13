import 'package:flutter/material.dart';
import '../services/address_service.dart';

/// Mode de recherche : départ ou destination
enum SearchMode { pickup, destination }

/// Liste étendue de lieux à Brazzaville (recherche dynamique avec suggestions)
const _allPlaces = [
  "Poto-Poto",
  "Bacongo",
  "Ouenzé",
  "Moungali",
  "Ma Campagne",
  "Centre-ville Brazzaville",
  "Aéroport Maya-Maya",
  "Moungali 1",
  "Moungali 2",
  "Moungali 3",
  "Poto-Poto Centre",
  "Poto-Poto Nord",
  "Bacongo Sud",
  "Bacongo Centre",
  "Ouenzé 1",
  "Ouenzé 2",
  "Ouenzé 3",
  "Talangaï",
  "Madibou",
  "Djiri",
  "Mfilou",
  "Ngambé",
  "Plateau des 15 ans",
  "Hôpital central",
  "Marché Total",
  "Gare routière Ouenzé",
  "Stade Alphonse Massamba-Débat",
  "Palais du peuple",
  "Centre culturel français",
  "Consulat France",
  "Embassy USA",
  "Université Marien Ngouabi",
];

class SearchScreen extends StatefulWidget {
  final SearchMode mode;

  const SearchScreen({super.key, this.mode = SearchMode.destination});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<String> _filtered = List.from(_allPlaces);
  Map<String, String?> _savedAddresses = {};

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
    AddressService.getAll().then((m) => mounted ? setState(() => _savedAddresses = m) : null);
  }

  void _onQueryChanged() {
    final q = _controller.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.from(_allPlaces);
      } else {
        _filtered = _allPlaces.where((s) => s.toLowerCase().contains(q)).toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    super.dispose();
  }

  void _selectDestination(BuildContext context, String dest) {
    Navigator.pop(context, dest);
  }

  @override
  Widget build(BuildContext context) {
    final isPickup = widget.mode == SearchMode.pickup;
    return Scaffold(
      appBar: AppBar(
        title: Text(isPickup ? "Lieu de prise en charge" : "Où allons-nous ?"),
        backgroundColor: Colors.green[700],
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: isPickup ? "Adresse de départ..." : "Rechercher une adresse à Brazzaville...",
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onSubmitted: (q) {
                if (q.trim().isNotEmpty) _selectDestination(context, q.trim());
              },
            ),
          ),
          if (_savedAddresses['home'] != null || _savedAddresses['work'] != null || _savedAddresses['school'] != null || _savedAddresses['hospital'] != null || _savedAddresses['pharmacy'] != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(alignment: Alignment.centerLeft, child: Text("Adresses favorites", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green[700]))),
            ),
            if (_savedAddresses['home'] != null)
              ListTile(leading: const Icon(Icons.home, color: Colors.green), title: const Text("Maison"), subtitle: Text(_savedAddresses['home']!), onTap: () => _selectDestination(context, _savedAddresses['home']!)),
            if (_savedAddresses['work'] != null)
              ListTile(leading: const Icon(Icons.work, color: Colors.blue), title: const Text("Travail"), subtitle: Text(_savedAddresses['work']!), onTap: () => _selectDestination(context, _savedAddresses['work']!)),
            if (_savedAddresses['school'] != null)
              ListTile(leading: const Icon(Icons.school, color: Colors.purple), title: const Text("École / Formation"), subtitle: Text(_savedAddresses['school']!), onTap: () => _selectDestination(context, _savedAddresses['school']!)),
            if (_savedAddresses['hospital'] != null)
              ListTile(leading: const Icon(Icons.local_hospital, color: Colors.red), title: const Text("Hôpital"), subtitle: Text(_savedAddresses['hospital']!), onTap: () => _selectDestination(context, _savedAddresses['hospital']!)),
            if (_savedAddresses['pharmacy'] != null)
              ListTile(leading: const Icon(Icons.local_pharmacy, color: Colors.orange), title: const Text("Pharmacie"), subtitle: Text(_savedAddresses['pharmacy']!), onTap: () => _selectDestination(context, _savedAddresses['pharmacy']!)),
            const Divider(),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _filtered.isEmpty ? "Aucun résultat" : "Suggestions (${_filtered.length})",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text("Aucun lieu trouvé.\nTapez le nom d'un quartier ou d'une adresse.", textAlign: TextAlign.center))
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final s = _filtered[i];
                      return ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.green),
                        title: Text(s),
                        onTap: () => _selectDestination(context, s),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
