import 'dart:convert';
import 'package:guardas_seguridad/providers/qrvalidacion_guarda.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

const kAzul = Color(0xFF003466);

class ScannGuarda extends StatefulWidget {
  const ScannGuarda({super.key});

  @override
  State<ScannGuarda> createState() => _ScannGuardaState();
}

class _ScannGuardaState extends State<ScannGuarda> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcode = capture.barcodes.first;
    final String? raw = barcode.rawValue;

    if (raw != null) {
      setState(() => _isProcessing = true);

      try {
        jsonDecode(raw); // Validar que sea JSON válido
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ QR inválido. No contiene datos en formato esperado.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QrvalidacionGuarda(qrData: raw),
        ),
      ).then((_) {
        Future.delayed(const Duration(seconds: 1), () {
          setState(() => _isProcessing = false);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escáner QR')),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),

          // Cuadro guía con solo el borde
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: CustomPaint(painter: _BorderPainter(color: kAzul)),
            ),
          ),

          // Texto guía
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kAzul,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Coloca el QR dentro del recuadro',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),

          // Animación de línea escaneando
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 125,
            left: MediaQuery.of(context).size.width / 2 - 125,
            child: SizedBox(
              width: 250,
              height: 250,
              child: _ScanLineAnimation(color: kAzul),
            ),
          ),
        ],
      ),
    );
  }
}

class _BorderPainter extends CustomPainter {
  final Color color;
  _BorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanLineAnimation extends StatefulWidget {
  final Color color;
  const _ScanLineAnimation({required this.color});

  @override
  State<_ScanLineAnimation> createState() => _ScanLineAnimationState();
}

class _ScanLineAnimationState extends State<_ScanLineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 250).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Positioned(
        top: _animation.value,
        child: Container(width: 250, height: 2, color: widget.color),
      ),
    );
  }
}
