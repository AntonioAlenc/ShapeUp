class Treino {
  final String id;
  final String nome;
  final String descricao;
  final List<String> exercicios;
  final String frequencia;
  final String personalId;
  final String alunoId;

  Treino({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.exercicios,
    required this.frequencia,
    required this.personalId,
    required this.alunoId,
  });

  factory Treino.fromMap(Map<String, dynamic> map, String id) {
    return Treino(
      id: id,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      exercicios: List<String>.from(map['exercicios'] ?? []),
      frequencia: map['frequencia'] ?? '',
      personalId: map['personalId'] ?? '',
      alunoId: map['alunoId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'exercicios': exercicios,
      'frequencia': frequencia,
      'personalId': personalId,
      'alunoId': alunoId,
    };
  }
}
