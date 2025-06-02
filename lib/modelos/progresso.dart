class Progresso {
  final String id;
  final String alunoId;
  final double peso;
  final double altura;
  final Map<String, double> medidas; // Ex: {'cintura': 70.0, 'peito': 95.0}
  final String? imagemUrl;
  final DateTime data;

  Progresso({
    required this.id,
    required this.alunoId,
    required this.peso,
    required this.altura,
    required this.medidas,
    this.imagemUrl,
    required this.data,
  });

  factory Progresso.fromMap(Map<String, dynamic> map, String id) {
    return Progresso(
      id: id,
      alunoId: map['alunoId'] ?? '',
      peso: (map['peso'] ?? 0).toDouble(),
      altura: (map['altura'] ?? 0).toDouble(),
      medidas: Map<String, double>.from(map['medidas'] ?? {}),
      imagemUrl: map['imagemUrl'],
      data: DateTime.parse(map['data']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alunoId': alunoId,
      'peso': peso,
      'altura': altura,
      'medidas': medidas,
      'imagemUrl': imagemUrl,
      'data': data.toIso8601String(),
    };
  }
}
