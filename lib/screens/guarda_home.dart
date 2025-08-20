import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:guardas_seguridad/screens/scann_guarda.dart';
import 'package:provider/provider.dart';
import '../providers/guarda_provider.dart';
import '../providers/auth_provider.dart';

const kAzul = Color(0xFF0A2F5C);
const kRojo = Color(0xFFFF3333);

class GuardaHome extends StatefulWidget {
  final String guardaId;
  const GuardaHome({super.key, required this.guardaId});

  @override
  State<GuardaHome> createState() => _GuardaHomeState();
}

class _GuardaHomeState extends State<GuardaHome> {
  late Future<void> _load;

  @override
  void initState() {
    super.initState();
    _load = context.read<GuardaProvider>().fetchPerfilPorEmail(widget.guardaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAzul,
      appBar: AppBar(
        backgroundColor: kAzul,
        elevation: 0,
        title: const Text('Mi perfil', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            tooltip: 'Abrir cámara (escáner QR)',
            icon: const Icon(Icons.photo_camera, color: Colors.white),
            onPressed: () async {
              final prov = context.read<GuardaProvider>();
              final bytes = await prov.descargarFotoPorEmail(widget.guardaId);

              if (bytes == null || bytes.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No puede usar la app hasta registrar su fotografía.',
                      ),
                    ),
                  );
                }
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannGuarda()),
              );
            },
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _load,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Text(
                  'Error: ${snap.error}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final prov = context.read<GuardaProvider>();
            final guarda = context.watch<GuardaProvider>().guarda!;

            Widget avatar = FutureBuilder<Uint8List?>(
              future: prov.descargarFotoPorEmail(guarda.id),
              builder: (_, s) {
                final hasBytes = s.hasData && (s.data?.isNotEmpty ?? false);
                final img = hasBytes
                    ? MemoryImage(s.data!)
                    : const AssetImage('assets/persona.png') as ImageProvider;
                return CircleAvatar(radius: 50, backgroundImage: img);
              },
            );

            Widget infoCard(IconData icono, String texto) => Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kAzul, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(icono, color: kRojo),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(texto, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            );

            String prettyTipo(String raw) {
              final t = raw.trim().toLowerCase();
              if ([
                'gs',
                'gu',
                'guarda',
                'guardia',
                'security',
                'guarda de seguridad',
              ].contains(t))
                return 'Guarda de seguridad';
              return raw;
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: kAzul, width: 2),
                        ),
                        child: Column(
                          children: [
                            avatar,
                            const SizedBox(height: 12),
                            Text(
                              guarda.nombreCompleto.isNotEmpty
                                  ? guarda.nombreCompleto
                                  : '—',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      infoCard(
                        Icons.badge,
                        "Identificación: ${guarda.identificacion}",
                      ),
                      infoCard(
                        Icons.security,
                        "Tipo de usuario: ${prettyTipo(guarda.tipoUsuario)}",
                      ),

                      // Mensaje si NO hay foto
                      FutureBuilder<Uint8List?>(
                        future: prov.descargarFotoPorEmail(guarda.id),
                        builder: (_, s) {
                          final hasBytes =
                              s.hasData && (s.data?.isNotEmpty ?? false);
                          if (hasBytes) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: kRojo.withOpacity(0.1),
                              border: Border.all(color: kRojo, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: kRojo),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "No se validará el uso de esta aplicación hasta que haya registrado su fotografía.",
                                    style: TextStyle(
                                      color: kRojo,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
