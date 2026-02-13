import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'help_request_screen.dart';
import 'contestation_screen.dart';
import 'ai_chat_support_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launch(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Support"), backgroundColor: Colors.green[700]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: const Text("Appel d'urgence"),
            subtitle: const Text("+242 06 444 22 11"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _launch('tel:+242064442211');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ouverture de l'appel..."), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
            },
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy, color: Colors.green),
            title: const Text("Assistance IA (chat)"),
            subtitle: const Text("Réponses instantanées, renvoi vers agent si besoin"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatSupportScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.green),
            title: const Text("Chat agent"),
            subtitle: const Text("Assistance Lun-Ven 8h-18h • support@yadeli.cg"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Chat Support"),
                  content: const Text("Assistance disponible : Lun-Ven 8h-18h. Écrivez-nous à support@yadeli.cg"),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.green),
            title: const Text("Demander de l'aide"),
            subtitle: const Text("Oubli, vol, mauvais chauffeur, refuser livraison"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpRequestScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.gavel, color: Colors.green),
            title: const Text("Contester un avis"),
            subtitle: const Text("Client ou professionnel : droit de contestation"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContestationScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.green),
            title: const Text("FAQ"),
            subtitle: const Text("Questions fréquentes"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("FAQ", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[700])),
                      const SizedBox(height: 16),
                      _buildFaqItem("Comment annuler une course ?", "Allez dans Historique > Trajets > sélectionnez le trajet > Annuler."),
                      _buildFaqItem("Comment payer ?", "Cash, Airtel Money ou MTN MoMo à la livraison."),
                      _buildFaqItem("Comment contacter le support ?", "Appelez le +242 06 444 22 11 ou utilisez le chat."),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(q, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(a, style: TextStyle(color: Colors.grey[700]))]),
    );
  }
}
