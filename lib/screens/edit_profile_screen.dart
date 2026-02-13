import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;

import '../main.dart';
import '../services/user_service.dart';
import '../services/address_service.dart';
import '../widgets/avatar_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _gender = 'homme';
  bool _verified = false;
  final List<String> _languages = [];
  static const _allLanguages = ['FR', 'EN', 'Lingala', 'Kituba'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _nameController.text = await UserService.getUserName();
    _phoneController.text = await UserService.getUserPhone();
    _gender = await UserService.getUserGender();
    _verified = await AddressService.isVerified();
    final langs = await UserService.getUserLanguages();
    _languages.clear();
    _languages.addAll(langs);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(picker.ImageSource source) async {
    try {
      final ip = picker.ImagePicker();
      final xFile = await ip.pickImage(source: source);
      if (xFile != null) {
        await profileService.savePhotoFromPath(xFile.path);
        if (mounted) setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Photo mise à jour"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString().split('\n').first}"), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _save() async {
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\s'), '');
    final validPhone = phone.isNotEmpty ? (phone.startsWith('+') ? phone : '+242 $phone') : '+242 06 444 22 11';
    await UserService.saveUser(
      name: _nameController.text.isNotEmpty ? _nameController.text : 'Utilisateur Yadeli',
      phone: validPhone,
      gender: _gender,
      languages: _languages.isEmpty ? ['FR'] : _languages,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil enregistré"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier le profil"), backgroundColor: Colors.green[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ListenableBuilder(
              listenable: profileService,
              builder: (_, __) => GestureDetector(
                onTap: _showPhotoOptions,
                child: Stack(
                  children: [
                    AvatarWidget(photoPath: profileService.photoPath, gender: _gender, radius: 50),
                    Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, size: 20, color: Colors.white))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Nom", prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Téléphone", prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            const Align(alignment: Alignment.centerLeft, child: Text("Genre", style: TextStyle(fontWeight: FontWeight.w500))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: RadioListTile<String>(title: const Text("Homme"), value: 'homme', groupValue: _gender, onChanged: (v) => setState(() => _gender = v!), activeColor: Colors.green[700])),
                Expanded(child: RadioListTile<String>(title: const Text("Femme"), value: 'femme', groupValue: _gender, onChanged: (v) => setState(() => _gender = v!), activeColor: Colors.green[700])),
              ],
            ),
            const SizedBox(height: 16),
            const Align(alignment: Alignment.centerLeft, child: Text("Langues parlées (pour faciliter l'échange)", style: TextStyle(fontWeight: FontWeight.w500))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _allLanguages.map((lang) => FilterChip(
                label: Text(lang),
                selected: _languages.contains(lang),
                onSelected: (v) {
                  setState(() {
                    if (v) _languages.add(lang);
                    else _languages.remove(lang);
                  });
                },
                selectedColor: Colors.green[100],
              )).toList(),
            ),
            const SizedBox(height: 16),
            if (_verified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green)),
                child: Row(children: [Icon(Icons.verified, color: Colors.green[700]), const SizedBox(width: 12), const Text("Profil vérifié", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]),
              )
            else
              OutlinedButton.icon(
                onPressed: () => _showVerifyPhoneDialog(),
                icon: const Icon(Icons.verified_user, size: 18),
                label: const Text("Vérifier le numéro de téléphone"),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Enregistrer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerifyPhoneDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Vérification du numéro"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Un code sera envoyé au ${_phoneController.text.isEmpty ? '+242 ...' : _phoneController.text}"),
            const SizedBox(height: 16),
            const Text("Code de démo : 123456"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              await AddressService.setVerified(true);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Numéro vérifié ! Profil vérifié ✓"), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
              setState(() => _verified = true);
            },
            child: const Text("Vérifier"),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions() {
    final canUseCamera = !kIsWeb && defaultTargetPlatform != TargetPlatform.windows;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (canUseCamera) ListTile(leading: const Icon(Icons.camera_alt), title: const Text("Prendre une photo"), onTap: () { Navigator.pop(context); _pickPhoto(picker.ImageSource.camera); }),
          ListTile(leading: const Icon(Icons.photo_library), title: const Text("Choisir une photo"), onTap: () { Navigator.pop(context); _pickPhoto(picker.ImageSource.gallery); }),
        ]),
      ),
    );
  }
}
