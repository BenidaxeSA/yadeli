import 'package:flutter/material.dart';

/// Demander une contestation d'un avis (client ou chauffeur/livreur)
class ContestationScreen extends StatefulWidget {
  final String? orderId;
  final String? targetType; // client, driver

  const ContestationScreen({super.key, this.orderId, this.targetType});

  @override
  State<ContestationScreen> createState() => _ContestationScreenState();
}

class _ContestationScreenState extends State<ContestationScreen> {
  final _reasonController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Expliquez les raisons de votre contestation"), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Contestation envoyée. L'équipe Yadeli examinera sous 48h."), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contester un avis"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Vous avez le droit de contester un avis porté sur vous (client ou professionnel). Expliquez pourquoi vous contestez.", style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: _reasonController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Décrivez les raisons de votre contestation...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _submitting ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("ENVOYER LA CONTESTATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
