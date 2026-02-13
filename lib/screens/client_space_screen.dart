import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/invoice_service.dart';
import '../services/user_activity_service.dart';
import '../services/favorites_service.dart';
import '../services/newsletter_service.dart';
import 'establishment_profile_screen.dart';
import 'driver_profile_screen.dart';
import '../services/demo_data_service.dart';

/// Espace client — factures, historique, favoris, newsletters
class ClientSpaceScreen extends StatefulWidget {
  const ClientSpaceScreen({super.key});

  @override
  State<ClientSpaceScreen> createState() => _ClientSpaceScreenState();
}

class _ClientSpaceScreenState extends State<ClientSpaceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Espace client"),
        backgroundColor: Colors.green[700],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: "Factures"),
            Tab(icon: Icon(Icons.history), text: "Historique"),
            Tab(icon: Icon(Icons.favorite), text: "Favoris"),
            Tab(icon: Icon(Icons.auto_awesome), text: "Suggestions"),
            Tab(icon: Icon(Icons.campaign), text: "Newsletters"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInvoicesTab(),
          _buildHistoryTab(),
          _buildFavoritesTab(),
          _buildSuggestionsTab(),
          _buildNewslettersTab(),
        ],
      ),
    );
  }

  Widget _buildInvoicesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: InvoiceService.getSavedInvoices(),
      builder: (context, snap) {
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return const Center(child: Text("Aucune facture. Vos factures (commandes, annulations) apparaîtront ici."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final inv = list[i];
            final order = inv['order'] as Map<String, dynamic>? ?? {};
            final type = inv['type'] ?? InvoiceService.typeOrder;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(type == InvoiceService.typeCancellation ? Icons.cancel : Icons.receipt, color: Colors.green[700]),
                title: Text("${type == InvoiceService.typeCancellation ? 'Annulation' : 'Commande'} #${inv['orderId']}"),
                subtitle: Text(inv['sentAt']?.toString().substring(0, 16) ?? ''),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'pdf') await InvoiceService.shareAsPdf(order, type: type);
                    if (v == 'share') await Share.share(inv['text']?.toString() ?? '');
                    if (v == 'resend') await InvoiceService.sendInvoice(order, type: type);
                    if (mounted) setState(() {});
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'pdf', child: ListTile(leading: Icon(Icons.picture_as_pdf), title: Text("Télécharger PDF"))),
                    const PopupMenuItem(value: 'share', child: ListTile(leading: Icon(Icons.share), title: Text("Partager"))),
                    const PopupMenuItem(value: 'resend', child: ListTile(leading: Icon(Icons.email), title: Text("Renvoyer mail/SMS/WhatsApp"))),
                  ],
                ),
                onTap: () {
                  final order = inv['order'] as Map<String, dynamic>?;
                  if (order != null && order.isNotEmpty) _showInvoiceDialog(inv);
                  else showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Facture"), content: SelectableText(inv['text']?.toString() ?? ''), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer"))]));
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showInvoiceDialog(Map<String, dynamic> inv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Facture #${inv['orderId']}"),
        content: SingleChildScrollView(child: SelectableText(inv['text']?.toString() ?? '')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await InvoiceService.shareAsPdf(inv['order'] as Map<String, dynamic>? ?? {}, type: inv['type'] ?? InvoiceService.typeOrder);
            },
            child: const Text("PDF"),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: UserActivityService.getActivities(),
      builder: (context, snap) {
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return const Center(child: Text("Aucune activité. Votre historique apparaîtra ici."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final a = list[i];
            final type = a['type'] ?? '';
            final data = a['data'] as Map<String, dynamic>? ?? {};
            final at = a['at']?.toString().substring(0, 16) ?? '';
            String label = type;
            IconData icon = Icons.history;
            if (type == 'order') {
              label = "Commande ${data['category']} - ${data['price']} XAF";
              icon = Icons.shopping_cart;
            } else if (type == 'order_cancelled') {
              label = "Annulation #${data['orderId']}";
              icon = Icons.cancel;
            } else if (type == 'establishment_viewed') {
              label = "Vu: ${data['name']}";
              icon = Icons.store;
            } else if (type == 'driver_viewed') {
              label = "Vu: ${data['name']}";
              icon = Icons.person;
            } else if (type == 'favorite_added') {
              label = "Favori: ${data['name']}";
              icon = Icons.favorite;
            }
            return ListTile(
              leading: Icon(icon, color: Colors.green[700], size: 20),
              title: Text(label, style: const TextStyle(fontSize: 14)),
              subtitle: Text(at),
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
      future: Future.wait([
        FavoritesService.getFavoriteEstablishments(),
        FavoritesService.getFavoriteDrivers(),
      ]).then((r) => {'establishments': r[0], 'drivers': r[1]}),
      builder: (context, snap) {
        final est = snap.data?['establishments'] ?? [];
        final drv = snap.data?['drivers'] ?? [];
        if (est.isEmpty && drv.isEmpty) {
          return const Center(child: Text("Aucun favori. Ajoutez des établissements ou chauffeurs en favoris."));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (est.isNotEmpty) ...[
              const Text("Établissements favoris", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...est.map((e) => ListTile(
                leading: const Icon(Icons.store, color: Colors.green),
                title: Text(e['name'] ?? ''),
                subtitle: Text(e['category'] ?? ''),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                  await FavoritesService.removeFavoriteEstablishment(e['id']?.toString() ?? '');
                  setState(() {});
                }),
                onTap: () {
                  final model = DemoDataService.getEstablishmentById(e['id']?.toString() ?? '');
                  if (model != null) Navigator.push(context, MaterialPageRoute(builder: (_) => EstablishmentProfileScreen(establishment: model)));
                },
              )),
              const SizedBox(height: 20),
            ],
            if (drv.isNotEmpty) ...[
              const Text("Chauffeurs/Livreurs favoris", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...drv.map((d) => ListTile(
                leading: const Icon(Icons.person, color: Colors.green),
                title: Text(d['name'] ?? ''),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                  await FavoritesService.removeFavoriteDriver(d['id']?.toString() ?? '');
                  setState(() {});
                }),
                onTap: () {
                  final model = DemoDataService.getDriverById(d['id']?.toString() ?? '');
                  if (model != null) Navigator.push(context, MaterialPageRoute(builder: (_) => DriverProfileScreen(driver: model)));
                },
              )),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSuggestionsTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: UserActivityService.getHabits(),
      builder: (context, snap) {
        final habits = snap.data ?? {};
        final topCat = (habits['topCategories'] as List?)?.cast<MapEntry<String, int>>() ?? [];
        final topEst = (habits['topEstablishments'] as List?)?.cast<MapEntry<String, int>>() ?? [];
        final topDrv = (habits['topDrivers'] as List?)?.cast<MapEntry<String, int>>() ?? [];
        if (topCat.isEmpty && topEst.isEmpty && topDrv.isEmpty) {
          return const Center(child: Text("Passez des commandes et consultez des établissements pour recevoir des suggestions personnalisées."));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (topCat.isNotEmpty) ...[
              const Text("Catégories préférées", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...topCat.take(5).map((e) => ListTile(leading: const Icon(Icons.category), title: Text(e.key), subtitle: Text("${e.value} commande(s)"))),
              const SizedBox(height: 20),
            ],
            if (topEst.isNotEmpty) ...[
              const Text("Établissements souvent consultés", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...topEst.take(5).map((e) {
                final model = DemoDataService.getEstablishmentById(e.key);
                return ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(model?.name ?? e.key),
                  subtitle: Text("${e.value} vue(s)"),
                  onTap: model != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => EstablishmentProfileScreen(establishment: model))) : null,
                );
              }),
              const SizedBox(height: 20),
            ],
            if (topDrv.isNotEmpty) ...[
              const Text("Chauffeurs souvent consultés", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...topDrv.take(5).map((e) {
                final model = DemoDataService.getDriverById(e.key);
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(model?.name ?? e.key),
                  subtitle: Text("${e.value} vue(s)"),
                  onTap: model != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => DriverProfileScreen(driver: model))) : null,
                );
              }),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNewslettersTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: NewsletterService.getNewsletters(),
      builder: (context, snap) {
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return const Center(child: Text("Aucune newsletter."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final n = list[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(n['type'] == 'promo' ? Icons.local_offer : Icons.campaign, color: Colors.green[700]),
                title: Text(n['title'] ?? ''),
                subtitle: Text((n['content'] ?? '').toString().length > 80 ? '${(n['content'] ?? '').toString().substring(0, 80)}...' : n['content']?.toString() ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => NewsletterService.sendNewsletterToUser(n),
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(n['title'] ?? ''),
                    content: SingleChildScrollView(child: Text(n['content']?.toString() ?? '')),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer"))],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
