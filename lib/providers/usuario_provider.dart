import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/http_helper.dart';
import '../core/config/api_config.dart';
import '../core/secure_storage.dart';
import '../models/usuario.dart';

class UsuarioProvider extends ChangeNotifier {
  UsuarioProvider(SecureStorage storage) : _http = HttpHelper(storage);
  final HttpHelper _http;

  Usuario? usuario;
  bool loading = false;
  String? error;

  Future<void> cargarPorClave(String clave) async {
    await cargarPorId(clave);
  }

  Future<void> cargarPorId(String idOEmail) async {
    final uri = ApiConfig.uri(
      'Usuarios',
      'ObtenerPorId',
      pathParams: {'id': idOEmail},
    );
    await _cargarGenerico(uri);
  }

  Future<void> _cargarGenerico(Uri uri) async {
    loading = true;
    error = null;
    Future.microtask(() => notifyListeners());
    try {
      final res = await _http.get(uri);
      final bodyText = utf8.decode(res.bodyBytes);

      dynamic decoded;
      try {
        decoded = jsonDecode(bodyText);
      } catch (_) {
        throw Exception('Respuesta no es JSON válido');
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        final map = (decoded is Map && decoded['data'] is Map)
            ? Map<String, dynamic>.from(decoded['data'] as Map)
            : Map<String, dynamic>.from(decoded as Map);
        usuario = Usuario.fromJson(map);
      } else if (res.statusCode == 401) {
        error =
            _extraerMensaje(decoded) ?? 'No autorizado (401). Revisa el token.';
      } else if (res.statusCode == 404) {
        error = _extraerMensaje(decoded) ?? 'Usuario no encontrado.';
      } else {
        error =
            _extraerMensaje(decoded) ?? 'Error ${res.statusCode}: $bodyText';
      }
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  String? _extraerMensaje(dynamic d) {
    if (d is Map) {
      for (final k in [
        'mensaje',
        'message',
        'error',
        'detail',
        'titulo',
        'descripcion',
      ]) {
        final v = d[k]?.toString();
        if (v != null && v.isNotEmpty) return v;
      }
    }
    return null;
  }
}
