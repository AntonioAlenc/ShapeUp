import 'package:flutter_test/flutter_test.dart';
import 'package:shapeup/modelos/progresso.dart';

void main() {
  group('Progresso Model Tests', () {
    test('toMap() deve converter corretamente', () {
      final progresso = Progresso(
        id: '123',
        alunoId: 'aluno1',
        sexo: 'masculino',
        peso: 80.5,
        altura: 1.75,
        medidas: {
          'bracoDireito': 35.0,
          'coxaEsquerda': 60.0,
          'cintura': 82.0,
        },
        imagemUrl: 'http://img.com/foto.png',
        observacoes: 'evoluindo bem',
        data: DateTime(2024, 1, 1),
        criadoEm: DateTime(2024, 1, 1, 12, 0),
        atualizadoEm: DateTime(2024, 1, 2, 12, 0),
      );

      final map = progresso.toMap();

      expect(map['alunoId'], 'aluno1');
      expect(map['sexo'], 'masculino');
      expect(map['peso'], 80.5);
      expect(map['altura'], 1.75);
      expect(map['medidas']['bracoDireito'], 35.0);
      expect(map['imagemUrl'], 'http://img.com/foto.png');
      expect(map['observacoes'], 'evoluindo bem');
    });

    test('fromMap() deve criar objeto corretamente', () {
      final map = {
        'alunoId': 'aluno99',
        'sexo': 'feminino',
        'peso': 60,
        'altura': 1.62,
        'medidas': {
          'bracoEsquerdo': 28,
          'cintura': 70,
        },
        'imagemUrl': null,
        'observacoes': 'ok',
        'data': '2024-01-05T00:00:00.000Z',
        'criadoEm': '2024-01-05T10:00:00.000Z',
        'atualizadoEm': '2024-01-06T11:00:00.000Z',
      };

      final progresso = Progresso.fromMap(map, '999');

      expect(progresso.id, '999');
      expect(progresso.alunoId, 'aluno99');
      expect(progresso.sexo, 'feminino');
      expect(progresso.peso, 60.0);
      expect(progresso.altura, 1.62);
      expect(progresso.medidas['bracoEsquerdo'], 28.0);
      expect(progresso.medidas['cintura'], 70.0);
      expect(progresso.observacoes, 'ok');
      expect(progresso.data, isA<DateTime>());
    });
  });
}
