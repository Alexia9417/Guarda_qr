import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import '../models/qrusuario.dart';
import '../providers/usuario_provider.dart';

const kAzul = Color(0xFF003466);

class QrvalidacionGuarda extends StatefulWidget {
  final String qrData;

  const QrvalidacionGuarda({super.key, required this.qrData});

  @override
  State<QrvalidacionGuarda> createState() => _QrvalidacionGuardaState();
}

class _QrvalidacionGuardaState extends State<QrvalidacionGuarda> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool? esValido;
  String mensaje = 'Validando...';

  @override
  void initState() {
    super.initState();
    _validarQR();
  }

  Future<void> _validarQR() async {
    try {
      final Map<String, dynamic> jsonQR = jsonDecode(widget.qrData);
      final usuarioQR = QRUsuario.fromJson(jsonQR);

      final usuarioProvider = Provider.of<UsuarioProvider>(
        context,
        listen: false,
      );
      await usuarioProvider.cargarPorId(usuarioQR.identificacion);

      // Verificar si hubo error al cargar el usuario
      if (usuarioProvider.error != null) {
        await audioPlayer.play(AssetSource('sonido_error.mp3'));
        setState(() {
          esValido = false;
          mensaje = '⚠️ ${usuarioProvider.error}';
        });
        return;
      }

      // Verificar fecha de vencimiento
      if (usuarioQR.fechaVencimiento.isBefore(DateTime.now())) {
        await audioPlayer.play(AssetSource('sonido_error.mp3'));
        setState(() {
          esValido = false;
          mensaje = '⚠️ QR expirado';
        });
        return;
      }
      // Validar coincidencia con el usuario cargado
      final usuarioBD = usuarioProvider.usuario;

      // Si no hay usuario cargado, mostrar error
      if (usuarioBD != null && usuarioQR.coincideCon(usuarioBD)) {
        await audioPlayer.play(AssetSource('lib/assets/sonido_success.wav'));
        setState(() {
          esValido = true;
          mensaje = '✅ Usuario válido';
        });
      } else {
        await audioPlayer.play(AssetSource('lib/assets/sonido_error.mp3'));
        setState(() {
          esValido = false;
          mensaje = '❌ Usuario inválido';
        });
      }
    } catch (e) {
      await audioPlayer.play(AssetSource('lib/assets/sonido_error.mp3'));
      setState(() {
        esValido = false;
        mensaje = '⚠️ Error al procesar QR';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color fondo = esValido == null
        ? Colors.grey.shade300
        : esValido!
        ? Colors.green.shade100
        : Colors.red.shade100;

    final Color borde = esValido == null
        ? Colors.grey
        : esValido!
        ? Colors.green.shade700
        : Colors.red.shade700;

    return Scaffold(
      backgroundColor: kAzul,
      appBar: AppBar(title: const Text('Validación QR',style: TextStyle(color: Colors.white))),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: fondo,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: fondo,
              border: Border.all(color: borde, width: 4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              mensaje,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: borde,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
