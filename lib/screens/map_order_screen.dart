import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart'; // 👈 INDISPENSABLE POUR LA REDIRECTION

class MapOrderScreen extends StatefulWidget {
  const MapOrderScreen({super.key});

  @override
  State<MapOrderScreen> createState() => _MapOrderScreenState();
}

class _MapOrderScreenState extends State<MapOrderScreen> {
  MapboxMap? mapboxMap;
  int _currentIndex = 0; 
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Fonction utilitaire pour la déconnexion (réutilisable)
  void _logout() {
    // 1. On ferme le tiroir si ouvert
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
    
    // 2. On renvoie vers l'écran de connexion en vidant l'historique
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
  }

  Future<void> _confirmOrder(String category, double price) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact du serveur...")),
      );

      await Supabase.instance.client.functions.invoke(
        'create-order',
        body: {
          'client_id': Supabase.instance.client.auth.currentUser?.id,
          'category': category,
          'total_price': price,
          'pickup_data': {'address': 'Ma Campagne'},
          'delivery_data': {'address': 'Poto-Poto'},
        },
      );

      if (mounted) {
        _showSnackBar("Commande réussie ! $price XAF", Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Erreur: $e", Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Trajets'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Compte'),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildMapHomePage(),
          const Center(child: Text("Historique des trajets bientôt disponible")),
          AccountScreen(onLogout: _logout), // 👈 On passe la fonction de déconnexion
        ],
      ),
    );
  }

  Widget _buildMapHomePage() {
    return Stack(
      children: [
        MapWidget(
          key: const ValueKey("mapWidget"),
          styleUri: MapboxStyles.MAPBOX_STREETS,
          cameraOptions: CameraOptions(
            center: Point(coordinates: Position(15.2832, -4.2634)), 
            zoom: 14.0,
          ),
          onMapCreated: (map) {
            mapboxMap = map;
            map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
            map.logo.updateSettings(LogoSettings(enabled: false));
            map.attribution.updateSettings(AttributionSettings(enabled: false));
          },
        ),

        Positioned(
          top: 50,
          left: 20,
          child: _buildCircularButton(Icons.menu, () {
            _scaffoldKey.currentState?.openDrawer();
          }),
        ),

        Positioned(
          top: 110,
          left: 20,
          right: 20,
          child: _buildSearchBar(),
        ),

        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.40,
          right: 20,
          child: _buildCircularButton(Icons.my_location, () {}, color: Colors.green),
        ),

        _buildDraggableSheet(),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.green[700]),
            accountName: const Text("Utilisateur Yedali", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("+242 06 444 22 11"),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.green)),
          ),
          ListTile(leading: const Icon(Icons.payment), title: const Text("Paiement"), onTap: () {}),
          ListTile(leading: const Icon(Icons.local_offer_outlined), title: const Text("Promotions"), onTap: () {}),
          ListTile(leading: const Icon(Icons.support_agent), title: const Text("Support"), onTap: () {}),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red), 
            title: const Text("Déconnexion", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), 
            onTap: _logout, // 👈 APPEL DE LA FONCTION CORRIGÉ
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- LES AUTRES WIDGETS UI (SEARCHBAR, BUTTONS, SHEET) RESTENT IDENTIQUES ---
  Widget _buildCircularButton(IconData icon, VoidCallback onTap, {Color color = Colors.black}) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)]),
      child: CircleAvatar(backgroundColor: Colors.white, radius: 25, child: IconButton(icon: Icon(icon, color: color), onPressed: onTap)),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 55, padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)]),
      child: Row(children: [const Icon(Icons.search, color: Colors.green), const SizedBox(width: 10), const Expanded(child: Text("Où allons-nous ?", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500))), VerticalDivider(indent: 15, endIndent: 15, color: Colors.grey[300]), const Icon(Icons.access_time, color: Colors.black54)]),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.38, minChildSize: 0.20, maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black12)]),
          child: ListView(
            controller: scrollController, padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const Padding(padding: EdgeInsets.all(20), child: Text("Prêt ? C'est parti !", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
              _buildTransportOption(icon: Icons.motorcycle, color: Colors.green, title: "Moto Express", subtitle: "Arrivée 3 min • Rapide", price: "1.500", onTap: () => _confirmOrder('Moto', 1500)),
              _buildTransportOption(icon: Icons.local_pharmacy, color: Colors.red, title: "Pharmacie", subtitle: "Livraison de médicaments", price: "3.000", onTap: () => _confirmOrder('Pharmacie', 3000)),
              const SizedBox(height: 20),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: () {}, child: const Text("VOIR TOUS LES SERVICES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransportOption({required IconData icon, required Color color, required String title, required String subtitle, required String price, required VoidCallback onTap}) {
    return ListTile(onTap: onTap, leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 30)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), subtitle: Text(subtitle), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text("$price XAF", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Text("Cash", style: TextStyle(fontSize: 12, color: Colors.grey))]));
  }
}

// --- NOUVELLE PAGE COMPTE (CORRIGÉE) ---
class AccountScreen extends StatelessWidget {
  final VoidCallback onLogout; // 👈 Reçoit la fonction de l'écran parent

  const AccountScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(radius: 40, backgroundColor: Colors.black12, child: Icon(Icons.person, size: 50, color: Colors.white)),
                SizedBox(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Yedali", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), Text("+242 06 444 22 11", style: TextStyle(color: Colors.grey))])
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildMenuOption(Icons.payment, "Paiement"),
          _buildMenuOption(Icons.local_offer_outlined, "Promotions"),
          _buildMenuOption(Icons.work_outline, "Profil professionnel"),
          _buildMenuOption(Icons.settings_outlined, "Paramètres"),
          _buildMenuOption(Icons.info_outline, "À propos"),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: onLogout, // 👈 APPEL DE LA FONCTION CORRIGÉ
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String title) {
    return ListTile(leading: Icon(icon, color: Colors.black), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)), trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), onTap: () {});
  }
}