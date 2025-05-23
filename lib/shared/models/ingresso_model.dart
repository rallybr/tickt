class IngressoModel {
  final String id;
  final String eventoId;
  final String compradorId;
  final String status;
  final DateTime dataCompra;
  final String? codigoQr;
  final String? nomeUsuario;
  final String numeroIngresso;

  IngressoModel({
    required this.id,
    required this.eventoId,
    required this.compradorId,
    required this.status,
    required this.dataCompra,
    this.codigoQr,
    this.nomeUsuario,
    required this.numeroIngresso,
  });

  factory IngressoModel.fromJson(Map<String, dynamic> json) {
    return IngressoModel(
      id: json['id'],
      eventoId: json['evento_id'],
      compradorId: json['comprador_id'],
      status: json['status'],
      dataCompra: DateTime.parse(json['data_compra']),
      codigoQr: json['codigo_qr'],
      nomeUsuario: json['nome_usuario'],
      numeroIngresso: json['numero_ingresso'] ?? json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'evento_id': eventoId,
      'comprador_id': compradorId,
      'status': status,
      'data_compra': dataCompra.toIso8601String(),
      'codigo_qr': codigoQr,
      'nome_usuario': nomeUsuario,
      'numero_ingresso': numeroIngresso,
    };
  }
} 