import 'package:cloud_firestore/cloud_firestore.dart';

class Treino {
  final String id;
  final String nome;
  final String descricao;
  final String frequencia; // (continua existindo para compatibilidade)
  final List<Map<String, dynamic>> exercicios;
  final String personalId;
  final String? alunoId;

  // 🔥 CAMPOS NOVOS — suporte semanal
  final String diaSemana; // segunda, terca, quarta, quinta, sexta, sabado, domingo
  final bool concluido; // concluído nesta semana?
  final DateTime? concluidoEm; // quando foi concluído?
  final DateTime? validadeSemana; // segunda-feira da semana de referência

  final DateTime criadoEm;
  final DateTime? atualizadoEm;

  Treino({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.frequencia,
    required this.exercicios,
    required this.personalId,
    this.alunoId,
    required this.diaSemana,
    required this.concluido,
    this.concluidoEm,
    this.validadeSemana,
    required this.criadoEm,
    this.atualizadoEm,
  });

  /// 🔹 Criação de um novo treino (padrão semanal)
  factory Treino.novo({
    required String nome,
    required String descricao,
    required String frequencia,
    required List<Map<String, dynamic>> exercicios,
    required String personalId,
    String? alunoId,
    required String diaSemana,
  }) {
    return Treino(
      id: '',
      nome: nome,
      descricao: descricao,
      frequencia: frequencia,
      exercicios: exercicios,
      personalId: personalId,
      alunoId: alunoId,
      diaSemana: diaSemana,
      concluido: false,
      concluidoEm: null,
      validadeSemana: _inicioSemana(DateTime.now()),
      criadoEm: DateTime.now(),
      atualizadoEm: null,
    );
  }

  /// 🔹 Converter para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'frequencia': frequencia,
      'exercicios': exercicios,
      'personalId': personalId,
      'alunoId': alunoId,
      'diaSemana': diaSemana,
      'concluido': concluido,
      'concluidoEm': concluidoEm != null ? Timestamp.fromDate(concluidoEm!) : null,
      'validadeSemana': validadeSemana != null ? Timestamp.fromDate(validadeSemana!) : null,
      'dataCriacao': Timestamp.fromDate(criadoEm),
      'atualizadoEm': atualizadoEm != null ? Timestamp.fromDate(atualizadoEm!) : null,
    };
  }

  /// 🔹 Ler documento do Firestore
  factory Treino.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Treino(
      id: doc.id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      frequencia: data['frequencia'] ?? '',
      exercicios: (data['exercicios'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      personalId: data['personalId'] ?? '',
      alunoId: data['alunoId'],
      diaSemana: data['diaSemana'] ?? 'segunda',

      concluido: data['concluido'] ?? false,
      concluidoEm: (data['concluidoEm'] as Timestamp?)?.toDate(),
      validadeSemana: (data['validadeSemana'] as Timestamp?)?.toDate(),

      criadoEm: (data['dataCriacao'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      atualizadoEm: (data['atualizadoEm'] as Timestamp?)?.toDate(),
    );
  }

  /// 🔹 Atualizar modelo
  Treino copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? frequencia,
    List<Map<String, dynamic>>? exercicios,
    String? personalId,
    String? alunoId,
    String? diaSemana,
    bool? concluido,
    DateTime? concluidoEm,
    DateTime? validadeSemana,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Treino(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      frequencia: frequencia ?? this.frequencia,
      exercicios: exercicios ?? this.exercicios,
      personalId: personalId ?? this.personalId,
      alunoId: alunoId ?? this.alunoId,
      diaSemana: diaSemana ?? this.diaSemana,
      concluido: concluido ?? this.concluido,
      concluidoEm: concluidoEm ?? this.concluidoEm,
      validadeSemana: validadeSemana ?? this.validadeSemana,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  /// 🔹 Segunda-feira da semana atual
  static DateTime _inicioSemana(DateTime d) {
    final segunda = d.subtract(Duration(days: d.weekday - 1));
    return DateTime(segunda.year, segunda.month, segunda.day, 0, 0, 0);
  }
}
