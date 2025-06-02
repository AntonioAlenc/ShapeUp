class Mensagem {
  final String id;
  final String texto;
  final String remetenteId;
  final String destinatarioId;
  final DateTime dataHora;

  Mensagem({
    required this.id,
    required this.texto,
    required this.remetenteId,
    required this.destinatarioId,
    required this.dataHora,
  });

  factory Mensagem.fromMap(Map<String, dynamic> map, String id) {
    return Mensagem(
      id: id,
      texto: map['texto'] ?? '',
      remetenteId: map['remetenteId'] ?? '',
      destinatarioId: map['destinatarioId'] ?? '',
      dataHora: DateTime.parse(map['dataHora']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'texto': texto,
      'remetenteId': remetenteId,
      'destinatarioId': destinatarioId,
      'dataHora': dataHora.toIso8601String(),
    };
  }
}
