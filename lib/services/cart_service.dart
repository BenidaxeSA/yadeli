import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Panier — articles à commander
class CartItem {
  final String id;
  final String category;
  final String name;
  final double price;
  final int quantity;
  final String? establishmentId;
  final Map<String, dynamic>? details;

  CartItem({
    required this.id,
    required this.category,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.establishmentId,
    this.details,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() => {
    'id': id, 'category': category, 'name': name, 'price': price,
    'quantity': quantity, 'establishmentId': establishmentId, 'details': details,
  };

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
    id: j['id'] ?? '', category: j['category'] ?? '', name: j['name'] ?? '',
    price: (j['price'] ?? 0).toDouble(), quantity: j['quantity'] ?? 1,
    establishmentId: j['establishmentId'], details: j['details'] as Map<String, dynamic>?,
  );
}

class CartService {
  static const _key = 'yadeli_cart';

  static Future<List<CartItem>> getItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      return list.map((e) => CartItem.fromJson(Map<String, dynamic>.from(jsonDecode(e)))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addItem(CartItem item) async {
    final items = await getItems();
    final idx = items.indexWhere((i) => i.id == item.id && i.establishmentId == item.establishmentId);
    if (idx >= 0) {
      items[idx] = CartItem(id: item.id, category: item.category, name: item.name, price: item.price, quantity: items[idx].quantity + item.quantity, establishmentId: item.establishmentId, details: item.details);
    } else {
      items.add(item);
    }
    await _save(items);
  }

  static Future<void> removeItem(String id, [String? establishmentId]) async {
    final items = await getItems();
    items.removeWhere((i) => i.id == id && (establishmentId == null || i.establishmentId == establishmentId));
    await _save(items);
  }

  static Future<void> updateQuantity(String id, int qty, [String? establishmentId]) async {
    final items = await getItems();
    final idx = items.indexWhere((i) => i.id == id && (establishmentId == null || i.establishmentId == establishmentId));
    if (idx >= 0) {
      if (qty <= 0) {
        items.removeAt(idx);
      } else {
        final old = items[idx];
        items[idx] = CartItem(id: old.id, category: old.category, name: old.name, price: old.price, quantity: qty, establishmentId: old.establishmentId, details: old.details);
      }
      await _save(items);
    }
  }

  static Future<void> clear() async {
    await _save([]);
  }

  static Future<void> _save(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, items.map((e) => jsonEncode(e.toJson())).toList());
  }

  static Future<double> getTotal() async {
    final items = await getItems();
    return items.fold<double>(0.0, (double s, CartItem i) => s + i.total);
  }
}
