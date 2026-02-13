import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _profilePhotoKey = 'yadeli_profile_photo_path';

class ProfileService extends ChangeNotifier {
  String? _photoPath;

  String? get photoPath => _photoPath;

  static final ProfileService _instance = ProfileService._();
  factory ProfileService() => _instance;

  ProfileService._() {
    _loadPhotoPath(); // Charge de façon asynchrone
  }

  Future<void> _loadPhotoPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_profilePhotoKey);
      if (stored != null) {
        final dir = await getApplicationDocumentsDirectory();
        final fullPath = '${dir.path}/$stored';
        if (File(fullPath).existsSync()) {
          _photoPath = fullPath;
        } else {
          await prefs.remove(_profilePhotoKey);
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> savePhotoFromPath(String sourcePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      const filename = 'profile_photo.jpg';
      final destPath = '${dir.path}/$filename';
      await File(sourcePath).copy(destPath);
      _photoPath = destPath;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profilePhotoKey, filename);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> clearPhoto() async {
    _photoPath = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profilePhotoKey);
    notifyListeners();
  }
}
