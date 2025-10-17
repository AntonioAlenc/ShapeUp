class Progresso {
  final String id;
  final String alunoId;
  final String sexo; // masculino ou feminino
  final double peso;
  final double altura;
  final Map<String, double> medidas; // Ex: {'bracoDireito': 35.0, 'coxaEsquerda': 60.0}
  final String? imagemUrl; // foto opcional
  final String? observacoes; // campo de anotações
  final DateTime data; // data do registro
  final DateTime criadoEm; // timestamp de criação
  final DateTime? atualizadoEm; // timestamp de atualização (opcional)

  Progresso({
    required this.id,
    required this.alunoId,
    required this.sexo,
    required this.peso,
    required this.altura,
    required this.medidas,
    this.imagemUrl,
    this.observacoes,
    required this.data,
    required this.criadoEm,
    this.atualizadoEm,
  });

  factory Progresso.fromMap(Map<String, dynamic> map, String id) {
    final medidasMap = <String, double>{};

    // 🔹 Garante que os campos novos (direito/esquerdo) existam no mapa
    if (map['medidas'] != null) {
      final m = Map<String, dynamic>.from(map['medidas']);
      for (final e in m.entries) {
        final valor = (e.value is num)
            ? (e.value as num).toDouble()
            : double.tryParse(e.value.toString());
        if (valor != null) medidasMap[e.key] = valor;
      }
    }

    return Progresso(
      id: id,
      alunoId: map['alunoId'] ?? '',
      sexo: map['sexo'] ?? '',
      peso: (map['peso'] ?? 0).toDouble(),
      altura: (map['altura'] ?? 0).toDouble(),
      medidas: medidasMap,
      imagemUrl: map['imagemUrl'],
      observacoes: map['observacoes'],
      data: map['data'] is DateTime
          ? map['data']
          : DateTime.tryParse(map['data'] ?? '') ?? DateTime.now(),
      criadoEm: map['criadoEm'] is DateTime
          ? map['criadoEm']
          : DateTime.tryParse(map['criadoEm'] ?? '') ?? DateTime.now(),
      atualizadoEm: map['atualizadoEm'] != null
          ? (map['atualizadoEm'] is DateTime
          ? map['atualizadoEm']
          : DateTime.tryParse(map['atualizadoEm']))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final medidasPadrao = {
      'bracoDireito': medidas['bracoDireito'] ?? 0.0,
      'bracoEsquerdo': medidas['bracoEsquerdo'] ?? 0.0,
      'coxaDireita': medidas['coxaDireita'] ?? 0.0,
      'coxaEsquerda': medidas['coxaEsquerda'] ?? 0.0,
      'cintura': medidas['cintura'] ?? 0.0,
      'quadril': medidas['quadril'] ?? 0.0,
    };

    return {
      'alunoId': alunoId,
      'sexo': sexo,
      'peso': peso,
      'altura': altura,
      'medidas': medidasPadrao,
      'imagemUrl': imagemUrl,
      'observacoes': observacoes,
      'data': data.toIso8601String(),
      'criadoEm': criadoEm.toIso8601String(),
      'atualizadoEm': atualizadoEm?.toIso8601String(),
    };
  }
}
