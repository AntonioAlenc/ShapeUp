import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shapeup/modelos/treino.dart';
import 'package:shapeup/servicos/treino_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late TreinoService service;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    firestore = FakeFirebaseFirestore();

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
      );

      final id = await service.salvarTreino(treino);
      final doc = await firestore.collection('treinos').doc(id).get();

      expect(doc.exists, true);
      expect(doc.data()!['nome'], 'Treino A');
      expect(doc.data()!['personalId'], 'personal123');
      expect(doc.data()!['exercicios'], isA<List>());
    });

    test('Atualizar treino deve modificar dados corretamente', () async {
      final docRef = await firestore.collection('treinos').add({
        'nome': 'Antigo',
        'descricao': 'Desc',
        'frequencia': '1x',
        'exercicios': [],
        'personalId': 'p1',
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
        criadoEm: DateTime.now(),
      );

      await service.atualizarTreino(docRef.id, atualizado);

      final snap = await docRef.get();
      final data = snap.data()!;

      expect(data['nome'], 'Novo Nome');
      expect(data['descricao'], 'Nova Desc');
      expect(data['frequencia'], '2x');
      expect(data['exercicios'][0]['nome'], 'Agachamento');
    });

    test('Excluir treino deve remover o documento', () async {
      final docRef = await firestore.collection('treinos').add({
        'nome': 'Treino X',
        'personalId': 'p1',
      });

      await service.excluirTreino(docRef.id);

      final snap = await docRef.get();
      expect(snap.exists, false);
    });

    test('Buscar por ID deve retornar Treino válido quando existir', () async {
      final docRef = await firestore.collection('treinos').add({
        'nome': 'Treino B',
        'descricao': 'Pernas',
        'frequencia': '2x',
        'exercicios': [
          {'nome': 'Agachamento', 'series': '3x15'}
        ],
        'personalId': 'p1',
        'dataCriacao': DateTime(2024, 1, 1),
      });

      final treino = await service.buscarPorId(docRef.id);

      expect(treino, isNotNull);
      expect(treino!.nome, 'Treino B');
      expect(treino.exercicios.length, 1);
      expect(treino.personalId, 'p1');
    });

    test('Buscar por ID deve retornar null quando não existir', () async {
      final treino = await service.buscarPorId('naoExiste');
      expect(treino, isNull);
    });

    test('Stream treinos do personal deve retornar lista correta', () async {
      await firestore.collection('treinos').add({
        'nome': 'Treino 1',
        'personalId': 'p1',
        'dataCriacao': DateTime.now(),
      });

      await firestore.collection('treinos').add({
        'nome': 'Treino 2',
        'personalId': 'p1',
        'dataCriacao': DateTime.now(),
      });

      final stream = service.streamTreinosDoPersonal('p1');

      stream.listen(expectAsync1((lista) {
        expect(lista.length, 2);
        expect(lista.first.personalId, 'p1');
      }));
    });

    test('Atribuir treino deve definir alunoId corretamente', () async {
      final docRef = await firestore.collection('treinos').add({
        'nome': 'Treino Z',
        'personalId': 'p1',
      });

      await service.atribuirTreino(docRef.id, 'aluno123');

      final snap = await docRef.get();
      expect(snap['alunoId'], 'aluno123');
    });

    test('Remover atribuição deve definir alunoId como null', () async {
      final docRef = await firestore.collection('treinos').add({
        'nome': 'Treino Z',
        'personalId': 'p1',
        'alunoId': 'aluno123',
      });

      await service.removerAtribuicao(docRef.id);

      final snap = await docRef.get();
      expect(snap['alunoId'], isNull);
    });
  });
}
