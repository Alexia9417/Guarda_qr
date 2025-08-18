import 'package:guardas_seguridad/models/usuario.dart';

class QRUsuario {
  final String nombreCompleto;
  final String identificacion;
  final String tipoUsuarioDescripcion;
  final List<String> carreras;
  final List<String> areas;
  final DateTime fechaVencimiento;

  QRUsuario({
    required this.nombreCompleto,
    required this.identificacion,
    required this.tipoUsuarioDescripcion,
    required this.carreras,
    required this.areas,
    required this.fechaVencimiento,
  });

  factory QRUsuario.fromJson(Map<String, dynamic> json) {
    return QRUsuario(
      nombreCompleto: json['NombreCompleto'] ?? '',
      identificacion: json['Identificacion'] ?? '',
      tipoUsuarioDescripcion: json['TipoUsuarioDescripcion'] ?? '',
      carreras: List<String>.from(json['Carreras'] ?? []),
      areas: List<String>.from(json['Areas'] ?? []),
      fechaVencimiento: DateTime.parse(json['FechaVencimiento']),
    );
  }

  bool coincideCon(Usuario otro) {
    return identificacion == otro.identificacion &&
        tipoUsuarioDescripcion.toLowerCase() == otro.tipoUsuario.toLowerCase() &&
        nombreCompleto.trim().toLowerCase() == otro.nombreCompleto.trim().toLowerCase();
  }
}