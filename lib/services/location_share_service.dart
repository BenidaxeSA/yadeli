import 'package:url_launcher/url_launcher.dart';
import 'location_service.dart';

/// Partage de localisation avec proches, police, pompiers, hopital
class LocationShareService {
  static const policeCongo = '117';
  static const pompiersCongo = '118';
  static const samuCongo = '3434';

  static String _buildMapsUrl(double lat, double lng) =>
      'https://www.google.com/maps?q=$lat,$lng';

  static String _buildSmsBody(double lat, double lng, {String? context}) {
    final url = _buildMapsUrl(lat, lng);
    return '${context ?? "Ma position Yadeli"}: $url (Lat: $lat, Lng: $lng)';
  }

  static Future<bool> shareWithProches({String? message}) async {
    try {
      final loc = await LocationService.getCurrentLocation();
      if (!loc.success || loc.latitude == null || loc.longitude == null) {
        return false;
      }
      final body = message ?? _buildSmsBody(loc.latitude!, loc.longitude!, context: 'Position partagee via Yadeli');
      final uri = Uri.parse('sms:?body=${Uri.encodeComponent(body)}');
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> callPolice() async {
    try {
      final uri = Uri.parse('tel:$policeCongo');
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> callPompiers() async {
    try {
      final uri = Uri.parse('tel:$pompiersCongo');
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> callSamu() async {
    try {
      final uri = Uri.parse('tel:$samuCongo');
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> reportToPoliceWithLocation() async {
    try {
      final loc = await LocationService.getCurrentLocation();
      final body = loc.success && loc.latitude != null && loc.longitude != null
          ? _buildSmsBody(loc.latitude!, loc.longitude!, context: 'URGENCE Yadeli - Ma position')
          : 'URGENCE signalee via Yadeli';
      final smsUri = Uri.parse('sms:$policeCongo?body=${Uri.encodeComponent(body)}');
      return await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> shareViaWhatsApp({String? phone}) async {
    try {
      final loc = await LocationService.getCurrentLocation();
      if (!loc.success || loc.latitude == null || loc.longitude == null) return false;
      final url = _buildMapsUrl(loc.latitude!, loc.longitude!);
      final text = 'Ma position Yadeli: $url';
      final uri = Uri.parse(
        phone != null
            ? 'https://wa.me/$phone?text=${Uri.encodeComponent(text)}'
            : 'https://wa.me/?text=${Uri.encodeComponent(text)}',
      );
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openMapsLink(double lat, double lng) async {
    try {
      final uri = Uri.parse(_buildMapsUrl(lat, lng));
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
