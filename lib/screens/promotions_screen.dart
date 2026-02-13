import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Promotions"), backgroundColor: Colors.green[700]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PromoCard(code: "YADELI10", discount: "10%", desc: "Première course"),
          _PromoCard(code: "MOTO50", discount: "500 XAF", desc: "Sur Moto Express"),
          _PromoCard(code: "BRAZA20", discount: "20%", desc: "Brazzaville centre"),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String code;
  final String discount;
  final String desc;

  const _PromoCard({required this.code, required this.discount, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: code));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Code $code copié !"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text(discount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(code, style: const TextStyle(fontWeight: FontWeight.bold)), Text(desc, style: TextStyle(color: Colors.grey[600]))])),
            Icon(Icons.copy, color: Colors.green[700], size: 20),
          ]),
        ),
      ),
    );
  }
}
