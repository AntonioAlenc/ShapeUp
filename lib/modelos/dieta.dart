class Dieta {
  final String id;
  final String nome;
  final List<String> refeicoes;
  final String observacoes;
  final String restricoes;
  final String personalId;
  final String alunoId;

  Dieta({
    required this.id,
    required this.nome,
    required this.refeicoes,
    required this.observacoes,
    required this.restricoes,
    required this.personalId,
    required this.alunoId,
  });

  factory Dieta.fromMap(Map<String, dynamic> map, String id) {
    return Dieta(
      id: id,
      nome: map['nome'] ?? '',
      refeicoes: List<String>.from(map['refeicoes'] ?? []),
      observacoes: map['observacoes'] ?? '',
      restricoes: map['restricoes'] ?? '',
      personalId: map['personalId'] ?? '',
      alunoId: map['alunoId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'refeicoes': refeicoes,
      'observacoes': observacoes,
      'restricoes': restricoes,
      'personalId': personalId,
      'alunoId': alunoId,
    };
  }
}
