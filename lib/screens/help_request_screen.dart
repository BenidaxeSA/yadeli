import 'package:flutter/material.dart';

/// Demander de l'aide : oubli, vol, mauvais chauffeur, refuser livraison
class HelpRequestScreen extends StatefulWidget {
  final String? orderId;

  const HelpRequestScreen({super.key, this.orderId});

  @override
  State<HelpRequestScreen> createState() => _HelpRequestScreenState();
}

class _HelpRequestScreenState extends State<HelpRequestScreen> {
  String? _selectedType;
  final _descriptionController = TextEditingController();
  bool _submitting = false;

  static const _helpTypes = [
    _HelpType('oubli', 'Oubli / Vol partiel ou total', Icons.inventory, 'Produit, colis, affaires personnelles (téléphone, etc.) oubliés ou volés'),
    _HelpType('mauvais_chauffeur', 'Chauffeur/livreur différent du profil', Icons.person_off, 'La personne en réel ne correspond pas au profil (genre, plaque, pas de badge Yadeli)'),
    _HelpType('refuser', 'Refuser la course/livraison', Icons.block, "Droit de refuser pour votre sécurité si l'identité ne correspond pas"),
    _HelpType('autre', 'Autre problème', Icons.help, 'Décrivez votre situation'),
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sélectionnez un type de problème"), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Demande envoyée. L'équipe Yadeli vous contactera."), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demander de l'aide"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Type de problème", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._helpTypes.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: _selectedType == t.id ? Colors.green[50] : null,
              child: ListTile(
                leading: Icon(t.icon, color: Colors.green[700]),
                title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(t.subtitle),
                selected: _selectedType == t.id,
                onTap: () => setState(() => _selectedType = t.id),
              ),
            )),
            const SizedBox(height: 20),
            const Text("Détails (optionnel)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Décrivez la situation...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            if (_selectedType == 'mauvais_chauffeur' || _selectedType == 'refuser') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange[800]),
                    const SizedBox(width: 12),
                    Expanded(child: Text("Vérifiez que la personne, la plaque et le badge Yadeli correspondent au profil avant d'accepter. Vous avez le droit de refuser pour votre sécurité.", style: TextStyle(fontSize: 13, color: Colors.orange[900]))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _submitting ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("ENVOYER LA DEMANDE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpType {
  final String id;
  final String title;
  final IconData icon;
  final String subtitle;
  const _HelpType(this.id, this.title, this.icon, this.subtitle);
}
