import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/congo_flag.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launch(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("À propos"), backgroundColor: Colors.green[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_taxi, size: 80, color: Colors.green[700]),
                const SizedBox(width: 20),
                CongoFlag(width: 60, height: 40),
              ],
            ),
            const SizedBox(height: 16),
            Text("Yadeli", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green[700])),
            const SizedBox(height: 8),
            Text("Votre trajet, notre priorité", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 24),
            const Text("Plateforme de transport et livraison au Congo.", textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text("Version 1.0.0", style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 32),
            ListTile(
              leading: Icon(Icons.language, color: Colors.green[700]),
              title: const Text("Site web"),
              subtitle: const Text("yadeli.cg"),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launch('https://yadeli.cg'),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.green[700]),
              title: const Text("Nous contacter"),
              subtitle: const Text("+242 06 444 22 11"),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launch('tel:+242064442211'),
            ),
          ],
        ),
      ),
    );
  }
}
