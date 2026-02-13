import 'package:flutter/material.dart';
import '../services/address_service.dart';
import 'search_screen.dart';

/// Gestion des adresses favorites — Uber, Citymapper
/// Maison, Travail
class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  String? _home;
  String? _work;
  String? _school;
  String? _hospital;
  String? _pharmacy;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await AddressService.getAll();
    if (mounted) setState(() {
      _home = m['home'];
      _work = m['work'];
      _school = m['school'];
      _hospital = m['hospital'];
      _pharmacy = m['pharmacy'];
    });
  }

  Future<void> _pickAddress(String type) async {
    final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
    if (result != null && mounted) {
      switch (type) {
        case 'home': await AddressService.setHome(result); setState(() => _home = result); break;
        case 'work': await AddressService.setWork(result); setState(() => _work = result); break;
        case 'school': await AddressService.setSchool(result); setState(() => _school = result); break;
        case 'hospital': await AddressService.setHospital(result); setState(() => _hospital = result); break;
        case 'pharmacy': await AddressService.setPharmacy(result); setState(() => _pharmacy = result); break;
      }
    }
  }

  Future<void> _clearAddress(String type) async {
    switch (type) {
      case 'home': await AddressService.setHome(''); setState(() => _home = null); break;
      case 'work': await AddressService.setWork(''); setState(() => _work = null); break;
      case 'school': await AddressService.setSchool(''); setState(() => _school = null); break;
      case 'hospital': await AddressService.setHospital(''); setState(() => _hospital = null); break;
      case 'pharmacy': await AddressService.setPharmacy(''); setState(() => _pharmacy = null); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adresses favorites"),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildAddressCard(
            icon: Icons.home,
            label: "Maison",
            address: _home,
            color: Colors.green,
            onTap: () => _pickAddress('home'),
            onClear: _home != null ? () => _clearAddress('home') : null,
          ),
          const SizedBox(height: 16),
          _buildAddressCard(
            icon: Icons.work,
            label: "Travail",
            address: _work,
            color: Colors.blue,
            onTap: () => _pickAddress('work'),
            onClear: _work != null ? () => _clearAddress('work') : null,
          ),
          const SizedBox(height: 16),
          _buildAddressCard(
            icon: Icons.school,
            label: "École / Centre de formation (université, atelier...)",
            address: _school,
            color: Colors.purple,
            onTap: () => _pickAddress('school'),
            onClear: _school != null ? () => _clearAddress('school') : null,
          ),
          const SizedBox(height: 16),
          _buildAddressCard(
            icon: Icons.local_hospital,
            label: "Hôpital",
            address: _hospital,
            color: Colors.red,
            onTap: () => _pickAddress('hospital'),
            onClear: _hospital != null ? () => _clearAddress('hospital') : null,
          ),
          const SizedBox(height: 16),
          _buildAddressCard(
            icon: Icons.local_pharmacy,
            label: "Pharmacie",
            address: _pharmacy,
            color: Colors.orange,
            onTap: () => _pickAddress('pharmacy'),
            onClear: _pharmacy != null ? () => _clearAddress('pharmacy') : null,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Ces adresses apparaîtront dans la recherche pour un accès rapide.", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard({
    required IconData icon,
    required String label,
    required String? address,
    required Color color,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 28)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(address ?? "Ajouter une adresse", style: TextStyle(color: address != null ? Colors.black87 : Colors.grey)),
        trailing: address != null && onClear != null
            ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: onClear)
            : const Icon(Icons.add, color: Colors.green),
      ),
    );
  }
}
