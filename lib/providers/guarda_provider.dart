import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../models/guarda.dart';
import '../core/config/api_config.dart';

class GuardaProvider with ChangeNotifier {
  final String baseUrlGateway;
  final String token;
  final http.Client _http;
  Uint8List? _cacheFoto;

  GuardaProvider({
    required this.baseUrlGateway,
    required this.token,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  Guarda? _guarda;
  Guarda? get guarda => _guarda;

  Future<Uint8List?> descargarFotoPorEmail(String email) async {
    if (_cacheFoto != null) return _cacheFoto;

    final uri = ApiConfig.uri(
      'Fotografias',
      'Obtener',
      pathParams: {'id': email},
    );

    final r = await _http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (r.statusCode != 200) return null;

    final body = jsonDecode(utf8.decode(r.bodyBytes));
    final b64 = (body['imagen'] ?? '').toString().trim();
    if (b64.isEmpty) return null;

    try {
      _cacheFoto = base64Decode(b64);
      return _cacheFoto;
    } catch (_) {
      return null;
    }
  }

  Future<Guarda> fetchPerfilPorEmail(String email) async {
    final perfilUri = ApiConfig.uri(
      'Usuarios',
      'ObtenerPorId',
      pathParams: {'id': email},
    );

    final resp = await _http
        .get(
          perfilUri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 12));

    if (resp.statusCode == 200) {
      final raw = jsonDecode(utf8.decode(resp.bodyBytes));
      final map = (raw is Map && raw['data'] is Map) ? raw['data'] : raw;

      var g = Guarda.fromJson(map as Map<String, dynamic>);

      final fotoUri = ApiConfig.uri(
        'Fotografias',
        'Obtener',
        pathParams: {'id': email},
      ).toString();

      g = g.copyWith(fotografiaUrl: fotoUri);

      _guarda = g;
      notifyListeners();
      return _guarda!;
    }

    if (resp.statusCode == 401) {
      throw Exception('No autorizado');
    }

    throw Exception(
      'Error al cargar el perfil (${resp.statusCode}): ${resp.body}',
    );
  }

  Future<Guarda> fetchPerfilPorId(String id) {
    return fetchPerfilPorEmail(id);
  }

  void clear() {
    _guarda = null;
    notifyListeners();
  }
}
