import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;

/// Signaler : comportement déplacé, insécurité, vol, oubli, discrimination (tribalisme, colorisme, sexisme...)
class ReportScreen extends StatefulWidget {
  final String orderId;

  const ReportScreen({super.key, required this.orderId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? _reportType;
  final _commentController = TextEditingController();
  final List<String> _images = [];
  String? _videoPath;
  bool _submitting = false;

  static const _types = [
    _ReportType('comportement', 'Comportement déplacé'),
    _ReportType('insecurite', 'Insécurité'),
    _ReportType('vol', 'Vol / Oubli (colis, affaires, enfants...)'),
    _ReportType('discrimination', 'Discrimination (tribalisme, colorisme, sexisme, religion)'),
    _ReportType('grave', 'Propos graves (violence, insultes, corruption...)'),
    _ReportType('autre', 'Autre'),
  ];

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Décrivez le problème ou ajoutez une preuve"), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signalement envoyé. L'équipe Yadeli va examiner."), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signaler un comportement"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Type de signalement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _reportType,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true),
              hint: const Text("Sélectionnez"),
              items: _types.map((t) => DropdownMenuItem(value: t.id, child: Text(t.label))).toList(),
              onChanged: (v) => setState(() => _reportType = v),
            ),
            const SizedBox(height: 16),
            const Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Décrivez ce qui s'est passé. Pour signaler à la police : utilisez le bouton rouge sur l'écran de course.",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 20),
            const Text("Preuves (image ou vidéo)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._images.asMap().entries.map((e) => Stack(
                  children: [
                    Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8)), child: Icon(Icons.image, color: Colors.orange[700])),
                    Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => setState(() => _images.removeAt(e.key)), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)))),
                  ],
                )),
                if (_videoPath != null)
                  Stack(
                    children: [
                      Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(8)), child: Icon(Icons.videocam, color: Colors.orange[700])),
                      Positioned(top: 4, right: 4, child: GestureDetector(onTap: () => setState(() => _videoPath = null), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)))),
                    ],
                  ),
                GestureDetector(
                  onTap: _addImage,
                  child: Container(width: 80, height: 80, decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add_a_photo, size: 32, color: Colors.grey)),
                ),
                if (!kIsWeb && defaultTargetPlatform != TargetPlatform.windows)
                  GestureDetector(
                    onTap: _addVideo,
                    child: Container(width: 80, height: 80, decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.videocam, size: 32, color: Colors.grey)),
                  ),
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

class _ReportType {
  final String id;
  final String label;
  const _ReportType(this.id, this.label);
}
