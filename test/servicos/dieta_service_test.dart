import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shapeup/modelos/dieta.dart';
import 'package:shapeup/servicos/firebase_dieta_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirebaseDietaService service;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    firestore = FakeFirebaseFirestore();

    // Agora usando o construtor test()
    service = FirebaseDietaService.test(firestore);
  });

  group('FirebaseDietaService - Testes', () {
    test('adicionarDieta deve criar documento', () async {
      final dieta = Dieta(
        id: 'd1',
        nome: 'Dieta Massa',
        refeicoes: ['Arroz', 'Frango'],
        observacoes: 'Para ganhar massa',
        restricoes: 'Nenhuma',
        personalId: 'p1',
        alunoId: 'a1',
      );

      await service.adicionarDieta(dieta);

      final snap = await firestore.collection('dietas').doc('d1').get();

      expect(snap.exists, true);
      expect(snap['nome'], 'Dieta Massa');
      expect(snap['personalId'], 'p1');
    });

    test('buscarDietaPorId deve retornar dieta válida', () async {
      await firestore.collection('dietas').doc('d2').set({
        'nome': 'Seca Rápida',
        'refeicoes': ['Ovos', 'Salada'],
        'observacoes': 'Poucas calorias',
        'restricoes': 'Sem açúcar',
        'personalId': 'p2',
        'alunoId': 'a2',
      });

      final res = await service.buscarDietaPorId('d2');

      expect(res, isNotNull);
      expect(res!.nome, 'Seca Rápida');
      expect(res.restricoes, 'Sem açúcar');
    });

    test('buscarDietaPorId deve retornar null quando não existir', () async {
      final res = await service.buscarDietaPorId('naoExiste');

      expect(res, isNull);
    });

    test('listarDietas deve retornar todas as dietas', () async {
      await firestore.collection('dietas').add({
        'nome': 'Dieta 1',
        'refeicoes': ['Banana'],
        'observacoes': '',
        'restricoes': '',
        'personalId': 'p1',
        'alunoId': 'a1',
      });

      await firestore.collection('dietas').add({
        'nome': 'Dieta 2',
        'refeicoes': ['Peito de frango'],
        'observacoes': '',
        'restricoes': '',
        'personalId': 'p2',
        'alunoId': 'a2',
      });

      final lista = await service.listarDietas();

      expect(lista.length, 2);
    });

    test('atualizarDieta deve alterar os dados', () async {
      await firestore.collection('dietas').doc('d3').set({
        'nome': 'Antiga',
        'refeicoes': [],
        'observacoes': '',
        'restricoes': '',
        'personalId': 'p1',
        'alunoId': 'a1',
      });

      final dietaAtualizada = Dieta(
        id: 'd3',
        nome: 'Nova Dieta',
        refeicoes: ['Ovos'],
        observacoes: 'Atualizada',
        restricoes: 'Nenhuma',
        personalId: 'p9',
        alunoId: 'a9',
      );

      await service.atualizarDieta(dietaAtualizada);

      final snap = await firestore.collection('dietas').doc('d3').get();

      expect(snap['nome'], 'Nova Dieta');
      expect(snap['personalId'], 'p9');
      expect(snap['alunoId'], 'a9');
    });

    test('deletarDieta deve remover documento', () async {
      await firestore.collection('dietas').doc('d4').set({
        'nome': 'Para Deletar',
        'refeicoes': [],
        'personalId': 'p1',
        'alunoId': 'a1',
      });

      await service.deletarDieta('d4');

      final snap = await firestore.collection('dietas').doc('d4').get();

      expect(snap.exists, false);
    });

    test('atribuirDieta deve adicionar alunoId', () async {
      await firestore.collection('dietas').doc('d5').set({
        'nome': 'Atribuir',
        'refeicoes': [],
        'personalId': 'p1',
        'alunoId': null,
      });

      await service.atribuirDieta('d5', 'aluno123');

      final snap = await firestore.collection('dietas').doc('d5').get();

      expect(snap['alunoId'], 'aluno123');
    });
  });
}
