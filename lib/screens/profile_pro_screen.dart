import 'package:flutter/material.dart';
import 'report_client_screen.dart';

class ProfileProScreen extends StatefulWidget {
  const ProfileProScreen({super.key});

  @override
  State<ProfileProScreen> createState() => _ProfileProScreenState();
}

class _ProfileProScreenState extends State<ProfileProScreen> {
  final _companyController = TextEditingController();
  final _siretController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    _siretController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil professionnel"), backgroundColor: Colors.green[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Facturation entreprise", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700])),
            const SizedBox(height: 8),
            const Text("Configurez vos informations professionnelles pour la facturation."),
            const SizedBox(height: 24),
            TextField(
              controller: _companyController,
              decoration: InputDecoration(
                labelText: "Nom de l'entreprise",
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _siretController,
              decoration: InputDecoration(
                labelText: "N° SIRET / RC",
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: "Adresse de facturation",
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text("Section professionnel", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text("Signaler un client"),
              subtitle: const Text("Comportement déplacé avec preuve (vidéo, audio, image)"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportClientScreen())),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_companyController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez remplir le nom de l'entreprise"), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil professionnel enregistré"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Enregistrer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
