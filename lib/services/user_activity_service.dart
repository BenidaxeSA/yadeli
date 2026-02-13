import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserActivityService {
  static const _key = 'yadeli_user_activities';
  static const _maxActivities = 500;

  static Future<void> log(String type, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      list.add(jsonEncode({'type': type, 'data': data, 'at': DateTime.now().toIso8601String()}));
      if (list.length > _maxActivities) list.removeRange(0, list.length - _maxActivities);
      await prefs.setStringList(_key, list);
    } catch (_) {}
  }

  static Future<void> logOrder(String orderId, String category, double price) async =>
      log('order', {'orderId': orderId, 'category': category, 'price': price});

  static Future<void> logOrderCancelled(String orderId, String reason) async =>
      log('order_cancelled', {'orderId': orderId, 'reason': reason});

  static Future<void> logEstablishmentViewed(String id, String name, String category) async =>
      log('establishment_viewed', {'id': id, 'name': name, 'category': category});

  static Future<void> logEstablishmentSearched(String query) async =>
      log('establishment_searched', {'query': query});

  static Future<void> logDriverViewed(String id, String name) async =>
      log('driver_viewed', {'id': id, 'name': name});

  static Future<void> logDriverSearched(String query) async =>
      log('driver_searched', {'query': query});

  static Future<void> logFavoriteAdded(String type, String id, String name) async =>
      log('favorite_added', {'type': type, 'id': id, 'name': name});

  static Future<List<Map<String, dynamic>>> getActivities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      return list.reversed.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getHabits() async {
    final activities = await getActivities();
    final categories = <String, int>{};
    final establishments = <String, int>{};
    final drivers = <String, int>{};
    for (final a in activities) {
      final type = a['type'] as String?;
      final data = a['data'] as Map<String, dynamic>? ?? {};
      if (type == 'order') {
        final cat = data['category']?.toString() ?? '';
        if (cat.isNotEmpty) categories[cat] = (categories[cat] ?? 0) + 1;
      }
      if (type == 'establishment_viewed') {
        final id = data['id']?.toString() ?? '';
        if (id.isNotEmpty) establishments[id] = (establishments[id] ?? 0) + 1;
      }
      if (type == 'driver_viewed') {
        final id = data['id']?.toString() ?? '';
        if (id.isNotEmpty) drivers[id] = (drivers[id] ?? 0) + 1;
      }
    }
    return {
      'topCategories': categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      'topEstablishments': establishments.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      'topDrivers': drivers.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    };
  }
}
