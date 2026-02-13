import 'dart:io';
import 'package:flutter/material.dart';

/// Avatar avec photo (asset ou fichier) ou défaut selon le genre (homme/femme)
class AvatarWidget extends StatelessWidget {
  final String? photoPath;
  final String gender;
  final double radius;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    this.photoPath,
    this.gender = 'homme',
    this.radius = 28,
    this.onTap,
  });

  Color get _defaultColor => gender == 'femme' ? Colors.pink : Colors.blue;

  bool get _hasValidPhoto {
    if (photoPath == null || photoPath!.isEmpty) return false;
    if (photoPath!.startsWith('assets/')) return true;
    try {
      return File(photoPath!).existsSync();
    } catch (_) {
      return false;
    }
  }

  ImageProvider? get _imageProvider {
    if (!_hasValidPhoto) return null;
    if (photoPath!.startsWith('assets/')) {
      return AssetImage(photoPath!);
    }
    return FileImage(File(photoPath!));
  }

  @override
  Widget build(BuildContext context) {
    final child = CircleAvatar(
      radius: radius,
      backgroundColor: _hasValidPhoto ? Colors.transparent : _defaultColor.withOpacity(0.2),
      backgroundImage: _imageProvider,
      child: !_hasValidPhoto
          ? Icon(Icons.person, color: _defaultColor, size: radius * 1.2)
          : null,
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: child);
    }
    return child;
  }
}
