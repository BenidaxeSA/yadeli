import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/map_order_screen.dart';
import 'screens/auth_screen.dart'; // 👈 On importe ton nouvel écran

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialisation de Supabase
  await Supabase.initialize(
    url: 'https://ycdksonqiybrchpfmxzv.supabase.co',
    anonKey: 'sb_secret_M7rfiHB9Cq2eR2vTS45anQ__toNK7qL', // ⚠️ N'oublie pas de coller ta clé ici
  );

  // 2. Configuration de Mapbox
  MapboxOptions.setAccessToken(
    "sk.eyJ1IjoiYmVuaWRheGUyMDI1IiwiYSI6ImNtamlybml4NzBidWUza3NkZDBhMHBoYmYifQ.67oF63YjNgHP5prKTE0DVA",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yadeli', // 👈 On change le nom ici aussi
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), // Style Yadeli
        useMaterial3: true,
      ),
      // 3. On utilise un widget de redirection
      home: const AuthRedirect(),
    );
  }
}

// 🔹 CE WIDGET DÉCIDE QUELLE PAGE AFFICHER AU DÉMARRAGE
class AuthRedirect extends StatelessWidget {
  const AuthRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    // On récupère la session actuelle de Supabase
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // Si connecté -> Carte
      return const MapOrderScreen();
    } else {
      // Si non connecté -> Login Yadeli
      return const AuthScreen();
    }
  }
}