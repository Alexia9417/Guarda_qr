import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:guardas_seguridad/models/qrusuario.dart';
import 'package:provider/provider.dart';
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

  Future<void> reproducirYDetener(
    AudioPlayer player,
    String assetPath,
    Duration duracion,
  ) async {
    await player.stop();
    await player.play(AssetSource(assetPath));
    Future.delayed(duracion, () async {
      await player.stop();
    });
  }

  Future<void> _validarQR() async {
    try {
      //print('📦 QR recibido (raw): ${widget.qrData}');
      //Se intenta decodificar directamente como JSON
      dynamic contenido = jsonDecode(widget.qrData);
      //Si es un string, se intenta decodificarlo nuevamente (por si es un JSON escapado)
      final Map<String, dynamic> jsonQR = (contenido is String)
          ? jsonDecode(contenido)
          : contenido;
      //print('✅ Contenido final: ${jsonQR['NombreCompleto']}');

      final usuarioQR = QRUsuario.fromJson(jsonQR);

      // Construcción del email
      String construirEmail(String id, String tipo) {
        final sufijo = tipo.toLowerCase() == 'estudiante'
            ? '@cuc.cr'
            : '@cuc.ac.cr';
        return '$id$sufijo';
      }

      final usuarioProvider = Provider.of<UsuarioProvider>(
        context,
        listen: false,
      );

      final email = construirEmail(
        usuarioQR.identificacion,
        usuarioQR.tipoUsuarioDescripcion,
      );

      await usuarioProvider.cargarPorId(email);

      if (usuarioProvider.error != null) {
        await reproducirYDetener(
          audioPlayer,
          'sonido_error.mp3',
          Duration(seconds: 3),
        );
        setState(() {
          esValido = false;
          mensaje = 'Error: ${usuarioProvider.error}';
        });
        return;
      }

      if (usuarioQR.fechaVencimiento == null ||
          usuarioQR.fechaVencimiento!.isBefore(DateTime.now())) {
        await reproducirYDetener(
          audioPlayer,
          'sonido_error.mp3',
          Duration(seconds: 3),
        );
        setState(() {
          esValido = false;
          mensaje = 'QR expirado';
        });
        return;
      }

      final usuarioBD = usuarioProvider.usuario;

      if (usuarioBD != null && usuarioQR.coincideCon(usuarioBD)) {
        await reproducirYDetener(
          audioPlayer,
          'sonido_success.wav',
          Duration(seconds: 5),
        );
        setState(() {
          esValido = true;
          mensaje = 'Usuario válido';
        });
      } else {
        await reproducirYDetener(
          audioPlayer,
          'sonido_error.mp3',
          Duration(seconds: 3),
        );
        setState(() {
          esValido = false;
          mensaje = 'Usuario inválido';
        });
      }
    } catch (e) {
      //print('❌ Error al procesar QR: $e');
      await reproducirYDetener(
        audioPlayer,
        'sonido_error.mp3',
        Duration(seconds: 3),
      );
      setState(() {
        esValido = false;
        mensaje = 'Error al procesar QR: ${e.toString()}';
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
      appBar: AppBar(
        title: const Text(
          'Validación QR',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kAzul,
      ),
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
