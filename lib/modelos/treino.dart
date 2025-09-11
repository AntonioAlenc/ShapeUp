import 'package:cloud_firestore/cloud_firestore.dart';

class Treino {
  final String id;
  final String nome;
  final String descricao;
  final String frequencia; // ex.: "3x por semana"
  final List<String> exercicios; // lista de nomes
  final String personalId; // uid do personal criador
  final String? alunoId; // uid do aluno atribuído (pode ser null)
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
    required this.criadoEm,
    this.atualizadoEm,
  });

  factory Treino.novo({
    required String nome,
    required String descricao,
    required String frequencia,
    required List<String> exercicios,
    required String personalId,
    String? alunoId,
  }) {
    return Treino(
      id: '',
      nome: nome,
      descricao: descricao,
      frequencia: frequencia,
      exercicios: exercicios,
      personalId: personalId,
      alunoId: alunoId,
      criadoEm: DateTime.now(),
      atualizadoEm: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'frequencia': frequencia,
      'exercicios': exercicios,
      'personalId': personalId,
      'alunoId': alunoId,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'atualizadoEm':
          atualizadoEm != null ? Timestamp.fromDate(atualizadoEm!) : null,
    };
  }

  factory Treino.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Treino(
      id: doc.id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      frequencia: data['frequencia'] ?? '',
      exercicios: (data['exercicios'] as List?)?.cast<String>() ?? const [],
      personalId: data['personalId'] ?? '',
      alunoId: data['alunoId'],
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoEm: (data['atualizadoEm'] as Timestamp?)?.toDate(),
    );
  }

  Treino copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? frequencia,
    List<String>? exercicios,
    String? personalId,
    String? alunoId,
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
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
