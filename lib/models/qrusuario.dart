import 'package:diacritic/diacritic.dart';
import 'package:guardas_seguridad/models/usuario.dart';

class QRUsuario {
  final String nombreCompleto;
  final String identificacion;
  final String tipoUsuarioDescripcion;
  final List<String> carreras;
  final List<String> areas;
  final DateTime? fechaVencimiento;

  QRUsuario({
    required this.nombreCompleto,
    required this.identificacion,
    required this.tipoUsuarioDescripcion,
    required this.carreras,
    required this.areas,
    required this.fechaVencimiento,
  });

  /// Construir desde JSON
  factory QRUsuario.fromJson(Map<String, dynamic> json) {
    return QRUsuario(
      nombreCompleto: json['NombreCompleto'] ?? '',
      identificacion: json['Identificacion'] ?? '',
      tipoUsuarioDescripcion: json['TipoUsuario'] ?? json['tipoUsuario'] ?? '',
      carreras: List<String>.from(json['Carreras'] ?? []),
      areas: List<String>.from(json['Areas'] ?? []),
      fechaVencimiento:
          (json['FechaVencimiento'] != null &&
              json['FechaVencimiento'].toString().isNotEmpty)
          ? DateTime.tryParse(json['FechaVencimiento'])
          : null,
    );
  }

  /// Serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'NombreCompleto': nombreCompleto,
      'Identificacion': identificacion,
      'TipoUsuario': tipoUsuarioDescripcion,
      'Carreras': carreras,
      'Areas': areas,
      'FechaVencimiento': fechaVencimiento?.toIso8601String(),
    };
  }

  /// Versión del objeto con todos los textos normalizados
  QRUsuario normalizado() {
    return QRUsuario(
      nombreCompleto: _normalizar(nombreCompleto),
      identificacion: _normalizar(identificacion),
      tipoUsuarioDescripcion: _normalizar(tipoUsuarioDescripcion),
      carreras: _normalizarLista(carreras),
      areas: _normalizarLista(areas),
      fechaVencimiento: fechaVencimiento,
    );
  }

  /// Comparación con otro usuario (ignorando mayúsculas/tildes/espacios)
  bool coincideCon(Usuario otro) {
    final qrNorm = normalizado();

    return qrNorm.identificacion == _normalizar(otro.identificacion) &&
        qrNorm.tipoUsuarioDescripcion == _normalizar(otro.tipoUsuario) &&
        qrNorm.nombreCompleto == _normalizar(otro.nombreCompleto);
  }

  /// Normaliza un texto: quita tildes, ñ → n, lowercase, espacios simples
  String _normalizar(String texto) {
    return removeDiacritics(
      texto,
    ).trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Normaliza listas completas
  List<String> _normalizarLista(List<String> lista) {
    return lista.map((e) => _normalizar(e)).toList();
  }
}
