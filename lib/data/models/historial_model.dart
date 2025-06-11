class HistorialModel {
  final String salida;
  final String accion;
  final String fecha;
  final String hora;
  final String usuario;

  HistorialModel({
    required this.salida,
    required this.accion,
    required this.fecha,
    required this.hora,
    required this.usuario,
  });

  factory HistorialModel.fromFirestore(Map<String, dynamic> data) {
    final timestamp = data['timestamp']['stringValue'];
    final partes = timestamp.split(' ');
    final fecha = partes[0]; // yyyy-mm-dd
    final hora = partes.length > 1 ? partes[1] : '';
    final horaFormateada = _formatearHora(hora);

    return HistorialModel(
      salida: data['salida']['stringValue'],
      accion: data['accion']['stringValue'],
      fecha: _formatearFecha(fecha),
      hora: horaFormateada,
      usuario: data['usuario']['stringValue'],
    );
  }

  static String _formatearFecha(String fechaISO) {
    final partes = fechaISO.split('-'); // [yyyy, mm, dd]
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  static String _formatearHora(String hora24) {
    final partes = hora24.split(':');
    int h = int.parse(partes[0]);
    final m = partes[1];
    final sufijo = h >= 12 ? 'Pm' : 'Am';
    h = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h:$m $sufijo';
  }
}
