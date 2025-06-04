class Treino {
  final String id;
  final String nome;
  final String descricao;
  final String frequencia;
  final List<String> exercicios;
  final String alunoId;
  final String personalId;

  Treino({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.frequencia,
    required this.exercicios,
    required this.alunoId,
    required this.personalId,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'frequencia': frequencia,
      'exercicios': exercicios,
      'alunoId': alunoId,
      'personalId': personalId,
    };
  }

  factory Treino.fromMap(Map<String, dynamic> map, String id) {
    return Treino(
      id: id,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      frequencia: map['frequencia'] ?? '',
      exercicios: List<String>.from(map['exercicios'] ?? []),
      alunoId: map['alunoId'] ?? '',
      personalId: map['personalId'] ?? '',
    );
  }
}
