class UserModel {
  final String id;
  final String? name;
  final String email;
  final String? whatsapp;
  final String? photoUrl;
  final String? igrejaId;
  final String? nivel;

  UserModel({
    required this.id,
    this.name,
    required this.email,
    this.whatsapp,
    this.photoUrl,
    this.igrejaId,
    this.nivel,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['nome'],
      email: json['email'],
      whatsapp: json['whatsapp'],
      photoUrl: json['foto_url'],
      igrejaId: json['igreja_id'],
      nivel: json['nivel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': name,
      'email': email,
      'whatsapp': whatsapp,
      'foto_url': photoUrl,
      'igreja_id': igrejaId,
      'nivel': nivel,
    };
  }
} 