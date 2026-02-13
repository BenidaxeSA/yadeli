import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de notifications SMS/email — mode démo + préparation Firebase/Twilio
class NotificationService {
  static const _sentKey = 'yadeli_notif_sent';

  /// Envoie une notification de confirmation de réception (SMS/email)
  /// En production : brancher Firebase Cloud Messaging + Twilio/SendGrid
  static Future<bool> sendConfirmationNotification({
    required String orderId,
    required String code,
    String? userEmail,
    String? userPhone,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = await _getUserContact();
      final email = user.email;
      final phone = user.phone ?? '+242 06 444 22 11';

      // Mode démo : simule l'envoi et enregistre
      final payload = jsonEncode({
        'orderId': orderId,
        'code': code,
        'email': email,
        'phone': phone,
        'sentAt': DateTime.now().toIso8601String(),
      });
      final list = prefs.getStringList(_sentKey) ?? [];
      list.add(payload);
      await prefs.setStringList(_sentKey, list);

      // En production : appeler Twilio pour SMS, SendGrid/Firebase pour email
      // await TwilioService.sendSms(phone, 'Yadeli: Code de confirmation $code');
      // await EmailService.send(email, 'Confirmation Yadeli', 'Votre code: $code');

      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<({String? email, String? phone})> _getUserContact() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return (
        email: prefs.getString('yadeli_user_email'),
        phone: prefs.getString('yadeli_user_phone'),
      );
    } catch (_) {
      return (email: null, phone: null);
    }
  }

  /// Notification météo / circulation / blocage
  static Future<void> notifyTrafficOrWeather(String message) async {
    // En production : push notification via FCM
    // ignore: avoid_print
    print('[Yadeli Notif] $message');
  }

  /// Notification d'arrivée du chauffeur
  static Future<void> notifyDriverArrival(String driverName, int etaMinutes) async {
    // ignore: avoid_print
    print('[Yadeli Notif] $driverName arrive dans $etaMinutes min');
  }
}
