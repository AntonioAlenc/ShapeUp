import 'package:cloud_firestore/cloud_firestore.dart';

class Treino {
  final String id;
  final String nome;
  final String descricao;
  final String frequencia; // ex.: "3x por semana"
  final List<Map<String, dynamic>> exercicios; // lista com nome, séries, observação
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

  // Criar um treino novo (sem ID ainda)
  factory Treino.novo({
    required String nome,
    required String descricao,
    required String frequencia,
    required List<Map<String, dynamic>> exercicios,
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

  // Converter para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'frequencia': frequencia,
      'exercicios': exercicios, // já é lista de Map
      'personalId': personalId,
      'alunoId': alunoId,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'atualizadoEm':
      atualizadoEm != null ? Timestamp.fromDate(atualizadoEm!) : null,
    };
  }

  // Criar treino a partir de um documento do Firestore
  factory Treino.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Treino(
      id: doc.id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      frequencia: data['frequencia'] ?? '',
      exercicios: (data['exercicios'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          [],
      personalId: data['personalId'] ?? '',
      alunoId: data['alunoId'],
      criadoEm: (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      atualizadoEm: (data['atualizadoEm'] as Timestamp?)?.toDate(),
    );
  }

  // Criar uma cópia com alteração
  Treino copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? frequencia,
    List<Map<String, dynamic>>? exercicios,
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
