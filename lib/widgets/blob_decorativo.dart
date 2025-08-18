import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class BlobDecorativo extends StatelessWidget {
  const BlobDecorativo({super.key});
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BlobDecorativoClipper(),
      child: Container(height: 80, color: AppColors.rojo),
    );
  }
}

class _BlobDecorativoClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.moveTo(0, size.height * 0.10);
    p.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.1,
      size.width * 0.4,
      size.height * 0.3,
    );
    p.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.6,
      size.width,
      size.height * 0.4,
    );
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
