import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import '../services/order_service.dart';
import '../services/location_share_service.dart';
import '../services/notification_service.dart';
import '../services/late_fee_service.dart';
import '../src/platform_mapbox.dart';
import 'rating_screen.dart';
import 'driver_profile_screen.dart';
import 'report_screen.dart';
import 'help_request_screen.dart';

/// Écran course en cours — Uber, Bolt, Citymapper
/// Carte, infos chauffeur, ETA, statuts, partager, contacter
class RideInProgressScreen extends StatefulWidget {
  final String orderId;
  final String pickup;
  final String delivery;
  final String category;
  final double price;

  const RideInProgressScreen({super.key, required this.orderId, required this.pickup, required this.delivery, required this.category, required this.price});

  @override
  State<RideInProgressScreen> createState() => _RideInProgressScreenState();
}

class _RideInProgressScreenState extends State<RideInProgressScreen> {
  String _status = OrderService.statusSearching;
  String? _driverName;
  String? _driverPhone;
  double? _driverRating;
  int? _etaMinutes;
  Timer? _simulationTimer;
  String _receptionCode = '';
  String? _notificationMessage; // météo, circulation, ambulance, bloqué...
  int? _driverDelayMinutes; // retard du chauffeur → réduction/code promo

  @override
  void initState() {
    super.initState();
    _simulateStatusProgression();
  }

  Future<void> _simulateStatusProgression() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await OrderService.updateOrderStatus(widget.orderId, OrderService.statusAssigned, driverName: 'Jean-Marc Okemba', driverPhone: '+242 06 123 45 67', driverRating: 4.8, etaMinutes: 5, driverId: 'd1');
    setState(() {
      _status = OrderService.statusAssigned;
      _driverName = 'Jean-Marc Okemba';
      _driverPhone = '+242 06 123 45 67';
      _driverRating = 4.8;
      _etaMinutes = 5;
    });

