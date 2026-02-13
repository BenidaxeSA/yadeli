import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Drapeau du Congo : triangle vert (haut-gauche), bande jaune diagonale, triangle rouge (bas-droite)
/// Diagonale du coin bas-gauche vers haut-droite
class CongoFlag extends StatelessWidget {
  final double width;
  final double height;

  const CongoFlag({super.key, this.width = 36, this.height = 24});

  static const green = Color(0xFF008E43);
  static const yellow = Color(0xFFFBDE00);
  static const red = Color(0xFFDC241F);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CustomPaint(
          painter: _CongoFlagPainter(),
          size: Size(width, height),
        ),
      ),
    );
  }
}

class _CongoFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Diagonale : (0,h) -> (w,0)
    // Bande jaune : épaisseur ~18% de la diagonale
    final diagLen = math.sqrt(w * w + h * h);
    final bandHalf = diagLen * 0.09;

    final p1 = Offset(0, h);
    final p2 = Offset(w, 0);
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 0.001) return;
    final ux = dx / len;
    final uy = dy / len;
    final perpX = -uy;
    final perpY = ux;

    // Points sur les bords de la bande jaune (vers l'intérieur)
    final bi1 = Offset(p1.dx + perpX * bandHalf, p1.dy + perpY * bandHalf);
    final bi2 = Offset(p2.dx + perpX * bandHalf, p2.dy + perpY * bandHalf);
    final bo1 = Offset(p1.dx - perpX * bandHalf, p1.dy - perpY * bandHalf);
    final bo2 = Offset(p2.dx - perpX * bandHalf, p2.dy - perpY * bandHalf);

    // Vert : triangle haut-gauche (sommets 0,0, w,0, 0,h)
    final greenPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(bo2.dx, bo2.dy)
      ..lineTo(bo1.dx, bo1.dy)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(greenPath, Paint()..color = CongoFlag.green);

    // Rouge : triangle bas-droite (sommet w,h), bordure = diagonale + droite + bas
    final redPath = Path()
      ..moveTo(0, h)
      ..lineTo(bo1.dx, bo1.dy)
      ..lineTo(bo2.dx, bo2.dy)
      ..lineTo(w, 0)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(redPath, Paint()..color = CongoFlag.red);

    // Jaune : bande diagonale (parallélogramme)
    final yellowPath = Path()
      ..moveTo(bo1.dx, bo1.dy)
      ..lineTo(bo2.dx, bo2.dy)
      ..lineTo(bi2.dx, bi2.dy)
      ..lineTo(bi1.dx, bi1.dy)
      ..close();
    canvas.drawPath(yellowPath, Paint()..color = CongoFlag.yellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
