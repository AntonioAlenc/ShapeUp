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

  // 🔥 CAMPOS NOVOS PARA O MODELO B
  final String? periodo;
  final String? texto;

  final bool concluida;
  final DateTime? concluidaEm;

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
    this.periodo,
    this.texto,
    this.concluida = false,
    this.concluidaEm,
  });

  factory Dieta.fromMap(Map<String, dynamic> map, String id) {
    final criado = (map['criadoEm'] ?? map['createdAt']) as Timestamp?;

    return Dieta(
      id: id,
      nome: map['nome'] ?? '',
      refeicoes: List<String>.from(map['refeicoes'] ?? []),
      observacoes: map['observacoes'] ?? '',
      restricoes: map['restricoes'] ?? '',
      personalId: map['personalId'] ?? '',
      alunoId: map['alunoId'] ?? '',
      criadoEm: criado?.toDate(),
      atualizadoEm: (map['atualizadoEm'] as Timestamp?)?.toDate(),

      // 🔥 adicionados para modelo B
      periodo: map['periodo'],
      texto: map['texto'],

      concluida: map['concluida'] ?? false,
      concluidaEm: (map['concluidaEm'] as Timestamp?)?.toDate(),
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
      'criadoEm': criadoEm != null
          ? Timestamp.fromDate(criadoEm!)
          : FieldValue.serverTimestamp(),
      'atualizadoEm':
      atualizadoEm != null ? Timestamp.fromDate(atualizadoEm!) : null,

      // 🔥 modelo B
      'periodo': periodo,
      'texto': texto,

      'concluida': concluida,
      'concluidaEm':
      concluidaEm != null ? Timestamp.fromDate(concluidaEm!) : null,
    };
  }
}