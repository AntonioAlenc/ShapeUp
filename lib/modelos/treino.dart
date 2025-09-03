class Exercicio {
  final String nome;
  final int series;
  final int reps;
  final int descansoSeg;

  Exercicio({
    required this.nome,
    required this.series,
    required this.reps,
    required this.descansoSeg,
  });

  Map<String, dynamic> toMap() => {
    'nome': nome,
    'series': series,
    'reps': reps,
    'descansoSeg': descansoSeg,
  };

  factory Exercicio.fromMap(Map<String, dynamic> m) => Exercicio(
    nome: m['nome'] ?? '',
    series: (m['series'] ?? 0) as int,
    reps: (m['reps'] ?? 0) as int,
    descansoSeg: (m['descansoSeg'] ?? 0) as int,
  );
}

class Treino {
  final String id;
  final String nome;
  final String descricao;
  final String frequencia; // ex.: "Seg/Qua/Sex"
  final List<Exercicio> exercicios; // agora é lista de objetos
  final String alunoId; // UID do aluno
  final String personalId; // UID do treinador/personal

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
      'exercicios': exercicios.map((e) => e.toMap()).toList(),
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
      exercicios: (map['exercicios'] as List? ?? [])
          .map((e) => Exercicio.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      alunoId: map['alunoId'] ?? '',
      personalId: map['personalId'] ?? '',
    );
  }
}
