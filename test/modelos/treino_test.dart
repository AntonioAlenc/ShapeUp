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
          Exercicio(
            nome: 'Supino Inclinado',
            series: 3,
            reps: 10,
            descansoSeg: 60,
          ),
          Exercicio(
            nome: 'Crucifixo',
            series: 3,
            reps: 12,
            descansoSeg: 60,
          ),
        ],
        alunoId: 'aluno123',
        personalId: 'personal456',
      );

      // converte para Map
      final mapa = treino.toMap();

      expect(mapa['nome'], equals('Peito/Ombros'));
      expect(mapa['descricao'], contains('peito'));
      expect(mapa['frequencia'], equals('3x por semana'));
      expect(mapa['alunoId'], equals('aluno123'));
      expect(mapa['personalId'], equals('personal456'));

      // verifica se os exercícios estão no Map
      final listaEx = (mapa['exercicios'] as List);
      expect(listaEx.length, equals(2));
      expect(listaEx.first['nome'], equals('Supino Inclinado'));

      // reconstrói a partir do Map
      final novoTreino = Treino.fromMap(mapa, 'treino1');

      expect(novoTreino.id, equals(treino.id));
      expect(novoTreino.nome, equals(treino.nome));
      expect(novoTreino.descricao, equals(treino.descricao));
      expect(novoTreino.frequencia, equals(treino.frequencia));
      expect(novoTreino.exercicios.length, equals(2));
      expect(novoTreino.exercicios[1].nome, equals('Crucifixo'));
    });
  });
}
