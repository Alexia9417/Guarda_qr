import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../core/theme/colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/blob_decorativo.dart';
import '../providers/auth_provider.dart';
import '../providers/usuario_provider.dart';

import '../providers/guarda_provider.dart';
import '../screens/guarda_home.dart';

import '../core/config/api_config.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final pass = passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese correo y contraseña')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(email, pass);

    if (!ok) {
      final msg = auth.error ?? 'Usuario y/o contraseña incorrectos.';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    final token = auth.token;
    final usuarioId = auth.usuarioId?.toString();

    final tipo = (auth.tipoUsuario ?? '').toLowerCase();

    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se recibió token válido del servidor'),
        ),
      );
      return;
    }

    if (usuarioId == null || usuarioId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo determinar el identificador del usuario'),
        ),
      );
      return;
    }

    // Validación flexible para "Guarda de seguridad"
    // Adecúa a lo que devuelve tu backend (código 'GS', descripción 'Guarda', etc.)
    final esGuarda =
        tipo == 'guarda' ||
        tipo == 'guardia' ||
        tipo == 'security' ||
        tipo == 'gs' ||
        tipo == 'gu';
    if (!esGuarda) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solo los guardas de seguridad pueden ingresar a esta aplicación.',
          ),
        ),
      );
      return;
    }

    // Cargar perfil básico a través de tu UsuarioProvider (opcional si lo necesitas en cache)
    final usuarioProv = context.read<UsuarioProvider>();
    await usuarioProv.cargarPorId(usuarioId).catchError((_) {});

    if (!mounted) return;

    // Navegar a la pantalla del guarda, inyectando GuardaProvider con ApiConfig.baseUrl
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) =>
              GuardaProvider(baseUrlGateway: ApiConfig.baseUrl, token: token),
          child: GuardaHome(guardaId: usuarioId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final loading = context.watch<AuthProvider>().loading;

    final hasText =
        emailController.text.trim().isNotEmpty &&
        passwordController.text.isNotEmpty;

    return ModalProgressHUD(
      inAsyncCall: loading,
      opacity: 0.15,
      progressIndicator: const CircularProgressIndicator.adaptive(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.azul,
        body: Stack(
          children: [
            const Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(child: AppLogo()),
            ),
            Positioned(
              top: size.height * 0.27,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _inputBox(
                      controller: emailController,
                      label: 'Correo electrónico',
                      icon: Icons.email,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    _inputBox(
                      controller: passwordController,
                      label: 'Contraseña',
                      icon: Icons.lock,
                      obscure: true,
                      obscureValue: _obscure,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: (!loading && hasText) ? _onLogin : null,
                        child: const Text(
                          'Ingresar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BlobDecorativo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputBox({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool? obscureValue,
    VoidCallback? onToggleObscure,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscure ? (obscureValue ?? true) : false,
      style: const TextStyle(color: AppColors.azul),
      cursorColor: AppColors.azul,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.azul),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  (obscureValue ?? true)
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppColors.azul,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
      keyboardType: icon == Icons.email
          ? TextInputType.emailAddress
          : TextInputType.text,
      textInputAction: icon == Icons.email
          ? TextInputAction.next
          : TextInputAction.done,
      onSubmitted: (_) {
        if (icon == Icons.lock) _onLogin();
      },
    );
  }
}
