import 'package:flutter/material.dart';
import '../main.dart';
import '../services/address_service.dart';
import '../services/user_service.dart';
import '../services/order_service.dart';
import '../services/invoice_service.dart';
import '../widgets/avatar_widget.dart';
import 'rating_screen.dart';
import 'driver_profile_screen.dart';
import 'modify_order_screen.dart';
import 'contestation_screen.dart';

class TripDetailScreen extends StatelessWidget {
  static bool _isDelivery(String? cat) => cat == 'Pharmacie' || cat == 'Livraison' || cat == 'Alimentaire' || cat == 'Boutique' || cat == 'Cosmétique' || cat == 'Marché';

  static String _statusLabel(String? s) {
    switch (s) {
      case 'searching': return "Recherche chauffeur";
      case 'assigned': return "Chauffeur assigné";
      case 'en_route': return "En route";
      case 'arrived': return "Arrivé";
      case 'in_progress': return "En cours";
      case 'terminé': return "Terminé";
      case 'cancelled': return "Annulé";
      default: return s ?? 'terminé';
    }
  }
  final Map<String, dynamic> order;

  const TripDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(order['date'] ?? '') ?? DateTime.now();
    final hora = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final dateStr = '${date.day}/${date.month}/${date.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail du trajet"),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_isDelivery(order['category'])) _buildDeliveryTracking(order),
          _buildSection("Informations commande", [
            _buildRow(Icons.category, "Service", order['category'] ?? 'Course'),
            _buildRow(Icons.attach_money, "Prix", "${order['price']} XAF"),
            if ((order['tip'] ?? 0) > 0) _buildRow(Icons.volunteer_activism, "Pourboire", "${order['tip']} XAF"),
            _buildRow(Icons.schedule, "Date", dateStr),
            _buildRow(Icons.access_time, "Heure", hora),
            _buildRow(Icons.flag, "Départ", order['pickup'] ?? '-'),
            _buildRow(Icons.location_on, "Arrivée", order['delivery'] ?? '-'),
            _buildRow(Icons.check_circle, "Statut", _statusLabel(order['status'])),
          ]),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await InvoiceService.sendInvoice(order);
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Récap envoyé par mail/SMS"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                  },
                  icon: const Icon(Icons.email, size: 18),
                  label: const Text("Envoyer récap"),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.green[700]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showInvoiceDialog(context, order),
                  icon: const Icon(Icons.receipt_long, size: 18),
                  label: const Text("Voir facture"),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.green[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (order['driver_name'] != null || order['driver_id'] != null) _buildDriverSection(context, order),
          _buildSection("Client", [
            FutureBuilder<Map<String, dynamic>>(
              future: Future.wait([AddressService.isVerified(), UserService.getUserLanguages()]).then((r) => {'verified': r[0] as bool, 'languages': r[1] as List<String>}),
              builder: (context, snap) => ListenableBuilder(
                listenable: profileService,
                builder: (context, _) => ListTile(
                  leading: AvatarWidget(
                    photoPath: profileService.photoPath,
                    gender: order['client_gender'] ?? 'homme',
                    radius: 28,
                  ),
                  title: Row(
                    children: [
                      Text(order['client_name'] ?? 'Client', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      if (snap.data?['verified'] == true) ...[const SizedBox(width: 6), Icon(Icons.verified, size: 18, color: Colors.green[700])],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order['client_phone'] ?? '+242 06 444 22 11', style: TextStyle(color: Colors.grey[600])),
                      if (snap.data?['languages'] != null && (snap.data!['languages'] as List).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text("Langues : ${(snap.data!['languages'] as List).join(', ')}", style: TextStyle(fontSize: 12, color: Colors.green[700])),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
          if ((order['status'] == 'terminé' || order['status'] == OrderService.statusCompleted))
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (order['rating'] == null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RatingScreen(orderId: order['id'].toString(), category: order['category'] ?? 'Course', driverName: order['driver_name'], establishmentName: _isDelivery(order['category']) ? 'Établissement' : null))),
                        icon: const Icon(Icons.star),
                        label: const Text("Noter"),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.green[700]),
                      ),
                    ),
                  if (order['rating'] != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContestationScreen(orderId: order['id'].toString()))),
                        icon: const Icon(Icons.gavel, size: 18),
                        label: const Text("Contester l'avis"),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (order['status'] != OrderService.statusCancelled)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final v = await Navigator.push(context, MaterialPageRoute(builder: (_) => ModifyOrderScreen(order: order)));
                        if (v == true && context.mounted) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("Modifier"),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDriverSection(BuildContext context, Map<String, dynamic> order) {
    final name = order['driver_name'] ?? 'Chauffeur';
    final phone = order['driver_phone'];
    final rating = order['driver_rating'];
    final driverId = order['driver_id'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: _buildSection("Chauffeur / Livreur", [
        ListTile(
          leading: CircleAvatar(radius: 24, backgroundColor: Colors.green[100], child: Text(name.substring(0, 1).toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]))),
          title: Row(
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (rating != null) ...[const SizedBox(width: 8), Icon(Icons.star, size: 16, color: Colors.amber[700]), Text(" ${rating.toStringAsFixed(1)}")],
            ],
          ),
          subtitle: phone != null ? Text(phone) : null,
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriverProfileScreen(driverId: driverId ?? 'd1'))),
        ),
      ]),
    );
  }

  Widget _buildDeliveryTracking(Map<String, dynamic> order) {
    const steps = ['Préparé', 'Pris en charge', 'En route', 'Livré'];
    final status = order['status'] ?? 'terminé';
    int completedCount = 0;
    if (status == 'searching' || status == 'assigned') completedCount = 1;
    else if (status == 'en_route') completedCount = 2;
    else if (status == 'arrived' || status == 'in_progress') completedCount = 3;
    else completedCount = 4;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Suivi de livraison", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700])),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(steps.length * 2 - 1, (i) {
                  if (i.isOdd) {
                    final stepIdx = i ~/ 2;
                    return Padding(padding: const EdgeInsets.only(left: 12), child: Container(width: 2, height: 20, color: completedCount > stepIdx ? Colors.green : Colors.grey[300]));
                  }
                  final stepIdx = i ~/ 2;
                  final done = completedCount > stepIdx;
                  return Row(
                    children: [
                      Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? Colors.green : Colors.grey, size: 24),
                      const SizedBox(width: 12),
                      Text(steps[stepIdx], style: TextStyle(fontWeight: done ? FontWeight.bold : FontWeight.normal, color: done ? Colors.green[800] : Colors.grey[700])),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700])),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  static void _showInvoiceDialog(BuildContext context, Map<String, dynamic> order) {
    final text = InvoiceService.buildInvoiceText(order);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Facture / Récapitulatif"),
        content: SingleChildScrollView(child: SelectableText(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await InvoiceService.sendInvoice(order);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Récap envoyé par mail/SMS"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
            },
            child: const Text("Envoyer"),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 22),
          const SizedBox(width: 12),
          Text("$label : ", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
