import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shapeup/modelos/treino.dart';
import 'package:shapeup/servicos/treino_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late TreinoService service;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    firestore = FakeFirebaseFirestore();

    // usa o modo de teste oficial
    service = TreinoService.test(firestore);
  });

  group('TreinoService - Testes com Fake Firestore', () {
    test('Salvar treino deve criar documento e retornar ID', () async {
      final treino = Treino.novo(
        nome: 'Treino A',
        descricao: 'Superiores',
        frequencia: '3x',
        exercicios: [
          {'nome': 'Supino', 'series': '3x12'}
        ],
        personalId: 'personal123',
        diaSemana: 'segunda',
      );

      final id = await service.salvarTreino(treino);
      final doc = await firestore.collection('treinos').doc(id).get();

      expect(doc.exists, true);
      expect(doc.data()!['nome'], 'Treino A');
      expect(doc.data()!['personalId'], 'personal123');
      expect(doc.data()!['diaSemana'], 'segunda');
    });

    test('Atualizar treino deve modificar dados corretamente', () async {
      final docRef = await firestore.collection('treinos').add({
        'nome': 'Antigo',
        'descricao': 'Desc',
        'frequencia': '1x',
        'exercicios': [],
        'personalId': 'p1',
        'diaSemana': 'quarta',
      });

      final atualizado = Treino(
        id: docRef.id,
        nome: 'Novo Nome',
        descricao: 'Nova Desc',
        frequencia: '2x',
        exercicios: [
          {'nome': 'Agachamento', 'series': '4x10'}
        ],
        personalId: 'p1',
        alunoId: null,
        criadoEm: DateTime.now(),
        atualizadoEm: null,
        diaSemana: 'sexta',
        concluido: false,
        concluidoEm: null,
        validadeSemana: DateTime.now(),
      );

      await service.atualizarTreino(docRef.id, atualizado);

      final snap = await docRef.get();
      final dt = snap.data()!;

      expect(dt['nome'], 'Novo Nome');
      expect(dt['descricao'], 'Nova Desc');
      expect(dt['exercicios'][0]['nome'], 'Agachamento');
      expect(dt['diaSemana'], 'sexta');
    });

    test('Excluir treino deve remover o documento', () async {
      final docRef = await firestore.collection('treinos').add({
        'nome': 'Treino X',
        'personalId': 'p1',
        'diaSemana': 'sexta',
      });

      await service.excluirTreino(docRef.id);

      final snap = await docRef.get();
      expect(snap.exists, false);
    });

    test('Atribuir treino deve definir alunoId corretamente', () async {
      final docRef = await firestore.collection('treinos').add({
        'nome': 'Treino Z',
        'personalId': 'p1',
        'diaSemana': 'sabado',
      });

      await service.atribuirTreino(docRef.id, 'aluno123');

      final snap = await docRef.get();
      expect(snap['alunoId'], 'aluno123');
    });
  });
}
