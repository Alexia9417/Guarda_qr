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
        // ✅ Forzar decodificación UTF-8 para caracteres especiales
        final utf8Fixed = utf8.decode(raw.codeUnits);

        // Validar que sea JSON válido
        jsonDecode(utf8Fixed);

        // Navegar con el string corregido
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrvalidacionGuarda(qrData: utf8Fixed),
          ),
        ).then((_) {
          if (mounted) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() => _isProcessing = false);
              }
            });
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR inválido o con caracteres corruptos.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAzul,
      appBar: AppBar(
        title: const Text('Escáner QR', style: TextStyle(color: Colors.white)),
        backgroundColor: kAzul,
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
