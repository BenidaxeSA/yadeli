import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;

/// Section professionnel : signaler un comportement déplacé d'un client (avec preuve)
class ReportClientScreen extends StatefulWidget {
  final String? orderId;
  final String? clientName;

  const ReportClientScreen({super.key, this.orderId, this.clientName});

  @override
  State<ReportClientScreen> createState() => _ReportClientScreenState();
}

class _ReportClientScreenState extends State<ReportClientScreen> {
  final _commentController = TextEditingController();
  final List<String> _images = [];
  String? _videoPath;
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    final canUseCamera = !kIsWeb && defaultTargetPlatform != TargetPlatform.windows;
    final source = await showModalBottomSheet<picker.ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (canUseCamera) ListTile(leading: const Icon(Icons.camera_alt), title: const Text("Prendre une photo"), onTap: () => Navigator.pop(context, picker.ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library), title: const Text("Insérer une image"), onTap: () => Navigator.pop(context, picker.ImageSource.gallery)),
        ]),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final ip = picker.ImagePicker();
      final xFile = await ip.pickImage(source: source);
      if (xFile != null && mounted) setState(() => _images.add(xFile.path));
    } catch (_) {}
  }

  Future<void> _addVideo() async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) return;
    try {
      final ip = picker.ImagePicker();
      final xFile = await ip.pickVideo(source: picker.ImageSource.camera);
      if (xFile != null && mounted) setState(() => _videoPath = xFile.path);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_commentController.text.trim().isEmpty && _images.isEmpty && _videoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Décrivez le problème ou ajoutez une preuve (vidéo, audio, image)"), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signalement envoyé. L'équipe Yadeli examinera."), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signaler un client"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: const Text("Section professionnel Yadeli : signalez un comportement déplacé ou grave d'un client avec preuve à l'appui.", style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 20),
            if (widget.clientName != null) Text("Client : ${widget.clientName}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Description du comportement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Décrivez le comportement déplacé ou grave...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            const Text("Preuves (vidéo, audio, images)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._images.asMap().entries.map((e) => Stack(
                  children: [
                    Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8)), child: Icon(Icons.image, color: Colors.orange[700])),
                    Positioned(top: 2, right: 2, child: GestureDetector(onTap: () => setState(() => _images.removeAt(e.key)), child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 12, color: Colors.white)))),
                  ],
                )),
                if (_videoPath != null)
                  Stack(
                    children: [
                      Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8)), child: Icon(Icons.videocam, color: Colors.orange[700])),
                      Positioned(top: 2, right: 2, child: GestureDetector(onTap: () => setState(() => _videoPath = null), child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 12, color: Colors.white)))),
                    ],
                  ),
                GestureDetector(onTap: _addImage, child: Container(width: 70, height: 70, decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_a_photo, size: 28, color: Colors.grey))),
                if (!kIsWeb && defaultTargetPlatform != TargetPlatform.windows)
                  GestureDetector(onTap: _addVideo, child: Container(width: 70, height: 70, decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.videocam, size: 28, color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _submitting ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("ENVOYER LE SIGNALEMENT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
