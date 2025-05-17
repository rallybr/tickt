class EstadoModel {
  final String id;
  final String nome;
  final String sigla;

  EstadoModel({
    required this.id,
    required this.nome,
    required this.sigla,
  });

  factory EstadoModel.fromJson(Map<String, dynamic> json) {
    print('Convertendo JSON para EstadoModel: $json');
    
    if (json['id'] == null) {
      print('Erro: id é nulo');
      throw Exception('id é obrigatório');
    }
    if (json['nome'] == null) {
      print('Erro: nome é nulo');
      throw Exception('nome é obrigatório');
    }
    if (json['sigla'] == null) {
      print('Erro: sigla é nula');
      throw Exception('sigla é obrigatória');
    }

    final estado = EstadoModel(
      id: json['id'].toString(),
      nome: json['nome'].toString(),
      sigla: json['sigla'].toString(),
    );

    print('EstadoModel criado: [32m${estado.toString()}[0m');
    return estado;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'sigla': sigla,
    };
  }

  @override
  String toString() {
    return 'EstadoModel(id: $id, nome: $nome, sigla: $sigla)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EstadoModel &&
        other.id == id &&
        other.nome == nome &&
        other.sigla == sigla;
  }

  @override
  int get hashCode => id.hashCode ^ nome.hashCode ^ sigla.hashCode;
} 