import 'package:cloud_firestore/cloud_firestore.dart';

class Treino {
  final String id;
  final String nome;
  final String descricao;
  final String frequencia;
  final List<Map<String, dynamic>> exercicios;
  final String personalId;
  final String? alunoId;
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

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'frequencia': frequencia,
      'exercicios': exercicios,
      'personalId': personalId,
      'alunoId': alunoId,
      'dataCriacao': Timestamp.fromDate(criadoEm), // 🔹 padronizado
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
      exercicios: (data['exercicios'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          [],
      personalId: data['personalId'] ?? '',
      alunoId: data['alunoId'],
      // 🔹 compatível com campos antigos (dataCriacao ou criadoEm)
      criadoEm: (data['dataCriacao'] as Timestamp?)?.toDate() ??
          (data['criadoEm'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      atualizadoEm: (data['atualizadoEm'] as Timestamp?)?.toDate(),
    );
  }

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
