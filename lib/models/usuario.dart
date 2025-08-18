class Usuario {
  final String nombreCompleto;
  final String identificacion;
  final String tipoUsuario;
  final String? fotografiaUrl;

  Usuario({
    required this.nombreCompleto,
    required this.identificacion,
    required this.tipoUsuario,
    this.fotografiaUrl,
  });

  factory Usuario.fromJson(Map<String, dynamic> j) {
    String _str(dynamic v) => v?.toString() ?? '';
    // Intentar nombre completo directo; si no, construirlo.
    final nombreCompleto = _str(j['NombreCompleto']).isNotEmpty
        ? _str(j['NombreCompleto'])
        : [
            _str(j['Nombre'] ?? j['nombre']),
            _str(j['PrimerApellido'] ?? j['primerApellido']),
            _str(j['SegundoApellido'] ?? j['segundoApellido']),
          ].where((x) => x.isNotEmpty).join(' ').trim();

    final identificacion = _str(j['Identificacion'] ?? j['identificacion']);


    final tipoUsuario = _str(j['TipoUsuario'] ?? j['Tipo'] ?? j['tipoUsuario']);

    final fotografiaUrl =
        (j['FotografiaUrl'] ?? j['fotografiaUrl'] ?? j['FotoUrl'])?.toString();

    return Usuario(
      nombreCompleto: nombreCompleto,
      identificacion: identificacion,
      tipoUsuario: tipoUsuario,
      fotografiaUrl: fotografiaUrl?.isEmpty == true ? null : fotografiaUrl,
    );
  }
}
