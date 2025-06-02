class Lembrete {
  final String id;
  final String alunoId;
  final String tipo; // 'treino' ou 'refeicao'
  final String mensagem;
  final DateTime horario;

  Lembrete({
    required this.id,
    required this.alunoId,
    required this.tipo,
    required this.mensagem,
    required this.horario,
  });

  factory Lembrete.fromMap(Map<String, dynamic> map, String id) {
    return Lembrete(
      id: id,
      alunoId: map['alunoId'] ?? '',
      tipo: map['tipo'] ?? '',
      mensagem: map['mensagem'] ?? '',
      horario: DateTime.parse(map['horario']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alunoId': alunoId,
      'tipo': tipo,
      'mensagem': mensagem,
      'horario': horario.toIso8601String(),
    };
  }
}
