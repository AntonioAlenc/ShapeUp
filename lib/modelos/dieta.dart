import 'package:cloud_firestore/cloud_firestore.dart';

class Dieta {
  final String id;
  final String nome;
  final List<String> refeicoes;
  final String observacoes;
  final String restricoes;
  final String personalId;
  final String alunoId;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  Dieta({
    required this.id,
    required this.nome,
    required this.refeicoes,
    required this.observacoes,
    required this.restricoes,
    required this.personalId,
    required this.alunoId,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Dieta.fromMap(Map<String, dynamic> map, String id) {
    final criadoEm = (map['criadoEm'] ?? map['createdAt']) as Timestamp?;
    return Dieta(
      id: id,
      nome: map['nome'] ?? '',
      refeicoes: List<String>.from(map['refeicoes'] ?? []),
      observacoes: map['observacoes'] ?? '',
      restricoes: map['restricoes'] ?? '',
      personalId: map['personalId'] ?? '',
      alunoId: map['alunoId'] ?? '',
      criadoEm: criadoEm?.toDate(),
      atualizadoEm: (map['atualizadoEm'] as Timestamp?)?.toDate(),
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
      'criadoEm': criadoEm != null ? Timestamp.fromDate(criadoEm!) : FieldValue.serverTimestamp(),
      'atualizadoEm': atualizadoEm != null ? Timestamp.fromDate(atualizadoEm!) : null,
    };
  }
}
