import 'package:flutter/material.dart';

class SwipeWrapper extends StatelessWidget {
  const SwipeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guardas - Inicio')),
      body: const Center(child: Text('Bienvenido, Guarda')),
    );
  }
}
