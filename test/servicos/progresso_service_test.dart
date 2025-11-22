import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:shapeup/servicos/firebase_progresso_service.dart';
import 'package:shapeup/modelos/progresso.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirebaseProgressoService service;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    firestore = FakeFirebaseFirestore();

    // Agora usando o construtor .test() que NÃO acessa Firebase real
    service = FirebaseProgressoService.test(firestore);
  });

  group('FirebaseProgressoService - Testes', () {
    test('adicionarProgresso deve criar registro corretamente', () async {
      final progresso = Progresso(
        id: 'p1',
        alunoId: 'aluno1',
        sexo: 'masculino',
        peso: 80.2,
        altura: 1.75,
        medidas: {
          'bracoDireito': 35.0,
          'cintura': 90.0,
        },
        imagemUrl: null,
        observacoes: 'ok',
        data: DateTime(2024, 1, 1),
        criadoEm: DateTime(2024, 1, 1),
      );

      await service.adicionarProgresso(progresso);

      final snap = await firestore.collection('progresso').doc('p1').get();

      expect(snap.exists, true);
      expect(snap['alunoId'], 'aluno1');
      expect(snap['peso'], 80.2);
      expect(snap['medidas']['bracoDireito'], 35.0);
    });

    test('buscarProgressoPorId deve retornar Progresso quando existir', () async {
      await firestore.collection('progresso').doc('p2').set({
        'alunoId': 'aluno2',
        'sexo': 'feminino',
        'peso': 60.0,
        'altura': 1.62,
        'medidas': {'cintura': 70.0},
        'data': DateTime(2024, 1, 1).toIso8601String(),
        'criadoEm': DateTime(2024, 1, 1).toIso8601String(),
      });

      final res = await service.buscarProgressoPorId('p2');

      expect(res, isNotNull);
      expect(res!.alunoId, 'aluno2');
      expect(res.medidas['cintura'], 70.0);
    });

    test('buscarProgressoPorId deve retornar null quando não existir', () async {
      final res = await service.buscarProgressoPorId('x999');
      expect(res, isNull);
    });

    test('listarProgressoPorAluno deve retornar lista correta', () async {
      await firestore.collection('progresso').add({
        'alunoId': 'a1',
        'sexo': 'm',
        'peso': 80,
        'altura': 1.80,
        'medidas': {'cintura': 90},
        'data': DateTime(2024, 1, 1).toIso8601String(),
        'criadoEm': DateTime(2024, 1, 1).toIso8601String(),
      });

      await firestore.collection('progresso').add({
        'alunoId': 'a1',
        'sexo': 'm',
        'peso': 81,
        'altura': 1.80,
        'medidas': {'cintura': 89},
        'data': DateTime(2024, 1, 2).toIso8601String(),
        'criadoEm': DateTime(2024, 1, 2).toIso8601String(),
      });

      final lista = await service.listarProgressoPorAluno('a1');

      expect(lista.length, 2);
      expect(lista[0].peso, 80);
      expect(lista[1].peso, 81);
    });

    test('atualizarProgresso deve alterar os dados', () async {
      await firestore.collection('progresso').doc('p3').set({
        'alunoId': 'a1',
        'sexo': 'm',
        'peso': 80,
        'altura': 1.80,
        'medidas': {'cintura': 90},
        'data': DateTime(2024, 1, 1).toIso8601String(),
        'criadoEm': DateTime(2024, 1, 1).toIso8601String(),
      });

      final prog = Progresso(
        id: 'p3',
        alunoId: 'a1',
        sexo: 'm',
        peso: 82,
        altura: 1.80,
        medidas: {'cintura': 88},
        data: DateTime(2024, 1, 1),
        criadoEm: DateTime(2024, 1, 1),
      );

      await service.atualizarProgresso(prog);

      final snap = await firestore.collection('progresso').doc('p3').get();
      expect(snap['peso'], 82);
      expect(snap['medidas']['cintura'], 88);
    });

    test('deletarProgresso deve remover registro', () async {
      await firestore.collection('progresso').doc('p4').set({
        'alunoId': 'a1',
        'peso': 80,
      });

      await service.deletarProgresso('p4');

      final snap = await firestore.collection('progresso').doc('p4').get();
      expect(snap.exists, false);
    });
  });
}
