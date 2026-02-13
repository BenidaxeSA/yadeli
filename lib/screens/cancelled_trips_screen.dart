import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'trip_detail_screen.dart';

/// Liste des trajets annulés
class CancelledTripsScreen extends StatelessWidget {
  const CancelledTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trajets annulés"),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: OrderService.getCancelledOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Aucun trajet annulé", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }
          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final o = orders[i];
              final date = DateTime.tryParse(o['date'] ?? '') ?? DateTime.now();
              final cancelledAt = o['cancelled_at'] != null ? DateTime.tryParse(o['cancelled_at']) : null;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.red[50],
                child: ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: Text(o['category'] ?? 'Course'),
                  subtitle: Text('${o['pickup'] ?? ''} → ${o['delivery'] ?? ''}\nAnnulé le ${cancelledAt != null ? "${cancelledAt.day}/${cancelledAt.month}/${cancelledAt.year}" : date.toString().substring(0, 10)}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(order: o))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
