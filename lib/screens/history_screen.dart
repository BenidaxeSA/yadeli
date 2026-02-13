import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'trip_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _filterIndex = 1; // 0 = En cours, 1 = Terminés, 2 = Annulés

  static bool _isCompleted(String? s) =>
      s == 'terminé' || s == OrderService.statusCompleted;

  static bool _isCancelled(String? s) => s == OrderService.statusCancelled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique des trajets"), backgroundColor: Colors.green[700]),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ChoiceChip(label: const Text("En cours"), selected: _filterIndex == 0, onSelected: (v) => setState(() => _filterIndex = 0), selectedColor: Colors.green[200]),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text("Terminés"), selected: _filterIndex == 1, onSelected: (v) => setState(() => _filterIndex = 1), selectedColor: Colors.green[200]),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text("Annulés"), selected: _filterIndex == 2, onSelected: (v) => setState(() => _filterIndex = 2), selectedColor: Colors.orange[200]),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _filterIndex == 2 ? OrderService.getCancelledOrders() : OrderService.getDemoOrders(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucun trajet pour le moment.\nPassez une commande pour voir l'historique.", textAlign: TextAlign.center));
                }
                var orders = snapshot.data!;
                final showCompleted = _filterIndex == 1;
                final showCancelled = _filterIndex == 2;
                if (showCancelled) {
                  orders = snapshot.data!;
                } else {
                  orders = orders.where((o) => _isCompleted(o['status']) == showCompleted).toList();
                }
                if (orders.isEmpty) {
                  return Center(child: Text(showCancelled ? "Aucun trajet annulé" : showCompleted ? "Aucun trajet terminé" : "Aucune course en cours", style: TextStyle(color: Colors.grey[600])));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, i) {
                    final o = orders[i];
                    final date = DateTime.tryParse(o['date'] ?? '') ?? DateTime.now();
                    final status = o['status'] ?? 'terminé';
                final isCancelled = _isCancelled(status);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isCancelled ? Colors.red[50] : null,
                      child: ListTile(
                        leading: Icon(_isDelivery(o['category']) ? Icons.inventory_2 : Icons.local_taxi, color: isCancelled ? Colors.red : Colors.green),
                        title: Text(o['category'] ?? 'Course'),
                        subtitle: Text('${o['pickup'] ?? ''} → ${o['delivery'] ?? ''}\n${o['price']} XAF • ${date.day}/${date.month}/${date.year}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: isCancelled ? Colors.red[200] : _isCompleted(status) ? Colors.green[100] : Colors.orange[100], borderRadius: BorderRadius.circular(8)),
                              child: Text(_statusShort(status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isCancelled ? Colors.red[900] : _isCompleted(status) ? Colors.green[800] : Colors.orange[800])),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(order: o))),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static bool _isDelivery(String? cat) => cat == 'Pharmacie' || cat == 'Livraison' || cat == 'Alimentaire' || cat == 'Boutique' || cat == 'Cosmétique' || cat == 'Marché';

  static String _statusShort(String s) {
    switch (s) {
      case 'searching': return "Recherche";
      case 'assigned': return "Assigné";
      case 'en_route': return "En route";
      case 'arrived': return "Arrivé";
      case 'in_progress': return "En cours";
      case 'terminé': return "Terminé";
      case 'cancelled': return "Annulé";
      default: return s;
    }
  }
}
