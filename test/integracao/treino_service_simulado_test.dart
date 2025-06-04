import 'package:flutter_test/flutter_test.dart';
import 'package:shapeup/modelos/treino.dart';

void main() {
  group('Teste de Integração - Servico de Treino Simulado', () {
    final servico = TreinoServicoSimulado();

    test('Salvar e recuperar um treino', () async {
      final treino = Treino(
        id: 'treino001',
        nome: 'Peito/Ombros',
        descricao: 'Treino para peito e ombros',
        frequencia: '3x por semana',
        exercicios: ['Supino', 'Crucifixo'],
        alunoId: 'aluno123',
        personalId: 'personal456',
      );

      await servico.salvarTreino(treino);

      final recuperado = await servico.buscarPorId('treino001');

      expect(recuperado, isNotNull);
      expect(recuperado!.nome, equals('Peito/Ombros'));
      expect(recuperado.exercicios.length, equals(2));
    });
  });
}

class TreinoServicoSimulado {
  final Map<String, Treino> _bancoFake = {};

  Future<void> salvarTreino(Treino treino) async {
    _bancoFake[treino.id] = treino;
  }

  Future<Treino?> buscarPorId(String id) async {
    return _bancoFake[id];
  }

  Future<List<Treino>> listarTodos() async {
    return _bancoFake.values.toList();
  }
}
