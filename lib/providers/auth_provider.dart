import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._storage);

  final SecureStorage _storage;

  bool loading = false;
  String? error;

  String? accessToken;
  String? refreshToken;

  String? usuarioId;
  String? tipoUsuario;

  String? get token => accessToken;

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final uri = ApiConfig.uri('Auth', 'Login');
      final headers = <String, String>{
        'Accept': 'application/json',
        'email': email.trim(),
        'password': password,
        'tipo_usuario': 'GuardasFE',
      };

      final res = await http.post(uri, headers: headers);
      final bodyText = utf8.decode(res.bodyBytes);

      dynamic decoded;
      try {
        decoded = jsonDecode(bodyText);
      } catch (_) {
        decoded = null;
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Toma valores con varios nombres posibles (backend puede variar)
        accessToken =
            decoded?['access_token']?.toString() ??
            decoded?['token']?.toString();

        refreshToken = decoded?['refresh_token']?.toString();

        usuarioId =
            decoded?['usuarioID']?.toString() ??
            decoded?['usuarioId']?.toString() ??
            decoded?['id']?.toString() ??
            decoded?['email']?.toString() ??
            email;

        final t =
            decoded?['tipoUsuario'] ??
            decoded?['TipoUsuario'] ??
            decoded?['rol'] ??
            decoded?['role'];
        tipoUsuario = t?.toString().toLowerCase() ?? 'guarda';

        if ((accessToken ?? '').isEmpty) {
          error = 'No se recibió access_token.';
          return false;
        }

        await _storage.saveToken(accessToken!);
        notifyListeners();
        return true;
      }
      error =
          (decoded is Map
              ? (decoded['mensaje'] ?? decoded['message'])?.toString()
              : null) ??
          'HTTP ${res.statusCode}: $bodyText';
      return false;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    accessToken = null;
    refreshToken = null;
    usuarioId = null;
    tipoUsuario = null;
    await _storage.clear();
    notifyListeners();
  }
}
