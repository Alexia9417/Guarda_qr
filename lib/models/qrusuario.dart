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
      tipoUsuarioDescripcion: json['TipoUsuario'] ?? '',
      carreras: List<String>.from(json['Carreras'] ?? []),
      areas: List<String>.from(json['Areas'] ?? []),
      fechaVencimiento: DateTime.parse(json['FechaVencimiento']),
    );
    
  }
  
  bool coincideCon(Usuario otro) {
    final idCoincide =
        _normalizar(identificacion) == _normalizar(otro.identificacion);
    final tipoCoincide =
        _normalizar(tipoUsuarioDescripcion) == _normalizar(otro.tipoUsuario);
    final nombreCoincide =
        _normalizar(nombreCompleto) == _normalizar(otro.nombreCompleto);

    return idCoincide && tipoCoincide && nombreCoincide;
  }

  String _normalizar(String texto) {
    return texto
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[áÁ]'), 'a')
        .replaceAll(RegExp(r'[éÉ]'), 'e')
        .replaceAll(RegExp(r'[íÍ]'), 'i')
        .replaceAll(RegExp(r'[óÓ]'), 'o')
        .replaceAll(RegExp(r'[úÚ]'), 'u');
  }
}
