class Usuario {
  final String id;
  final String nome;
  final String email;
  final String tipo; // 'aluno' ou 'personal'
  final String? fotoUrl;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
    this.fotoUrl,
  });

  // Construtor a partir de dados do Firebase
  factory Usuario.fromMap(Map<String, dynamic> map, String id) {
    return Usuario(
      id: id,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      tipo: map['tipo'] ?? 'aluno',
      fotoUrl: map['fotoUrl'],
    );
  }

  // Converte o modelo para map (ex: salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'tipo': tipo,
      'fotoUrl': fotoUrl,
    };
  }
}
