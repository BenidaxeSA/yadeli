import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'ride_in_progress_screen.dart';
import '../services/order_service.dart';
import '../services/favorites_service.dart';

/// Détails de la commande avant confirmation — instructions, adresse, délégué, image
class OrderDetailsScreen extends StatefulWidget {
  final String pickup;
  final String delivery;
  final String category;
  final double price;
  final int etaMinutes;

  const OrderDetailsScreen({super.key, required this.pickup, required this.delivery, required this.category, required this.price, required this.etaMinutes});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

/// Supplément pour réserver un chauffeur favori (selon disponibilités)
const _preferredDriverFee = 500.0;

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _instructionsController = TextEditingController();
  final _delegateNameController = TextEditingController();
  final _delegatePhoneController = TextEditingController();
  final _arrondissementController = TextEditingController();
  final _rueController = TextEditingController();
  final _zoneController = TextEditingController();
  final _quartierController = TextEditingController();
  final _referenceController = TextEditingController();
  final _retraitBoutiqueController = TextEditingController();
  bool _delegateSomeone = false;
  String? _addressType; // maison, bidonville, endroit_recule, etc.
  final List<String> _dropOffImages = [];
  bool _loading = false;
  List<Map<String, dynamic>> _favoriteDrivers = [];
  String _selectedPreferredDriverId = '';

  @override
  void initState() {
    super.initState();
    _loadFavoriteDrivers();
  }

  Future<void> _loadFavoriteDrivers() async {
    final list = await FavoritesService.getFavoriteDrivers();
    if (mounted) setState(() => _favoriteDrivers = list);
  }

  double get _totalPrice => widget.price + (_selectedPreferredDriverId.isNotEmpty ? _preferredDriverFee : 0);

  @override
  void dispose() {
    _instructionsController.dispose();
    _delegateNameController.dispose();
    _delegatePhoneController.dispose();
    _arrondissementController.dispose();
    _rueController.dispose();
    _zoneController.dispose();
    _quartierController.dispose();
    _referenceController.dispose();
    _retraitBoutiqueController.dispose();
    super.dispose();
  }

