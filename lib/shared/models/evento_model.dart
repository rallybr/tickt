class EventoModel {
  final String? id;
  final String titulo;
  final String descricao;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String local;
  final String bannerUrl;
  final String igrejaId;
  final String? criadorId;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? logoEvento;

  EventoModel({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.dataInicio,
    required this.dataFim,
    required this.local,
    required this.bannerUrl,
    required this.igrejaId,
    this.criadorId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.logoEvento,
  });

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    return EventoModel(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: DateTime.parse(json['data_fim']),
      local: json['local'],
      bannerUrl: json['banner_url'],
      igrejaId: json['igreja_id'],
      criadorId: json['criador_id'],
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      logoEvento: json['logo_evento'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'titulo': titulo,
      'descricao': descricao,
      'data_inicio': dataInicio.toIso8601String(),
      'data_fim': dataFim.toIso8601String(),
      'local': local,
      'banner_url': bannerUrl,
      'igreja_id': igrejaId,
      'criador_id': criadorId,
      'status': status,
      'logo_evento': logoEvento,
    };
    if (id != null) {
      map['id'] = id;
    }
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    if (updatedAt != null) {
      map['updated_at'] = updatedAt!.toIso8601String();
    }
    return map;
  }
} 