import 'package:flutter/material.dart';
import '../services/order_service.dart';

/// Écran listant tous les services disponibles
class AllServicesScreen extends StatelessWidget {
  final VoidCallback onOrderPlaced;

  const AllServicesScreen({super.key, required this.onOrderPlaced});

  @override
  Widget build(BuildContext context) {
    const services = [
      _ServiceItem(icon: Icons.motorcycle, color: Colors.green, title: "Moto Express", subtitle: "Arrivée 3 min • Rapide", price: 1500, category: "Moto"),
      _ServiceItem(icon: Icons.directions_car, color: Colors.blue, title: "Yadeli Auto", subtitle: "Confort • Climatisé", price: 2500, category: "Auto"),
      _ServiceItem(icon: Icons.local_pharmacy, color: Colors.red, title: "Pharmacie", subtitle: "Livraison de médicaments", price: 3000, category: "Pharmacie"),
      _ServiceItem(icon: Icons.restaurant, color: Colors.amber, title: "Alimentaire", subtitle: "Restaurants, snacks, plats", price: 2500, category: "Alimentaire"),
      _ServiceItem(icon: Icons.store, color: Colors.purple, title: "Boutique", subtitle: "Produits de boutiques", price: 2000, category: "Boutique"),
      _ServiceItem(icon: Icons.face, color: Colors.pink, title: "Cosmétique", subtitle: "Produits de beauté", price: 2200, category: "Cosmétique"),
      _ServiceItem(icon: Icons.shopping_basket, color: Colors.teal, title: "Marché", subtitle: "Marchés publics et locaux", price: 1800, category: "Marché"),
      _ServiceItem(icon: Icons.inventory_2, color: Colors.orange, title: "Livraison Colis", subtitle: "Colis sécurisé avec preuve", price: 2000, category: "Livraison"),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Tous les services"), backgroundColor: Colors.green[700]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, i) {
          final s = services[i];
          return _ServiceCard(
            icon: s.icon,
            color: s.color,
            title: s.title,
            subtitle: s.subtitle,
            price: s.price,
            onTap: () => _confirmOrder(context, s.category, s.price.toDouble(), onOrderPlaced),
          );
        },
      ),
    );
  }

  static Future<void> _confirmOrder(BuildContext context, String category, double price, VoidCallback onOrderPlaced) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Traitement..."), duration: Duration(seconds: 1)));
    final result = await OrderService.createOrder(category: category, price: price);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.message),
      backgroundColor: result.success ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
    if (result.success) onOrderPlaced();
  }
}

class _ServiceItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final int price;
  final String category;

  const _ServiceItem({required this.icon, required this.color, required this.title, required this.subtitle, required this.price, required this.category});
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final int price;
  final VoidCallback onTap;

  const _ServiceCard({required this.icon, required this.color, required this.title, required this.subtitle, required this.price, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 32)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        subtitle: Text(subtitle),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text("$price XAF", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Text("Cash", style: TextStyle(fontSize: 12, color: Colors.grey))]),
      ),
    );
  }
}
