import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import '../models/driver_model.dart';
import '../services/demo_data_service.dart';
import '../widgets/avatar_widget.dart';
import 'driver_profile_screen.dart';

/// Liste des chauffeurs/livreurs proches + carte des emplacements
class DriversNearbyScreen extends StatefulWidget {
  const DriversNearbyScreen({super.key});

  @override
  State<DriversNearbyScreen> createState() => _DriversNearbyScreenState();
}

class _DriversNearbyScreenState extends State<DriversNearbyScreen> {
  List<DriverModel> _list = [];
  bool _loading = true;
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await DemoDataService.getDriversNearby();
    if (mounted) setState(() {
      _list = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chauffeurs & livreurs"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _showMap
              ? _buildMap()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text("Meilleurs notés (les mieux notés et avis positifs en premier)", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ),
                      ..._list.map((d) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: AvatarWidget(photoPath: d.photoPath, gender: d.gender, radius: 28),
                          title: Row(
                            children: [
                              Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (d.hasYadeliBadge) ...[const SizedBox(width: 6), Icon(Icons.verified, size: 18, color: Colors.green[700])],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${d.vehicleLabel} • ${d.licensePlate} • ${d.rating.toStringAsFixed(1)} ★ • ${d.positiveReviewsCount} avis", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              Text("${(d.distanceKm ?? 0).toStringAsFixed(1)} km • ${d.address ?? ''}", style: TextStyle(fontSize: 12, color: Colors.green[700])),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriverProfileScreen(driver: d))),
                        ),
                      )),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMap() {
    return fm.FlutterMap(
      options: fm.MapOptions(
        initialCenter: const LatLng(-4.2634, 15.2832),
        initialZoom: 14,
        interactionOptions: const fm.InteractionOptions(flags: fm.InteractiveFlag.all),
      ),
      children: [
        fm.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.yadeli.app',
        ),
        fm.MarkerLayer(
          markers: _list.map((d) => fm.Marker(
            point: LatLng(d.lat, d.lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriverProfileScreen(driver: d))),
              child: Container(
                decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }
}
