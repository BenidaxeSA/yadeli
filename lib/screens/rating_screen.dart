import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;
import '../services/order_service.dart';

/// Notation complète : chauffeur, établissement, avis, likes, images colis
class RatingScreen extends StatefulWidget {
  final String orderId;
  final String category;
  final String? driverName;
  final String? establishmentName;

  const RatingScreen({super.key, required this.orderId, required this.category, this.driverName, this.establishmentName});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _stars = 0;
  int _driverStars = 0;
  int _establishmentStars = 0;
  int _tipXaf = 0;
  final _commentController = TextEditingController();
  final _driverCommentController = TextEditingController();
  final _establishmentCommentController = TextEditingController();
  bool? _liked;
  final List<String> _packageImages = [];
  bool _submitting = false;

  bool get _isDelivery => widget.category == 'Pharmacie' || widget.category == 'Livraison' || widget.category == 'Alimentaire' || widget.category == 'Boutique' || widget.category == 'Cosmétique' || widget.category == 'Marché';

  Widget _placeholder() => Container(width: 80, height: 80, color: Colors.green[100], child: Icon(Icons.photo_camera, color: Colors.green[700]));

  @override
  void dispose() {
    _commentController.dispose();
    _driverCommentController.dispose();
    _establishmentCommentController.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    final canUseCamera = !kIsWeb && defaultTargetPlatform != TargetPlatform.windows;
    final source = await showModalBottomSheet<picker.ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (canUseCamera)           if (canUseCamera) ListTile(leading: const Icon(Icons.camera_alt), title: const Text("Prendre une photo"), onTap: () => Navigator.pop(context, picker.ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library), title: const Text("Insérer une image depuis la galerie"), onTap: () => Navigator.pop(context, picker.ImageSource.gallery)),
        ]),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final ip = picker.ImagePicker();
      final xFile = await ip.pickImage(source: source);
      if (xFile != null && mounted) {
        setState(() => _packageImages.add(xFile.path));
      }
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_stars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Donnez une note globale"), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _submitting = true);
    await OrderService.setOrderRating(
      widget.orderId,
      _stars,
      _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      _driverStars > 0 ? _driverStars : null,
      _establishmentStars > 0 ? _establishmentStars : null,
      _driverCommentController.text.trim().isEmpty ? null : _driverCommentController.text.trim(),
      _establishmentCommentController.text.trim().isEmpty ? null : _establishmentCommentController.text.trim(),
      _liked,
      _packageImages.isEmpty ? null : _packageImages,
    );
    if (_tipXaf > 0) await OrderService.setOrderTip(widget.orderId, _tipXaf);
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Merci pour votre avis !"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Noter la course"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Note globale", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  icon: Icon(_stars >= star ? Icons.star : Icons.star_border, size: 40, color: Colors.amber),
                  onPressed: () => setState(() => _stars = star),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Votre avis / commentaire",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            if (widget.driverName != null) ...[
              const Text("Pourboire chauffeur/livreur (optionnel)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [0, 500, 1000, 2000, 5000].map((x) => ChoiceChip(
                  label: Text(x == 0 ? "Aucun" : "$x XAF"),
                  selected: _tipXaf == x,
                  onSelected: (v) => setState(() => _tipXaf = x),
                  selectedColor: Colors.green[100],
                )).toList(),
              ),
              const SizedBox(height: 24),
            ],
            const Text("Avez-vous aimé ?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(label: const Text("👍 Oui"), selected: _liked == true, onSelected: (v) => setState(() => _liked = true)),
                const SizedBox(width: 12),
                ChoiceChip(label: const Text("👎 Non"), selected: _liked == false, onSelected: (v) => setState(() => _liked = false)),
              ],
            ),
            if (widget.driverName != null) ...[
              const SizedBox(height: 24),
              Text("Noter le chauffeur/livreur : ${widget.driverName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return IconButton(
                    icon: Icon(_driverStars >= star ? Icons.star : Icons.star_border, size: 32, color: Colors.amber),
                    onPressed: () => setState(() => _driverStars = star),
                  );
                }),
              ),
              TextField(
                controller: _driverCommentController,
                maxLines: 2,
                decoration: InputDecoration(hintText: "Commentaire sur le chauffeur", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true),
              ),
            ],
            if (_isDelivery && widget.establishmentName != null) ...[
              const SizedBox(height: 24),
              Text("Noter l'établissement : ${widget.establishmentName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return IconButton(
                    icon: Icon(_establishmentStars >= star ? Icons.star : Icons.star_border, size: 32, color: Colors.amber),
                    onPressed: () => setState(() => _establishmentStars = star),
                  );
                }),
              ),
              TextField(
                controller: _establishmentCommentController,
                maxLines: 2,
                decoration: InputDecoration(hintText: "Commentaire sur l'établissement", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true),
              ),
            ],
            if (_isDelivery) ...[
              const SizedBox(height: 24),
              const Text("Prendre une photo / Insérer une ou des images de l'état du colis ou du produit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("(pharmaceutique, alimentaire ou autre)", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._packageImages.asMap().entries.map((e) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: File(e.value).existsSync()
                            ? Image.file(File(e.value), width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder())
                            : _placeholder(),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _packageImages.removeAt(e.key)),
                          child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  )),
                  GestureDetector(
                    onTap: _addImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _submitting ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("ENVOYER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
