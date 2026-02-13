import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_activity_service.dart';

/// Favoris : établissements et chauffeurs/livreurs
class FavoritesService {
  static const _establishmentsKey = 'yadeli_fav_establishments';
  static const _driversKey = 'yadeli_fav_drivers';

  static Future<List<Map<String, dynamic>>> getFavoriteEstablishments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_establishmentsKey) ?? [];
      return list.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getFavoriteDrivers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_driversKey) ?? [];
      return list.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> isFavoriteEstablishment(String id) async {
    final list = await getFavoriteEstablishments();
    return list.any((e) => e['id']?.toString() == id);
  }

  static Future<bool> isFavoriteDriver(String id) async {
    final list = await getFavoriteDrivers();
    return list.any((e) => e['id']?.toString() == id);
  }

  static Future<void> addFavoriteEstablishment(Map<String, dynamic> e) async {
    final list = await getFavoriteEstablishments();
    if (list.any((x) => x['id']?.toString() == e['id']?.toString())) return;
    list.add(e);
    await _saveEstablishments(list);
    await UserActivityService.logFavoriteAdded('establishment', e['id']?.toString() ?? '', e['name']?.toString() ?? '');
  }

  static Future<void> addFavoriteDriver(Map<String, dynamic> d) async {
    final list = await getFavoriteDrivers();
    if (list.any((x) => x['id']?.toString() == d['id']?.toString())) return;
    list.add(d);
    await _saveDrivers(list);
    await UserActivityService.logFavoriteAdded('driver', d['id']?.toString() ?? '', d['name']?.toString() ?? '');
  }

  static Future<void> removeFavoriteEstablishment(String id) async {
    final list = await getFavoriteEstablishments();
    list.removeWhere((e) => e['id']?.toString() == id);
    await _saveEstablishments(list);
  }

  static Future<void> removeFavoriteDriver(String id) async {
    final list = await getFavoriteDrivers();
    list.removeWhere((e) => e['id']?.toString() == id);
    await _saveDrivers(list);
  }

  static Future<void> _saveEstablishments(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_establishmentsKey, list.map((e) => jsonEncode(e)).toList());
  }

  static Future<void> _saveDrivers(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_driversKey, list.map((e) => jsonEncode(e)).toList());
  }
}
