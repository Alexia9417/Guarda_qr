class Guarda {
  final String id;
  final String nombreCompleto;
  final String identificacion;
  final String tipoUsuario;
  final String? fotografiaUrl;

  Guarda({
    required this.id,
    required this.nombreCompleto,
    required this.identificacion,
    required this.tipoUsuario,
    this.fotografiaUrl,
  });

  factory Guarda.fromJson(Map<String, dynamic> j) {
    final email = (j['email'] ?? '').toString();
    final nombre = (j['nombre'] ?? '').toString().trim();
    final ape1 = (j['primerApellido'] ?? '').toString().trim();
    final ape2 = (j['segundoApellido'] ?? '').toString().trim();
    final nombreCompleto = [
      nombre,
      ape1,
      ape2,
    ].where((s) => s.isNotEmpty).join(' ').trim();

    final ident = (j['identificacion'] ?? j['cedula'] ?? '').toString();
    final tipo = (j['tipoUsuario'] ?? j['rol'] ?? '').toString();

    return Guarda(
      id: email,
      nombreCompleto: nombreCompleto,
      identificacion: ident,
      tipoUsuario: tipo,
      fotografiaUrl: null,
    );
  }

  Guarda copyWith({String? fotografiaUrl}) => Guarda(
    id: id,
    nombreCompleto: nombreCompleto,
    identificacion: identificacion,
    tipoUsuario: tipoUsuario,
    fotografiaUrl: fotografiaUrl ?? this.fotografiaUrl,
  );
}
