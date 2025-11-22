import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shapeup/modelos/treino.dart';

void main() {
  group('Modelo Treino - Testes', () {
    test('Criar treino com construtor padrão', () {
      final treino = Treino(
        id: '123',
        nome: 'Treino A',
        descricao: 'Descrição do treino',
        frequencia: '3x por semana',
        exercicios: [
          {'nome': 'Supino', 'series': 3, 'reps': 12},
        ],
        personalId: 'personal1',
        alunoId: 'aluno1',
        criadoEm: DateTime(2024, 1, 1),
        atualizadoEm: DateTime(2024, 1, 2),
      );

      expect(treino.id, '123');
      expect(treino.nome, 'Treino A');
      expect(treino.descricao, 'Descrição do treino');
      expect(treino.frequencia, '3x por semana');
      expect(treino.personalId, 'personal1');
      expect(treino.alunoId, 'aluno1');
      expect(treino.exercicios.length, 1);
      expect(treino.criadoEm, DateTime(2024, 1, 1));
      expect(treino.atualizadoEm, DateTime(2024, 1, 2));
    });

    test('Treino.novo deve criar objeto com id vazio e data atual', () {
      final treino = Treino.novo(
        nome: 'Treino B',
        descricao: 'Desc B',
        frequencia: '2x',
        exercicios: [],
        personalId: 'p123',
      );

      expect(treino.id, '');
      expect(treino.nome, 'Treino B');
      expect(treino.descricao, 'Desc B');
      expect(treino.frequencia, '2x');
      expect(treino.personalId, 'p123');
      expect(treino.alunoId, isNull);
      expect(treino.exercicios, isEmpty);
      expect(treino.atualizadoEm, isNull);
    });

    test('toMap deve converter corretamente os dados', () {
      final date = DateTime(2024, 1, 1);

      final treino = Treino(
        id: '123',
        nome: 'Treino Map',
        descricao: 'Teste',
        frequencia: '1x',
        exercicios: [{'nome': 'Agachamento', 'series': 3}],
        personalId: 'p1',
        alunoId: 'a1',
        criadoEm: date,
      );

      final map = treino.toMap();

      expect(map['nome'], 'Treino Map');
      expect(map['descricao'], 'Teste');
      expect(map['frequencia'], '1x');
      expect(map['exercicios'][0]['nome'], 'Agachamento');
      expect(map['personalId'], 'p1');
      expect(map['alunoId'], 'a1');
      expect(map['dataCriacao'], isA<Timestamp>());
      expect((map['dataCriacao'] as Timestamp).toDate(), date);
    });

    test('fromDoc deve reconstruir objeto corretamente', () {
      final data = {
        'nome': 'Treino X',
        'descricao': 'Força',
        'frequencia': '3x',
        'exercicios': [
          {'nome': 'Supino', 'series': 4},
        ],
        'personalId': 'p123',
        'alunoId': 'a123',
        'dataCriacao': Timestamp.fromDate(DateTime(2023, 5, 1)),
        'atualizadoEm': Timestamp.fromDate(DateTime(2023, 5, 2)),
      };

      final doc = _FakeDocumentSnapshot('abc', data);

      final treino = Treino.fromDoc(doc);

      expect(treino.id, 'abc');
      expect(treino.nome, 'Treino X');
      expect(treino.exercicios.length, 1);
      expect(treino.personalId, 'p123');
      expect(treino.alunoId, 'a123');
      expect(treino.criadoEm, DateTime(2023, 5, 1));
      expect(treino.atualizadoEm, DateTime(2023, 5, 2));
    });

    test('copyWith deve criar nova instância alterando somente campos desejados', () {
      final original = Treino(
        id: '1',
        nome: 'Treino Original',
        descricao: 'Desc O',
        frequencia: '1x',
        exercicios: [],
        personalId: 'p1',
        alunoId: 'a1',
        criadoEm: DateTime(2024, 1, 1),
      );

      final novo = original.copyWith(nome: 'Treino Novo', frequencia: '2x');

      expect(novo.nome, 'Treino Novo');
      expect(novo.frequencia, '2x');
      expect(novo.id, original.id);
      expect(novo.personalId, original.personalId);
    });

    test('fromDoc deve funcionar com campos antigos (criadoEm)', () {
      final data = {
        'nome': 'Antigo',
        'descricao': 'Teste',
        'frequencia': '1x',
        'exercicios': [],
        'personalId': 'p1',
        'criadoEm': Timestamp.fromDate(DateTime(2021, 1, 1)),
      };

      final doc = _FakeDocumentSnapshot('xyz', data);

      final treino = Treino.fromDoc(doc);

      expect(treino.criadoEm, DateTime(2021, 1, 1));
    });
  });
}

/// Fake DocumentSnapshot para testes sem Firebase real
class _FakeDocumentSnapshot implements DocumentSnapshot {
  @override
  final String id;

  @override
  final Map<String, dynamic>? dataMap;

  _FakeDocumentSnapshot(this.id, this.dataMap);

  @override
  Map<String, dynamic>? data() => dataMap;

  // A partir daqui: membros que não usamos, mas são obrigatórios
  @override noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