  Future<void> _addDropOffImage() async {
    final canUseCamera = !kIsWeb && defaultTargetPlatform != TargetPlatform.windows;
    final source = await showModalBottomSheet<picker.ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (canUseCamera) ListTile(leading: const Icon(Icons.camera_alt), title: const Text("Prendre une photo"), onTap: () => Navigator.pop(context, picker.ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library), title: const Text("Insérer une image"), onTap: () => Navigator.pop(context, picker.ImageSource.gallery)),
        ]),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final ip = picker.ImagePicker();
      final xFile = await ip.pickImage(source: source);
      if (xFile != null && mounted) setState(() => _dropOffImages.add(xFile.path));
    } catch (_) {}
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    final details = {
      'instructions': _instructionsController.text.trim(),
      'delegate': _delegateSomeone,
      'delegate_name': _delegateNameController.text.trim(),
      'delegate_phone': _delegatePhoneController.text.trim(),
      'arrondissement': _arrondissementController.text.trim(),
      'rue': _rueController.text.trim(),
      'zone': _zoneController.text.trim(),
      'quartier': _quartierController.text.trim(),
      'address_type': _addressType,
      'reference': _referenceController.text.trim(),
      'retrait_boutique': _retraitBoutiqueController.text.trim(),
      'drop_off_images': _dropOffImages,
    };
    final result = await OrderService.createOrder(
      category: widget.category,
      price: _totalPrice,
      pickupAddress: widget.pickup,
      deliveryAddress: widget.delivery,
      orderDetails: details,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message), backgroundColor: result.success ? Colors.green : Colors.red, behavior: SnackBarBehavior.floating));
    if (result.success && result.orderId != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RideInProgressScreen(orderId: result.orderId!, pickup: widget.pickup, delivery: widget.delivery, category: widget.category, price: _totalPrice)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de la commande"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Prix estimé", style: TextStyle(fontWeight: FontWeight.bold)), Text("${_totalPrice.round()} XAF • ~${widget.etaMinutes} min", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]))]),
                    if (_selectedPreferredDriverId.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text("dont +${_preferredDriverFee.round()} XAF (chauffeur favori)", style: TextStyle(fontSize: 12, color: Colors.green[700]))),
                  ],
                ),
              ),
            ),
            if (_favoriteDrivers.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text("Réserver un chauffeur favori ?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPreferredDriverId,
                    hint: const Text("Choisir selon disponibilités"),
                    isExpanded: true,
                    items: [const DropdownMenuItem<String>(value: '', child: Text("Aucun (attribution automatique)")), ..._favoriteDrivers.map((d) => DropdownMenuItem<String>(value: d['id']?.toString() ?? '', child: Text("${d['name'] ?? 'Chauffeur'} (+${_preferredDriverFee.round()} XAF)")))],
                    onChanged: (v) => setState(() => _selectedPreferredDriverId = v ?? ''),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 24),
            const Text("Instructions de livraison", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _instructionsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Où souhaitez-vous être servi ? Indications pour le livreur...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Déléguer quelqu'un pour récupérer"),
              subtitle: const Text("Une autre personne viendra récupérer à ma place"),
              value: _delegateSomeone,
              onChanged: (v) => setState(() => _delegateSomeone = v),
              activeColor: Colors.green[700],
            ),
            if (_delegateSomeone) ...[
              TextField(controller: _delegateNameController, decoration: InputDecoration(labelText: "Nom de la personne", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true)),
              const SizedBox(height: 8),
              TextField(controller: _delegatePhoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: "Téléphone", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true)),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),
            const Text("Adresse détaillée (lieu de dépôt)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _addressType,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true),
              hint: const Text("Type de lieu"),
              items: const [
                DropdownMenuItem(value: 'maison', child: Text("Maison")),
                DropdownMenuItem(value: 'quartier', child: Text("Quartier")),
                DropdownMenuItem(value: 'bidonville', child: Text("Bidonville")),
                DropdownMenuItem(value: 'endroit_recule', child: Text("Endroit reculé")),
                DropdownMenuItem(value: 'zone', child: Text("Zone / District")),
              ],
              onChanged: (v) => setState(() => _addressType = v),
            ),
            const SizedBox(height: 12),
            TextField(controller: _arrondissementController, decoration: InputDecoration(labelText: "Arrondissement", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true)),
            const SizedBox(height: 8),
            TextField(controller: _rueController, decoration: InputDecoration(labelText: "Rue", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true)),
            const SizedBox(height: 8),
            TextField(controller: _zoneController, decoration: InputDecoration(labelText: "Zone / District", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true)),
            const SizedBox(height: 8),
            TextField(controller: _quartierController, decoration: InputDecoration(labelText: "Quartier", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true)),
            const SizedBox(height: 8),
            TextField(controller: _referenceController, decoration: InputDecoration(labelText: "Référence (repère)", hintText: "Ex: près du marché, derrière l'église", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true)),
            const SizedBox(height: 16),
            const Text("Point de retrait congolais en boutique", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            TextField(controller: _retraitBoutiqueController, decoration: InputDecoration(hintText: "Nom et infos du point de retrait (si applicable)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true)),
            const SizedBox(height: 20),
            const Text("Image de l'endroit où déposer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._dropOffImages.asMap().entries.map((e) => Stack(
                  children: [
                    Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)), child: Icon(Icons.image, color: Colors.green[700])),
                    Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => setState(() => _dropOffImages.removeAt(e.key)), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)))),
                  ],
                )),
                GestureDetector(
                  onTap: _addDropOffImage,
                  child: Container(width: 80, height: 80, decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_a_photo, size: 32, color: Colors.grey)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _confirm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _loading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("CONFIRMER LA RÉSERVATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
