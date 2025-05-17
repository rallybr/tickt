class IgrejaModel {
  final String id;
  final String nome;
  final String regiaoId;

  IgrejaModel({
    required this.id,
    required this.nome,
    required this.regiaoId,
  });

  factory IgrejaModel.fromJson(Map<String, dynamic> json) {
    return IgrejaModel(
      id: json['id'],
      nome: json['nome'],
      regiaoId: json['regiao_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'regiao_id': regiaoId,
    };
  }
} 