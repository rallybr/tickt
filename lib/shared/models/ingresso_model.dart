class IngressoModel {
  final String id;
  final String codigoQr;
  final String numeroIngresso;
  final String status;
  final DateTime dataCompra;
  final String eventoId;
  final String compradorId;

  IngressoModel({
    required this.id,
    required this.codigoQr,
    required this.numeroIngresso,
    required this.status,
    required this.dataCompra,
    required this.eventoId,
    required this.compradorId,
  });

  factory IngressoModel.fromJson(Map<String, dynamic> json) {
    return IngressoModel(
      id: json['id'],
      codigoQr: json['codigo_qr'] ?? json['hash_unico'] ?? '',
      numeroIngresso: json['numero_ingresso'] ?? '',
      status: json['status'] ?? '',
      dataCompra: DateTime.parse(json['data_compra'] ?? json['created_at']),
      eventoId: json['evento_id'] ?? '',
      compradorId: json['comprador_id'] ?? '',
    );
  }
} 