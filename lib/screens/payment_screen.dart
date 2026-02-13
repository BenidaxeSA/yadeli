import 'package:flutter/material.dart';
import 'payment_detail_screen.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  static const _methods = [
    _Method(id: 'Airtel', title: 'Airtel Money', subtitle: 'Paiement mobile', icon: Icons.phone_android),
    _Method(id: 'MTN', title: 'MTN MoMo', subtitle: 'Paiement mobile', icon: Icons.phone_android),
    _Method(id: 'Cash', title: 'Espèces (Cash)', subtitle: 'Paiement à la livraison', icon: Icons.payments),
    _Method(id: 'Card', title: 'Carte bancaire', subtitle: 'Visa, Mastercard', icon: Icons.credit_card),
    _Method(id: 'PlayStore', title: 'Google Play', subtitle: 'Paiement in-app Android', icon: Icons.android),
    _Method(id: 'AppleStore', title: 'App Store', subtitle: 'Paiement in-app iOS', icon: Icons.apple),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement"), backgroundColor: Colors.green[700]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _methods.map((m) => _PaymentCard(
          icon: m.icon,
          title: m.title,
          subtitle: m.subtitle,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentDetailScreen(methodId: m.id, methodTitle: m.title, methodIcon: m.icon))),
        )).toList(),
      ),
    );
  }
}

class _Method {
  final String id, title, subtitle;
  final IconData icon;
  const _Method({required this.id, required this.title, required this.subtitle, required this.icon});
}

class _PaymentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
