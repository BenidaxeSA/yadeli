import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres"), backgroundColor: Colors.green[700]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListenableBuilder(
            listenable: LocaleService.instance,
            builder: (_, __) => ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Langue"),
              subtitle: Text(LocaleService.instance.locale.label),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final result = await showDialog<AppLocale>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Choisir la langue"),
                    content: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        ListTile(title: const Text("Français"), onTap: () => Navigator.pop(context, AppLocale.fr)),
                        ListTile(title: const Text("English"), onTap: () => Navigator.pop(context, AppLocale.en)),
                        ListTile(title: const Text("Lingala"), onTap: () => Navigator.pop(context, AppLocale.ln)),
                        ListTile(title: const Text("Kituba"), onTap: () => Navigator.pop(context, AppLocale.kg)),
                      ]),
                    ),
                  ),
                );
                if (result != null && mounted) {
                  await LocaleService.instance.setLocale(result);
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Langue : ${result.label}"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
              activeColor: Colors.green[700],
            ),
            onTap: () => setState(() => _notificationsEnabled = !_notificationsEnabled),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text("Confidentialité"),
            subtitle: const Text("Gérer vos données et confidentialité"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Confidentialité"),
                  content: const SingleChildScrollView(
                    child: Text(
                      "• Vos données personnelles sont protégées.\n• Nous ne partageons pas vos informations avec des tiers.\n• Vous pouvez supprimer votre compte à tout moment.",
                    ),
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
