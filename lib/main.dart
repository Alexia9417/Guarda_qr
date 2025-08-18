import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/secure_storage.dart';
import 'providers/auth_provider.dart';
import 'providers/usuario_provider.dart';
import 'screens/login_guardas.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = SecureStorage();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(storage)),
        ChangeNotifierProvider(create: (_) => UsuarioProvider(storage)),
      ],
      child: const MaterialApp(
        title: 'App de Guardas CUC',
        debugShowCheckedModeBanner: false,
        home: Login(),
      ),
    );
  }
}
