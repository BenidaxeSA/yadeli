import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'user_service.dart';

/// Factures — commandes, annulations — mail/SMS/WhatsApp + espace client + PDF
class InvoiceService {
  static const _invoicesKey = 'yadeli_invoices';
  static const typeOrder = 'order';
  static const typeCancellation = 'cancellation';

  /// Génère le texte détaillé du récapitulatif
  static String buildInvoiceText(Map<String, dynamic> order, {String type = typeOrder}) {
    final date = DateTime.tryParse(order['date'] ?? '') ?? DateTime.now();
    final sb = StringBuffer();
    sb.writeln('═══════════════════════════════════');
    sb.writeln('   YADELI - ${type == typeCancellation ? 'FACTURE ANNULATION' : 'RÉCAPITULATIF'}');
    sb.writeln('═══════════════════════════════════');
    sb.writeln('');
    sb.writeln('Commande #${order['id']}');
    sb.writeln('Date: ${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}');
    sb.writeln('');
    sb.writeln('Service: ${order['category'] ?? 'Course'}');
    sb.writeln('Départ: ${order['pickup'] ?? '-'}');
    sb.writeln('Arrivée: ${order['delivery'] ?? '-'}');
    if (order['driver_name'] != null) sb.writeln('Chauffeur: ${order['driver_name']}');
    if (order['establishment_name'] != null) sb.writeln('Établissement: ${order['establishment_name']}');
    sb.writeln('');
    sb.writeln('Montant: ${order['price']} XAF');
    if ((order['tip'] ?? 0) > 0) sb.writeln('Pourboire: ${order['tip']} XAF');
    sb.writeln('');
    sb.writeln('Statut: ${_statusLabel(order['status'])}');
    sb.writeln('═══════════════════════════════════');
    return sb.toString();
  }

  static String _statusLabel(String? s) {
    switch (s) {
      case 'searching': return 'Recherche chauffeur';
      case 'assigned': return 'Chauffeur assigné';
      case 'en_route': return 'En route';
      case 'arrived': return 'Arrivé';
      case 'in_progress': return 'En cours';
      case 'terminé': return 'Terminé';
      case 'cancelled': return 'Annulé';
      default: return s ?? 'Terminé';
    }
  }

  /// Envoie le récap par mail/SMS/WhatsApp
  static Future<bool> sendInvoice(Map<String, dynamic> order, {String type = typeOrder}) async {
    try {
      final text = buildInvoiceText(order, type: type);
      final email = await UserService.getUserEmail();
      final phone = await UserService.getUserPhone();

      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_invoicesKey) ?? [];
      list.add(jsonEncode({
        'orderId': order['id'], 'type': type, 'sentAt': DateTime.now().toIso8601String(),
        'text': text, 'order': order,
      }));
      await prefs.setStringList(_invoicesKey, list);

      if (email != null && email.isNotEmpty) {
        final subj = type == typeCancellation ? 'Facture annulation' : 'Récap commande';
        final uri = Uri.parse('mailto:$email?subject=Yadeli%20-%20$subj%20${order['id']}&body=${Uri.encodeComponent(text)}');
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

      final waUri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
      try {
        await launchUrl(waUri, mode: LaunchMode.externalApplication);
      } catch (_) {}

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Génère un PDF et permet de partager/télécharger
  static Future<Uint8List> buildPdf(Map<String, dynamic> order, {String type = typeOrder}) async {
    final pdf = pw.Document();
    final text = buildInvoiceText(order, type: type);
    pdf.addPage(
      pw.Page(
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('YADELI - ${type == typeCancellation ? 'FACTURE ANNULATION' : 'RÉCAPITULATIF'}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  /// Affiche/partage en PDF
  static Future<void> shareAsPdf(Map<String, dynamic> order, {String type = typeOrder}) async {
    try {
      final bytes = await buildPdf(order, type: type);
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (_) {}
  }

  /// Liste des factures sauvegardées (vue dans l'app)
  static Future<List<Map<String, dynamic>>> getSavedInvoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_invoicesKey) ?? [];
      return list.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getInvoiceForOrder(String orderId) async {
    final invoices = await getSavedInvoices();
    try {
      return invoices.firstWhere((i) => i['orderId']?.toString() == orderId);
    } catch (_) {
      return null;
    }
  }
}
