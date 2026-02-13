import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'search_screen.dart';

/// Modifier ou annuler une course
class ModifyOrderScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const ModifyOrderScreen({super.key, required this.order});

  @override
  State<ModifyOrderScreen> createState() => _ModifyOrderScreenState();
}

class _ModifyOrderScreenState extends State<ModifyOrderScreen> {
  String? _pickup;
  String? _delivery;
  bool _cancelling = false;

  bool get _canModify {
    final s = widget.order['status'];
    return s == OrderService.statusSearching || s == OrderService.statusAssigned;
  }

  @override
  void initState() {
    super.initState();
    _pickup = widget.order['pickup'];
    _delivery = widget.order['delivery'];
  }

  Future<void> _pickAddress(bool isPickup) async {
    final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => SearchScreen(mode: isPickup ? SearchMode.pickup : SearchMode.destination)));
    if (result != null && mounted) setState(() => isPickup ? _pickup = result : _delivery = result);
  }

  Future<void> _saveModifications() async {
    final id = widget.order['id'].toString();
    final ok = await OrderService.modifyOrder(id, pickup: _pickup, delivery: _delivery);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? "Modifications enregistrées" : "Impossible de modifier"),
      backgroundColor: ok ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
    if (ok) Navigator.pop(context, true);
  }

  bool get _canCancel {
    final s = widget.order['status'];
    final confirmedByEst = widget.order['confirmed_by_establishment'] == true;
    final confirmedByDriver = widget.order['confirmed_by_driver'] == true;
    if (s == OrderService.statusInProgress || s == OrderService.statusEnRoute || s == OrderService.statusArrived) return false;
    if (confirmedByEst || confirmedByDriver) return false;
    return true;
  }

  Future<void> _cancelOrder() async {
    if (!_canCancel) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Impossible d'annuler : course en cours ou commande confirmée par l'établissement/livreur. Signalez un problème si nécessaire."),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Annuler la course ?"),
        content: const Text(
          "Si vous annulez sans motif valable (commande par erreur), des frais d'annulation peuvent être facturés.\n\n"
          "En cas de problème, signalez-le d'abord avant d'annuler.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Non")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Oui, annuler", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _cancelling = true);
    final ok = await OrderService.cancelOrder(widget.order['id'].toString());
    if (!mounted) return;
    setState(() => _cancelling = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? "Course annulée" : "Erreur"),
      backgroundColor: ok ? Colors.orange : Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier / Annuler"), backgroundColor: Colors.green[700]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!_canModify)
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [Icon(Icons.info, color: Colors.orange[800]), const SizedBox(width: 12), Expanded(child: Text("La course ne peut plus être modifiée (déjà en cours ou terminée).", style: TextStyle(color: Colors.orange[900])))]),
              ),
            )
          else ...[
            const Text("Modifier l'adresse de départ", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              title: Text(_pickup ?? "Départ"),
              trailing: const Icon(Icons.edit),
              onTap: () => _pickAddress(true),
            ),
            const SizedBox(height: 16),
            const Text("Modifier la destination", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              title: Text(_delivery ?? "Destination"),
              trailing: const Icon(Icons.edit),
              onTap: () => _pickAddress(false),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canModify ? _saveModifications : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text("ENREGISTRER LES MODIFICATIONS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          if (!_canCancel)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(Icons.info, color: Colors.orange[800]),
                const SizedBox(width: 12),
                Expanded(child: Text("Annulation impossible : course en cours ou commande confirmée. Signalez un problème si nécessaire.", style: TextStyle(fontSize: 13, color: Colors.orange[900]))),
              ]),
            ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: (_cancelling || !_canCancel) ? null : _cancelOrder,
              icon: _cancelling ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.cancel),
              label: Text(_cancelling ? "Annulation..." : "Annuler la course"),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
