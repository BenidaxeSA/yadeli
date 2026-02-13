import 'package:flutter/material.dart';
import '../services/price_estimator_service.dart';
import '../services/location_service.dart';
import 'search_screen.dart';
import 'order_details_screen.dart';

/// Flux de réservation complet — Uber, Bolt, Citymapper
/// Départ → Destination → Service → Estimation prix → Confirmation
class BookingFlowScreen extends StatefulWidget {
  final String? initialCategory;

  const BookingFlowScreen({super.key, this.initialCategory});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  String? _pickup;
  String? _destination;
  String? _selectedCategory;
  double? _estimatedPrice;
  int? _etaMinutes;

  static const _services = [
    _ServiceData(icon: Icons.motorcycle, color: Colors.green, title: "Moto Express", category: "Moto"),
    _ServiceData(icon: Icons.directions_car, color: Colors.blue, title: "Yadeli Auto", category: "Auto"),
    _ServiceData(icon: Icons.local_pharmacy, color: Colors.red, title: "Pharmacie", category: "Pharmacie"),
    _ServiceData(icon: Icons.restaurant, color: Colors.amber, title: "Alimentaire", category: "Alimentaire"),
    _ServiceData(icon: Icons.store, color: Colors.purple, title: "Boutique", category: "Boutique"),
    _ServiceData(icon: Icons.face, color: Colors.pink, title: "Cosmétique", category: "Cosmétique"),
    _ServiceData(icon: Icons.shopping_basket, color: Colors.teal, title: "Marché", category: "Marché"),
    _ServiceData(icon: Icons.inventory_2, color: Colors.orange, title: "Livraison Colis", category: "Livraison"),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) _selectedCategory = widget.initialCategory;
  }

  Future<void> _pickLocation(bool isPickup) async {
    if (isPickup) {
      final useCurrent = await showModalBottomSheet<bool>(
        context: context,
        builder: (_) => SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(leading: const Icon(Icons.my_location), title: const Text("Utiliser ma position"), onTap: () => Navigator.pop(context, true)),
            ListTile(leading: const Icon(Icons.search), title: const Text("Choisir une adresse"), onTap: () => Navigator.pop(context, false)),
          ]),
        ),
      );
      if (useCurrent == true && mounted) {
        final loc = await LocationService.getCurrentLocation();
        if (loc.success && loc.message.isNotEmpty && mounted) {
          _pickup = loc.message;
          _recomputeEstimate();
          setState(() {});
        }
      } else if (useCurrent == false && mounted) {
        final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => SearchScreen(mode: SearchMode.pickup)));
        if (result != null && mounted) {
          _pickup = result;
          _recomputeEstimate();
          setState(() {});
        }
      }
      return;
    }
    final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => SearchScreen(mode: SearchMode.destination)));
    if (result != null && mounted) {
      _destination = result;
      _recomputeEstimate();
      setState(() {});
    }
  }

  void _recomputeEstimate() {
    final p = _pickup ?? 'Ma Campagne';
    final d = _destination ?? 'Poto-Poto';
    if (_selectedCategory != null && d.isNotEmpty) {
      _estimatedPrice = PriceEstimatorService.estimate(_selectedCategory!, p, d);
      _etaMinutes = PriceEstimatorService.estimateEtaMinutes(p, d);
    }
  }

  void _goToOrderDetails() {
    final p = _pickup ?? 'Ma Campagne';
    final d = _destination;
    if (d == null || d.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Choisissez une destination"), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
      return;
    }
    if (_selectedCategory == null || _estimatedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Choisissez un service"), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailsScreen(
      pickup: p,
      delivery: d,
      category: _selectedCategory!,
      price: _estimatedPrice!,
      etaMinutes: _etaMinutes ?? 10,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Réserver une course"),
        backgroundColor: Colors.green[700],
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAddressRow(Icons.trip_origin, "Départ", _pickup ?? "Position actuelle", () => _pickLocation(true)),
            const Divider(height: 24),
            _buildAddressRow(Icons.location_on, "Destination", _destination ?? "Où allons-nous ?", () => _pickLocation(false)),
            const SizedBox(height: 24),
            const Text("Choisir un service", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._services.map((s) => _buildServiceOption(s)),
            if (_estimatedPrice != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Prix estimé", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("${_estimatedPrice!.round()} XAF", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green[800])),
                      ]),
                      if (_etaMinutes != null) Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(children: [Icon(Icons.access_time, size: 18, color: Colors.green[700]), const SizedBox(width: 6), Text("Arrivée dans ~$_etaMinutes min", style: TextStyle(color: Colors.green[800]))]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToOrderDetails,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("AJOUTER LES DÉTAILS ET CONFIRMER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.green[700])),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: value.contains("?") ? Colors.grey : Colors.black)),
              ]),
            ),
            const Icon(Icons.edit, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceOption(_ServiceData s) {
    final selected = _selectedCategory == s.category;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: selected ? Colors.green[50] : null,
      child: ListTile(
        onTap: () {
          _selectedCategory = s.category;
          _recomputeEstimate();
          setState(() {});
        },
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: s.color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(s.icon, color: s.color, size: 28)),
        title: Text(s.title, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.green[800] : null)),
        trailing: selected ? Icon(Icons.check_circle, color: Colors.green[700]) : null,
      ),
    );
  }
}

class _ServiceData {
  final IconData icon;
  final Color color;
  final String title;
  final String category;
  const _ServiceData({required this.icon, required this.color, required this.title, required this.category});
}
