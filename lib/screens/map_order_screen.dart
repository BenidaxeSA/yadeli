import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:image_picker/image_picker.dart' as picker;
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../main.dart';
import '../services/order_service.dart';
import '../services/address_service.dart';
import '../services/location_service.dart';
import '../services/user_service.dart';
import '../src/platform_mapbox.dart';
import '../widgets/avatar_widget.dart';
import 'all_services_screen.dart';
import 'booking_flow_screen.dart';
import 'payment_screen.dart';
import 'promotions_screen.dart';
import 'support_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'profile_pro_screen.dart';
import 'edit_profile_screen.dart';
import 'history_screen.dart';
import 'saved_addresses_screen.dart';
import 'establishments_list_screen.dart';
import 'drivers_nearby_screen.dart';
import 'cancelled_trips_screen.dart';
import 'cart_screen.dart';
import 'client_space_screen.dart';

class MapOrderScreen extends StatefulWidget {
  const MapOrderScreen({super.key});

  @override
  State<MapOrderScreen> createState() => _MapOrderScreenState();
}

class _MapOrderScreenState extends State<MapOrderScreen> {
  MapboxMap? mapboxMap;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncUserFromSupabase();
    _sheetController.addListener(() {
      final s = _sheetController.size;
      if (s != null && (s > 0.5) != _sheetExpanded && mounted) setState(() => _sheetExpanded = s > 0.5);
    });
  }

  Future<void> _syncUserFromSupabase() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;
    final user = session.user;
    final email = user.email;
    if (email == null) return;
    final existing = await UserService.getUserEmail();
    if (existing == email) return;
    final name = user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? email.split('@').first;
    await UserService.saveUser(name: name, phone: '+242 06 444 22 11', gender: 'homme', email: email, languages: ['FR']);
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _locationMessage;
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  final fm.MapController _mapController = fm.MapController();
  bool _sheetExpanded = false;

  // Fonction utilitaire pour la déconnexion (réutilisable)
  Future<void> _logout() async {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
    await Supabase.instance.client.auth.signOut();
    // Le StreamBuilder dans AuthRedirect affichera AuthScreen automatiquement
  }

  Future<void> _confirmOrder(String category, double price) async {
    if (!mounted) return;
    _showSnackBar("Traitement...", Colors.blue);

    final result = await OrderService.createOrder(category: category, price: price);

    if (!mounted) return;
    _showSnackBar(result.message, result.success ? Colors.green : Colors.red);
    if (result.success) setState(() {}); // Rafraîchit l'historique
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  void _openDrawerScreen(Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _pickProfilePhoto() async {
    final canUseCamera = !kIsWeb && defaultTargetPlatform != TargetPlatform.windows;
    final source = await showModalBottomSheet<picker.ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (canUseCamera) ListTile(leading: const Icon(Icons.camera_alt), title: const Text("Prendre une photo"), onTap: () => Navigator.pop(context, picker.ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library), title: const Text("Choisir une photo"), onTap: () => Navigator.pop(context, picker.ImageSource.gallery)),
        ]),
      ),
    );
    if (source == null || !mounted) return;
    final useCamera = source == picker.ImageSource.camera && !kIsWeb && defaultTargetPlatform != TargetPlatform.windows;
    try {
      final ip = picker.ImagePicker();
      final xFile = await ip.pickImage(source: useCamera ? picker.ImageSource.camera : picker.ImageSource.gallery);
      if (xFile != null) {
        await profileService.savePhotoFromPath(xFile.path);
        if (mounted) _showSnackBar("Photo de profil mise à jour", Colors.green);
      }
    } catch (e) {
      if (mounted) _showSnackBar("Erreur: ${e.toString().split('\n').first}", Colors.red);
    }
  }

  Future<void> _onLocationTap() async {
    _showSnackBar("Recherche de position...", Colors.blue);
    final result = await LocationService.getCurrentLocation();
    if (!mounted) return;
    if (result.success) {
      setState(() => _locationMessage = result.message);
      _showSnackBar(result.message, Colors.green);
    } else {
      _showSnackBar(result.message, Colors.orange);
    }
  }

  void _toggleSheet() {
    if (_sheetExpanded) {
      _sheetController.animateTo(0.20, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() => _sheetExpanded = false);
    } else {
      _sheetController.animateTo(0.75, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() => _sheetExpanded = true);
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
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
          const HistoryScreen(),
          AccountScreen(onLogout: _logout),
        ],
      ),
    );
  }

  Widget _buildMapHomePage() {
    return Stack(
      children: [
        // Mapbox uniquement sur Android/iOS — placeholder sur Windows/Web
        if (isMapboxSupported)
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
          )
        else
          Stack(
            children: [
              fm.FlutterMap(
                mapController: _mapController,
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
                ],
              ),
              if (_locationMessage != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.95), borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.location_on, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_locationMessage!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500), textAlign: TextAlign.center)),
                    ]),
                  ),
                ),
            ],
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
          child: _buildCircularButton(Icons.my_location, _onLocationTap, color: Colors.green),
        ),

        _buildDraggableSheet(),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _DrawerHeaderContent(onPickPhoto: _pickProfilePhoto),
          ListTile(leading: const Icon(Icons.payment), title: const Text("Paiement"), onTap: () => _openDrawerScreen(const PaymentScreen())),
          ListTile(leading: const Icon(Icons.shopping_cart), title: const Text("Mon panier"), onTap: () => _openDrawerScreen(CartScreen(onOrderPlaced: () => setState(() {})))),
          ListTile(leading: const Icon(Icons.person_pin_circle), title: const Text("Espace client"), subtitle: const Text("Factures, historique, favoris"), onTap: () => _openDrawerScreen(const ClientSpaceScreen())),
          ListTile(leading: const Icon(Icons.home_work), title: const Text("Adresses favorites"), onTap: () => _openDrawerScreen(const SavedAddressesScreen())),
          ListTile(leading: const Icon(Icons.store), title: const Text("Établissements proches"), onTap: () => _openDrawerScreen(const EstablishmentsListScreen())),
          ListTile(leading: const Icon(Icons.local_taxi), title: const Text("Chauffeurs proches"), onTap: () => _openDrawerScreen(const DriversNearbyScreen())),
          ListTile(leading: const Icon(Icons.cancel), title: const Text("Trajets annulés"), onTap: () => _openDrawerScreen(const CancelledTripsScreen())),
          ListTile(leading: const Icon(Icons.local_offer_outlined), title: const Text("Promotions"), onTap: () => _openDrawerScreen(const PromotionsScreen())),
          ListTile(leading: const Icon(Icons.support_agent), title: const Text("Support"), onTap: () => _openDrawerScreen(const SupportScreen())),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: _logout,
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
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingFlowScreen())),
      child: Container(
        height: 55, padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)]),
        child: Row(children: [const Icon(Icons.search, color: Colors.green), const SizedBox(width: 10), const Expanded(child: Text("Où allons-nous ?", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500))), VerticalDivider(indent: 15, endIndent: 15, color: Colors.grey[300]), const Icon(Icons.access_time, color: Colors.black54)]),
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.38,
      minChildSize: 0.20,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black12)]),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              GestureDetector(
                onTap: _toggleSheet,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Icon(_sheetExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 36, color: Colors.green[700]),
                      const SizedBox(height: 4),
                      Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                    ],
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.all(20), child: Text("Prêt ? C'est parti !", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
              _buildTransportOption(icon: Icons.motorcycle, color: Colors.green, title: "Moto Express", subtitle: "Arrivée 3 min • Rapide", price: "1.500", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingFlowScreen(initialCategory: 'Moto')))),
              _buildTransportOption(icon: Icons.local_pharmacy, color: Colors.red, title: "Pharmacie", subtitle: "Livraison de médicaments", price: "3.000", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingFlowScreen(initialCategory: 'Pharmacie')))),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AllServicesScreen(onOrderPlaced: () => setState(() {})))),
                  child: const Text("VOIR TOUS LES SERVICES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
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

class _DrawerHeaderContent extends StatelessWidget {
  final VoidCallback onPickPhoto;

  const _DrawerHeaderContent({required this.onPickPhoto});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: Future.wait([UserService.getUserName(), UserService.getUserPhone(), UserService.getUserGender()]).then((l) => {'name': l[0], 'phone': l[1], 'gender': l[2]}),
      builder: (context, snap) {
        final name = snap.data?['name'] ?? 'Utilisateur Yadeli';
        final phone = snap.data?['phone'] ?? '+242 06 444 22 11';
        final gender = snap.data?['gender'] ?? 'homme';
        return FutureBuilder<bool>(
          future: AddressService.isVerified(),
          builder: (_, snap) => ListenableBuilder(
            listenable: profileService,
            builder: (_, __) => UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              accountName: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (snap.data == true) ...[const SizedBox(width: 6), Icon(Icons.verified, size: 18, color: Colors.white70)],
                ],
              ),
              accountEmail: Text(phone),
              currentAccountPicture: AvatarWidget(photoPath: profileService.photoPath, gender: gender, radius: 35, onTap: onPickPhoto),
            ),
          ),
        );
      },
    );
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
          FutureBuilder<Map<String, String>>(
            future: Future.wait([UserService.getUserName(), UserService.getUserPhone(), UserService.getUserGender()]).then((l) => {'name': l[0], 'phone': l[1], 'gender': l[2]}),
            builder: (context, snap) {
              final name = snap.data?['name'] ?? 'Yadeli';
              final phone = snap.data?['phone'] ?? '+242 06 444 22 11';
              final gender = snap.data?['gender'] ?? 'homme';
              return ListenableBuilder(
                listenable: profileService,
                builder: (context, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          AvatarWidget(photoPath: profileService.photoPath, gender: gender, radius: 40, onTap: () => _pickProfilePhoto(context)),
                          Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, size: 16, color: Colors.white))),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), Text(phone, style: TextStyle(color: Colors.grey))]),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          _buildMenuOption(context, Icons.edit, "Modifier le profil"),
          _buildMenuOption(context, Icons.person_pin_circle, "Espace client"),
          _buildMenuOption(context, Icons.payment, "Paiement"),
          _buildMenuOption(context, Icons.local_offer_outlined, "Promotions"),
          _buildMenuOption(context, Icons.home_work, "Adresses favorites"),
          _buildMenuOption(context, Icons.store, "Établissements proches"),
          _buildMenuOption(context, Icons.local_taxi, "Chauffeurs proches"),
          _buildMenuOption(context, Icons.cancel, "Trajets annulés"),
          _buildMenuOption(context, Icons.work_outline, "Profil professionnel"),
          _buildMenuOption(context, Icons.settings_outlined, "Paramètres"),
          _buildMenuOption(context, Icons.info_outline, "À propos"),
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

  Future<void> _pickProfilePhoto(BuildContext context) async {
    final canUseCamera = !kIsWeb && defaultTargetPlatform != TargetPlatform.windows;
    final source = await showModalBottomSheet<picker.ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (canUseCamera) ListTile(leading: const Icon(Icons.camera_alt), title: const Text("Prendre une photo"), onTap: () => Navigator.pop(context, picker.ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library), title: const Text("Choisir une photo"), onTap: () => Navigator.pop(context, picker.ImageSource.gallery)),
        ]),
      ),
    );
    if (source == null || !context.mounted) return;
    try {
      final ip = picker.ImagePicker();
      final xFile = await ip.pickImage(source: source);
      if (xFile != null) {
        await profileService.savePhotoFromPath(xFile.path);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Photo de profil mise à jour"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString().split('\n').first}"), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
    }
  }

  Widget _buildMenuOption(BuildContext context, IconData icon, String title) {
    Widget? screen;
    if (title == "Modifier le profil") screen = const EditProfileScreen();
    if (title == "Espace client") screen = const ClientSpaceScreen();
    if (title == "Paiement") screen = const PaymentScreen();
    if (title == "Promotions") screen = const PromotionsScreen();
    if (title == "Adresses favorites") screen = const SavedAddressesScreen();
    if (title == "Établissements proches") screen = const EstablishmentsListScreen();
    if (title == "Chauffeurs proches") screen = const DriversNearbyScreen();
    if (title == "Trajets annulés") screen = const CancelledTripsScreen();
    if (title == "Profil professionnel") screen = const ProfileProScreen();
    if (title == "Paramètres") screen = const SettingsScreen();
    if (title == "À propos") screen = const AboutScreen();
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () => screen != null ? Navigator.push(context, MaterialPageRoute(builder: (_) => screen!)) : null,
    );
  }
}