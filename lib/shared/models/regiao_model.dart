class RegiaoModel {
  final String id;
  final String nome;
  final String blocoId;

  RegiaoModel({
    required this.id,
    required this.nome,
    required this.blocoId,
  });

  factory RegiaoModel.fromJson(Map<String, dynamic> json) {
    return RegiaoModel(
      id: json['id'],
      nome: json['nome'],
      blocoId: json['bloco_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'bloco_id': blocoId,
    };
  }
} 