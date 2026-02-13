import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'user_service.dart';

/// Publicités et newsletters — envoi mail/SMS + espace client
class NewsletterService {
  static const _key = 'yadeli_newsletters';
  static const _sentKey = 'yadeli_newsletters_sent';

  static Future<List<Map<String, dynamic>>> getNewsletters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      if (list.isEmpty) {
        return _defaultNewsletters();
      }
      return list.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
    } catch (_) {
      return _defaultNewsletters();
    }
  }

  static List<Map<String, dynamic>> _defaultNewsletters() => [
    {'id': 'n1', 'title': 'Bienvenue chez Yadeli', 'content': 'Découvrez nos services de transport et livraison à Brazzaville.', 'date': '2025-01-01', 'type': 'newsletter'},
    {'id': 'n2', 'title': 'Promo -20% sur votre première course', 'content': 'Utilisez le code BIENVENUE20 pour -20% sur votre première commande.', 'date': '2025-01-15', 'type': 'promo'},
    {'id': 'n3', 'title': 'Nouveaux partenaires pharmacie', 'content': 'Pharmacie du Centre et Pharmacie Bacongo rejoignent Yadeli.', 'date': '2025-02-01', 'type': 'newsletter'},
  ];

  static Future<void> markAsSent(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_sentKey) ?? [];
      if (!list.contains(id)) {
        list.add(id);
        await prefs.setStringList(_sentKey, list);
      }
    } catch (_) {}
  }

  static Future<bool> sendNewsletterToUser(Map<String, dynamic> n) async {
    try {
      final email = await UserService.getUserEmail();
      final phone = await UserService.getUserPhone();
      final text = '${n['title']}\n\n${n['content']}\n\n— Yadeli';
      if (email != null && email.isNotEmpty) {
        final uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(n['title'] ?? '')}&body=${Uri.encodeComponent(text)}');
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {}
      }
      if (phone != null) {
        final smsUri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(text)}');
        try {
          await launchUrl(smsUri, mode: LaunchMode.externalApplication);
        } catch (_) {}
      }
      await markAsSent(n['id']?.toString() ?? '');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> addNewsletter(Map<String, dynamic> n) async {
    final list = await getNewsletters();
    list.insert(0, {...n, 'date': DateTime.now().toIso8601String()});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, list.map((e) => jsonEncode(e)).toList());
  }
}
