class BlocoModel {
  final String id;
  final String nome;
  final String estadoId;

  BlocoModel({
    required this.id,
    required this.nome,
    required this.estadoId,
  });

  factory BlocoModel.fromJson(Map<String, dynamic> json) {
    return BlocoModel(
      id: json['id'],
      nome: json['nome'],
      estadoId: json['estado_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'estado_id': estadoId,
    };
  }
} 