    _simulationTimer = Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      await OrderService.updateOrderStatus(widget.orderId, OrderService.statusEnRoute);
      if (mounted) {
        setState(() {
          _status = OrderService.statusEnRoute;
          _notificationMessage = "Trafic dense, arrivée possible avec quelques minutes de retard";
          _driverDelayMinutes = 5; // simulation : 5 min de retard
        });
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() {
            _notificationMessage = null;
            _driverDelayMinutes = null;
          });
        });
      }
    });

    Future.delayed(const Duration(seconds: 6), () async {
      if (!mounted) return;
      await OrderService.updateOrderStatus(widget.orderId, OrderService.statusArrived);
      if (mounted) {
        final code = '${DateTime.now().second.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}';
        setState(() {
          _status = OrderService.statusArrived;
          _receptionCode = code;
        });
        await NotificationService.sendConfirmationNotification(orderId: widget.orderId, code: code);
      }
    });

    Future.delayed(const Duration(seconds: 8), () async {
      if (!mounted) return;
      await OrderService.updateOrderStatus(widget.orderId, OrderService.statusInProgress);
      if (mounted) setState(() => _status = OrderService.statusInProgress);
    });

    Future.delayed(const Duration(seconds: 12), () async {
      if (!mounted) return;
      await OrderService.updateOrderStatus(widget.orderId, OrderService.statusCompleted);
      if (mounted) setState(() => _status = OrderService.statusCompleted);
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  String _statusLabel() {
    switch (_status) {
      case OrderService.statusSearching:
        return "Recherche d'un chauffeur...";
      case OrderService.statusAssigned:
        return "Chauffeur assigné";
      case OrderService.statusEnRoute:
        return "En route vers vous";
      case OrderService.statusArrived:
        return "Chauffeur arrivé";
      case OrderService.statusInProgress:
        return "Course en cours";
      case OrderService.statusCompleted:
        return "Course terminée";
      default:
        return _status;
    }
  }

  void _goToRating() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RatingScreen(orderId: widget.orderId, category: widget.category, driverName: _driverName)));
  }

  void _openDriverProfile() {
    if (_driverName == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => DriverProfileScreen(driverId: 'd1')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_statusLabel()),
        backgroundColor: Colors.green[700],
        leading: _status == OrderService.statusCompleted ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.popUntil(context, (r) => r.isFirst)) : null,
      ),
      body: Column(
        children: [
          if (_notificationMessage != null) _buildNotificationBanner(),
          Expanded(
            child: isMapboxSupported
                ? _buildMapPlaceholder()
                : fm.FlutterMap(
                    options: fm.MapOptions(
                      initialCenter: const LatLng(-4.2634, 15.2832),
                      initialZoom: 14,
                      interactionOptions: const fm.InteractionOptions(flags: fm.InteractiveFlag.all),
                    ),
                    children: [
                      fm.TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.yadeli.app',
                      ),
                    ],
                  ),
          ),
          _buildBottomPanel(),
        ],
      ),
      floatingActionButton: _status != OrderService.statusSearching && _status != OrderService.statusCompleted
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'share',
                  onPressed: _shareLocation,
                  child: const Icon(Icons.share_location),
                  backgroundColor: Colors.green[700],
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'report',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportScreen(orderId: widget.orderId))),
                  child: const Icon(Icons.report),
                  backgroundColor: Colors.orange,
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'police',
                  onPressed: _reportToPolice,
                  child: const Icon(Icons.shield),
                  backgroundColor: Colors.red,
                ),
              ],
            )
          : null,
    );
  }

  void _shareLocation() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Partager ma localisation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.green),
              title: const Text("Avec mes proches (SMS)"),
              onTap: () async {
                Navigator.pop(context);
                final ok = await LocationShareService.shareWithProches();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? "Localisation partagée avec vos proches" : "Impossible d'ouvrir l'application SMS"),
                  backgroundColor: ok ? Colors.green : Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text("Via WhatsApp"),
              onTap: () async {
                Navigator.pop(context);
                final ok = await LocationShareService.shareViaWhatsApp();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? "WhatsApp ouvert" : "Impossible d'ouvrir WhatsApp"),
                  backgroundColor: ok ? Colors.green : Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield, color: Colors.red),
              title: const Text("Signaler à la police (urgence)"),
              onTap: () async {
                Navigator.pop(context);
                final ok = await LocationShareService.reportToPoliceWithLocation();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? "Localisation envoyée à la police" : "Impossible d'ouvrir l'application"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_fire_department, color: Colors.orange),
              title: const Text("Appeler les pompiers (118)"),
              onTap: () async {
                Navigator.pop(context);
                await LocationShareService.callPompiers();
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_hospital, color: Colors.red),
              title: const Text("Appeler le SAMU / Hôpital (3434)"),
              onTap: () async {
                Navigator.pop(context);
                await LocationShareService.callSamu();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRefuseDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Refuser la course/livraison"),
        content: const Text("Vous avez le droit de refuser si la personne, la plaque ou le badge ne correspondent pas au profil. Pour votre sécurité, contactez le support."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => HelpRequestScreen(orderId: widget.orderId)));
            },
            child: const Text("Demander de l'aide"),
          ),
        ],
      ),
    );
  }

  void _reportToPolice() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Signaler une insécurité"),
        content: const Text("Votre localisation sera partagée avec la police. En cas d'urgence, appelez le 117."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await LocationShareService.reportToPoliceWithLocation();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok ? "Signalement envoyé à la police. Localisation partagée." : "Impossible d'ouvrir l'application."),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ));
            },
            child: const Text("Signaler"),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBanner() {
    final discount = _driverDelayMinutes != null ? LateFeeService.driverLateDiscount(_driverDelayMinutes!) : 0.0;
    final promoCode = _driverDelayMinutes != null ? LateFeeService.generateDelayPromoCode(_driverDelayMinutes!) : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.orange[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.orange[800]),
              const SizedBox(width: 12),
              Expanded(child: Text(_notificationMessage!, style: TextStyle(color: Colors.orange[900]))),
            ],
          ),
          const SizedBox(height: 8),
          Text("Météo, circulation, ambulance peuvent causer des retards.", style: TextStyle(fontSize: 11, color: Colors.orange[800])),
          if (discount > 0 && promoCode.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Réduction pour retard du chauffeur : -${discount.round()} XAF", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
                  Text("Code promo : $promoCode", style: TextStyle(fontSize: 12, color: Colors.green[700])),
                ],
              ),
            ),
          ],
          TextButton.icon(
            icon: const Icon(Icons.report, size: 18),
            label: const Text("Signaler si bloqué au même endroit"),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportScreen(orderId: widget.orderId))),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text("Carte du trajet", style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -4))]),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_driverName != null) ...[
              Row(
                children: [
                  GestureDetector(
                    onTap: _openDriverProfile,
                    child: CircleAvatar(radius: 30, backgroundColor: Colors.green[100], child: Text(_driverName!.substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _openDriverProfile,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_driverName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          if (_driverRating != null) Row(children: [Icon(Icons.star, size: 18, color: Colors.amber[700]), const SizedBox(width: 4), Text("${_driverRating!.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.w600))]),
                          Text("Voir le profil", style: TextStyle(fontSize: 12, color: Colors.green[700])),
                        ],
                      ),
                    ),
                  ),
                  if (_driverPhone != null)
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Appel: $_driverPhone"), behavior: SnackBarBehavior.floating)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.green),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lien de partage copié !"), behavior: SnackBarBehavior.floating)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (_driverName != null && _status != OrderService.statusCompleted) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Vérifiez l'identité : la personne, la plaque et le badge Yadeli doivent correspondre au profil.", style: TextStyle(fontSize: 12, color: Colors.blue[900])),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.block, size: 18),
                          label: const Text("Refuser"),
                          onPressed: () => _showRefuseDialog(),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.help, size: 18),
                          label: const Text("Aide"),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelpRequestScreen(orderId: widget.orderId))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (_receptionCode.isNotEmpty) ...[
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text("Code de confirmation : donnez ce code au chauffeur/livreur", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(_receptionCode, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8, color: Colors.green[800])),
                      const SizedBox(height: 8),
                      Text("Vous serez notifié par SMS/email à la confirmation.", style: TextStyle(fontSize: 11, color: Colors.green[700])),
                      const SizedBox(height: 8),
                      Text("En cas de retard de votre part, des frais de ${LateFeeService.clientLateFeePer5Min.round()} XAF peuvent s'appliquer par tranche de 5 min.", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            _buildRouteInfo(),
            const SizedBox(height: 16),
            if (_status == OrderService.statusCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToRating,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("NOTER LA COURSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            else if (_etaMinutes != null && _status != OrderService.statusSearching)
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Text("Arrivée dans ~$_etaMinutes min", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green[800])),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [Icon(Icons.trip_origin, color: Colors.green[700], size: 20), const SizedBox(width: 12), Expanded(child: Text(widget.pickup, style: const TextStyle(fontWeight: FontWeight.w500)))]),
            Padding(padding: const EdgeInsets.only(left: 9), child: Container(width: 2, height: 20, color: Colors.grey[400])),
            Row(children: [Icon(Icons.location_on, color: Colors.red[400], size: 20), const SizedBox(width: 12), Expanded(child: Text(widget.delivery, style: const TextStyle(fontWeight: FontWeight.w500)))]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("${widget.category} • ${widget.price.round()} XAF", style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      ),
    );
  }
}
