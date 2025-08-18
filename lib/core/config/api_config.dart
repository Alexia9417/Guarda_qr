import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _prod =
      'https://tiusr34pl.cuc-carrera-ti.ac.cr/ApiGateway/gateway';
  static const String _dev =
      'https://tiusr34pl.cuc-carrera-ti.ac.cr/ApiGateway/gateway';

  static String get baseUrl => kReleaseMode ? _prod : _dev;

  static const Map<String, Map<String, String>> services = {
    'Auth': {
      'Login': '/auth/login',
      'Validate': '/auth/validate',
      'Refresh': '/auth/refresh',
    },
    'Usuarios': {'ObtenerPorId': '/usuario/{id}'},
    'Fotografias': {'Obtener': '/usuario/foto/{id}'},
    'Qr': {'Generar': '/usuario/qr'},
    'TokenValidation': {'ValidateFull': '/auth/validate'},
  };

  static String buildPath(
    String service,
    String endpoint, {
    Map<String, String>? pathParams,
  }) {
    String? p = services[service]?[endpoint];
    if (p == null) {
      throw ArgumentError('Endpoint no definido: $service/$endpoint');
    }
    pathParams?.forEach((k, v) {
      p = p!.replaceAll('{$k}', Uri.encodeComponent(v));
    });
    return p!;
  }

  static Uri uri(
    String service,
    String endpoint, {
    Map<String, String>? pathParams,
    Map<String, String>? query,
  }) {
    final path = buildPath(service, endpoint, pathParams: pathParams);
    final u = Uri.parse('$baseUrl$path');
    return query == null ? u : u.replace(queryParameters: query);
  }
}
