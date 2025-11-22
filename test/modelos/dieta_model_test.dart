import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shapeup/modelos/dieta.dart';

void main() {
  group('Dieta Model Tests', () {
    test('toMap() deve converter corretamente', () {
      final dieta = Dieta(
        id: 'd1',
        nome: 'Dieta Cetogenica',
        refeicoes: ['Ovos', 'Abacate'],
        observacoes: 'Baixo carboidrato',
        restricoes: 'Sem açúcar',
        personalId: 'personal99',
        alunoId: 'aluno88',
        criadoEm: DateTime(2024, 1, 1),
        atualizadoEm: DateTime(2024, 1, 2),
      );

      final map = dieta.toMap();

      expect(map['nome'], 'Dieta Cetogenica');
      expect(map['refeicoes'], contains('Ovos'));
      expect(map['observacoes'], 'Baixo carboidrato');
      expect(map['restricoes'], 'Sem açúcar');
      expect(map['personalId'], 'personal99');
      expect(map['alunoId'], 'aluno88');
      expect(map['criadoEm'], isA<Timestamp>());
    });

    test('fromMap() deve converter timestamps corretamente', () {
      final map = {
        'nome': 'Dieta Massa',
        'refeicoes': ['Arroz', 'Frango'],
        'observacoes': 'ganho de massa',
        'restricoes': '',
        'personalId': 'p1',
        'alunoId': 'a1',
        'criadoEm': Timestamp.fromDate(DateTime(2024, 1, 10)),
        'atualizadoEm': Timestamp.fromDate(DateTime(2024, 1, 11)),
      };

      final dieta = Dieta.fromMap(map, 'd2');

      expect(dieta.id, 'd2');
      expect(dieta.nome, 'Dieta Massa');
      expect(dieta.refeicoes.length, 2);
      expect(dieta.criadoEm, isA<DateTime>());
      expect(dieta.atualizadoEm, isA<DateTime>());
    });
  });
}
