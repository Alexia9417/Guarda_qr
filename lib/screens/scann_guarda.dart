import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:guardas_seguridad/providers/qrvalidacion_guarda.dart';

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
      //Se intenta decodificar directamente como JSON
      dynamic contenido = jsonDecode(raw);
      //Si es un Map, se convierte a string para pasarlo a la siguiente pantalla
      String qrData = (contenido is Map) ? jsonEncode(contenido) : raw;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QrvalidacionGuarda(qrData: qrData),
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
      // 2. Si falla, intenta decodificar como UTF-8
      try {
        final utf8Fixed = utf8.decode(raw.runes.toList());
        dynamic contenido = jsonDecode(utf8Fixed);
        String qrData = (contenido is Map) ? jsonEncode(contenido) : utf8Fixed;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrvalidacionGuarda(qrData: qrData),
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
          setState(() => _isProcessing = false);
        }
      }
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

          // Cuadro guía con borde
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
