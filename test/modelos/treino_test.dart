import 'package:flutter_test/flutter_test.dart';
import 'package:shapeup/modelos/treino.dart';

void main() {
  group('Teste da Entidade Treino', () {
    test('Conversão de Treino para Map e de volta', () {
      final treino = Treino(
        id: 'treino1',
        nome: 'Peito/Ombros',
        descricao: 'Treino para peito e ombros',
        frequencia: '3x por semana',
        exercicios: [
          'Supino Inclinado - 3x10',
          'Crucifixo - 3x12',
        ],
        alunoId: 'aluno123',
        personalId: 'personal456',
      );

      final mapa = treino.toMap();

      expect(mapa['nome'], equals('Peito/Ombros'));
      expect(mapa['descricao'], contains('peito'));
      expect(mapa['frequencia'], equals('3x por semana'));
      expect(mapa['exercicios'], contains('Crucifixo - 3x12'));
      expect(mapa['alunoId'], equals('aluno123'));
      expect(mapa['personalId'], equals('personal456'));

      final novoTreino = Treino.fromMap(mapa, 'treino1');

      expect(novoTreino.id, equals(treino.id));
      expect(novoTreino.nome, equals(treino.nome));
      expect(novoTreino.descricao, equals(treino.descricao));
      expect(novoTreino.frequencia, equals(treino.frequencia));
      expect(novoTreino.exercicios.length, equals(2));
    });
  });
}
