import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'invoice_service.dart';
import 'user_activity_service.dart';

/// Résultat d'une commande
class OrderResult {
  final bool success;
  final String message;
  final bool isDemoMode;
  final String? orderId;

  OrderResult({required this.success, required this.message, this.isDemoMode = false, this.orderId});
}

/// Service de commande : backend Supabase avec fallback mode démo en cas d'erreur réseau
class OrderService {
  static const _demoOrdersKey = 'yadeli_demo_orders';
  static const _cancelledOrdersKey = 'yadeli_cancelled_orders';

  static const statusSearching = 'searching';
  static const statusAssigned = 'assigned';
  static const statusEnRoute = 'en_route';
  static const statusArrived = 'arrived';
  static const statusInProgress = 'in_progress';
  static const statusCompleted = 'terminé';
  static const statusCancelled = 'cancelled';

  /// Crée une commande via Supabase, ou en mode démo si le backend est inaccessible
  static Future<OrderResult> createOrder({
    required String category,
    required double price,
    String? clientId,
    Map<String, dynamic>? pickupData,
    Map<String, dynamic>? deliveryData,
    String? pickupAddress,
    String? deliveryAddress,
    Map<String, dynamic>? orderDetails,
  }) async {
    final pickup = pickupAddress ?? pickupData?['address'] ?? 'Ma Campagne';
    final delivery = deliveryAddress ?? deliveryData?['address'] ?? 'Poto-Poto';
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'create-order',
        body: {
          'client_id': clientId ?? Supabase.instance.client.auth.currentUser?.id,
          'category': category,
          'total_price': price,
          'pickup_data': pickupData ?? {'address': pickup},
          'delivery_data': deliveryData ?? {'address': delivery},
        },
      );

