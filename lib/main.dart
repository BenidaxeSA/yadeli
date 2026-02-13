import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/app_localizations.dart';
import 'services/profile_service.dart';
import 'services/locale_service.dart';
import 'src/platform_mapbox.dart';
import 'screens/map_order_screen.dart';
import 'screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exception}\n${details.stack}');
  };

  await LocaleService.init();

  await Supabase.initialize(
    url: 'https://bhcgojcoonymapqiwqsz.supabase.co',
    anonKey: 'sb_publishable_QOxzFmgkUoBUEqA4BpAKCg_5xEcCKH3', // ⚠️ Clé publiable (anon) depuis Project Settings > API
  );

  // 2. Configuration de Mapbox (Android/iOS uniquement — pas supporté sur Windows/Web)
  if (isMapboxSupported) {
    MapboxOptions.setAccessToken(
      "sk.eyJ1IjoiYmVuaWRheGUyMDI1IiwiYSI6ImNtamlybml4NzBidWUza3NkZDBhMHBoYmYifQ.67oF63YjNgHP5prKTE0DVA",
    );
  }

  runApp(const MyApp());
}

// Provider pour accéder au ProfileService depuis n'importe où
final profileService = ProfileService();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService.instance,
      builder: (_, __) {
        final loc = LocaleService.instance.flutterLocale;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Yadeli',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          locale: (loc.languageCode == 'ln' || loc.languageCode == 'kg') ? const Locale('fr') : loc,
          supportedLocales: const [
            Locale('fr'),
            Locale('en'),
            Locale('ln'),
            Locale('kg'),
          ],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AuthRedirect(),
        );
      },
    );
  }
}

// 🔹 CE WIDGET DÉCIDE QUELLE PAGE AFFICHER AU DÉMARRAGE
/// Écoute les changements d'auth (connexion, déconnexion, OAuth Google)
class AuthRedirect extends StatelessWidget {
  const AuthRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      initialData: AuthState(AuthChangeEvent.initialSession, Supabase.instance.client.auth.currentSession),
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          return const MapOrderScreen();
        }
        return const AuthScreen();
      },
    );
  }
}