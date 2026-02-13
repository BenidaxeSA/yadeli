import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

/// Panier — articles à commander
class CartScreen extends StatefulWidget {
  final VoidCallback? onOrderPlaced;

  const CartScreen({super.key, this.onOrderPlaced});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _items = [];
  bool _loading = true;
  bool _ordering = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await CartService.getItems();
    if (mounted) setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _placeOrder() async {
    if (_items.isEmpty) return;
    setState(() => _ordering = true);
    final total = await CartService.getTotal();
    final categories = _items.map((i) => i.category).toSet().join(', ');
    final result = await OrderService.createOrder(
      category: categories,
      price: total,
      orderDetails: {'items': _items.map((i) => i.toJson()).toList()},
    );
    if (!mounted) return;
    setState(() => _ordering = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.message),
      backgroundColor: result.success ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
    if (result.success) {
      await CartService.clear();
      _load();
      widget.onOrderPlaced?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon panier"),
        backgroundColor: Colors.green[700],
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
                  title: const Text("Vider le panier ?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Non")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Oui", style: TextStyle(color: Colors.red))),
                  ],
                ));
                if (ok == true) {
                  await CartService.clear();
                  _load();
                }
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text("Panier vide", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("Ajouter des articles"),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (context, i) {
                          final item = _items[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("${item.category} • ${item.price.round()} XAF x ${item.quantity}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    onPressed: () async {
                                      await CartService.updateQuantity(item.id, item.quantity - 1, item.establishmentId);
                                      _load();
                                    },
                                  ),
                                  Text("${item.quantity}"),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                    onPressed: () async {
                                      await CartService.addItem(CartItem(id: item.id, category: item.category, name: item.name, price: item.price, quantity: 1, establishmentId: item.establishmentId, details: item.details));
                                      _load();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () async {
                                      await CartService.removeItem(item.id, item.establishmentId);
                                      _load();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4))]),
                      child: SafeArea(
                        child: Column(
                          children: [
                            FutureBuilder<double>(
                              future: CartService.getTotal(),
                              builder: (context, snap) => Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  Text("${(snap.data ?? 0).round()} XAF", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700])),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _ordering ? null : _placeOrder,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                child: _ordering ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("COMMANDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