      if (response.status == 200) {
        return OrderResult(success: true, message: 'Commande réussie ! $price XAF');
      } else {
        final msg = response.data?['error'] ?? 'Erreur ${response.status}';
        return OrderResult(success: false, message: 'Échec: $msg');
      }
    } catch (e) {
      final str = e.toString();
      if (str.contains('SocketException') || str.contains('Failed host lookup') || str.contains('Connection')) {
        final id = await _saveDemoOrder(category, price, pickup: pickup, delivery: delivery, orderDetails: orderDetails);
        try {
          final orders = await getDemoOrders();
          final order = orders.firstWhere((o) => o['id']?.toString() == id);
          await InvoiceService.sendInvoice(order);
          await UserActivityService.logOrder(id, category, price);
        } catch (_) {}
        return OrderResult(
          success: true,
          message: 'Commande enregistrée ! $price XAF',
          isDemoMode: true,
          orderId: id,
        );
      }
      return OrderResult(success: false, message: 'Erreur: ${str.split('\n').first}');
    }
  }

  static Future<String> _saveDemoOrder(String category, double price, {String? pickup, String? delivery, Map<String, dynamic>? orderDetails}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_demoOrdersKey) ?? [];
      final userName = await _getUserName();
      final userPhone = await _getUserPhone();
      final userGender = await _getUserGender();
      existing.add(jsonEncode({
        'id': id,
        'category': category,
        'price': price,
        'date': DateTime.now().toIso8601String(),
        'client_name': userName,
        'client_phone': userPhone,
        'client_gender': userGender,
        'pickup': pickup ?? 'Ma Campagne',
        'delivery': delivery ?? 'Poto-Poto',
        'status': statusSearching,
        'driver_name': null,
        'driver_phone': null,
        'driver_rating': null,
        'eta_minutes': null,
        'rating': null,
        'order_details': orderDetails,
        'tip': 0,
        'cancellation_fee': 0,
        'confirmed_by_establishment': false,
        'confirmed_by_driver': false,
      }));
      await prefs.setStringList(_demoOrdersKey, existing);
    } catch (_) {}
    return id;
  }

  static Future<bool> updateOrderStatus(String id, String status, {String? driverName, String? driverPhone, double? driverRating, int? etaMinutes, String? driverId, String? establishmentId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_demoOrdersKey) ?? [];
      final idx = list.indexWhere((e) => (jsonDecode(e) as Map)['id'] == id);
      if (idx < 0) return false;
      final order = Map<String, dynamic>.from(jsonDecode(list[idx]));
      order['status'] = status;
      if (driverName != null) order['driver_name'] = driverName;
      if (driverPhone != null) order['driver_phone'] = driverPhone;
      if (driverRating != null) order['driver_rating'] = driverRating;
      if (etaMinutes != null) order['eta_minutes'] = etaMinutes;
      if (driverId != null) order['driver_id'] = driverId;
      if (establishmentId != null) order['establishment_id'] = establishmentId;
      list[idx] = jsonEncode(order);
      await prefs.setStringList(_demoOrdersKey, list);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> setOrderTip(String id, int tipXaf) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_demoOrdersKey) ?? [];
      final idx = list.indexWhere((e) => (jsonDecode(e) as Map)['id']?.toString() == id);
      if (idx < 0) return false;
      final order = Map<String, dynamic>.from(jsonDecode(list[idx]));
      order['tip'] = tipXaf;
      list[idx] = jsonEncode(order);
      await prefs.setStringList(_demoOrdersKey, list);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> setOrderRating(String id, int stars, [String? comment, int? driverStars, int? establishmentStars, String? driverComment, String? establishmentComment, bool? liked, List<String>? packageImagePaths]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_demoOrdersKey) ?? [];
      final idx = list.indexWhere((e) => (jsonDecode(e) as Map)['id']?.toString() == id);
      if (idx < 0) return false;
      final order = Map<String, dynamic>.from(jsonDecode(list[idx]));
      order['rating'] = stars;
      if (comment != null) order['rating_comment'] = comment;
      if (driverStars != null) order['driver_rating_given'] = driverStars;
      if (establishmentStars != null) order['establishment_rating_given'] = establishmentStars;
      if (driverComment != null) order['driver_comment'] = driverComment;
      if (establishmentComment != null) order['establishment_comment'] = establishmentComment;
      if (liked != null) order['liked'] = liked;
      if (packageImagePaths != null) order['package_images'] = packageImagePaths;
      order['status'] = 'terminé';
      list[idx] = jsonEncode(order);
      await prefs.setStringList(_demoOrdersKey, list);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('yadeli_user_name') ?? 'Utilisateur Yadeli';
  }

  static Future<String> _getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('yadeli_user_phone') ?? '+242 06 444 22 11';
  }

  static Future<String> _getUserGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('yadeli_user_gender') ?? 'homme';
  }

  static Future<List<Map<String, dynamic>>> getDemoOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_demoOrdersKey) ?? [];
      return list.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> cancelOrder(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_demoOrdersKey) ?? [];
      final idx = list.indexWhere((e) => (jsonDecode(e) as Map)['id'] == id);
      if (idx < 0) return false;
      final order = Map<String, dynamic>.from(jsonDecode(list[idx]));
      order['status'] = statusCancelled;
      order['cancelled_at'] = DateTime.now().toIso8601String();
      list.removeAt(idx);
      try {
        await InvoiceService.sendInvoice(order, type: InvoiceService.typeCancellation);
        await UserActivityService.logOrderCancelled(order['id']?.toString() ?? '', 'client');
      } catch (_) {}
      await prefs.setStringList(_demoOrdersKey, list);
      final cancelled = prefs.getStringList(_cancelledOrdersKey) ?? [];
      cancelled.add(jsonEncode(order));
      await prefs.setStringList(_cancelledOrdersKey, cancelled);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> modifyOrder(String id, {String? pickup, String? delivery}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_demoOrdersKey) ?? [];
      final idx = list.indexWhere((e) => (jsonDecode(e) as Map)['id'] == id);
      if (idx < 0) return false;
      final order = Map<String, dynamic>.from(jsonDecode(list[idx]));
      if (order['status'] != statusSearching && order['status'] != statusAssigned) return false;
      if (pickup != null) order['pickup'] = pickup;
      if (delivery != null) order['delivery'] = delivery;
      list[idx] = jsonEncode(order);
      await prefs.setStringList(_demoOrdersKey, list);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getCancelledOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_cancelledOrdersKey) ?? [];
      return list.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getOrderById(String id) async {
    final orders = await getDemoOrders();
    try {
      return orders.firstWhere((o) => o['id'].toString() == id);
    } catch (_) {
      return null;
    }
  }
}
