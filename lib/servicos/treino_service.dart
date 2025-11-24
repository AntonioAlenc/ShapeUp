import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/treino.dart';

class TreinoService {
  // ============================================================
  // SINGLETON PADRÃO
  // ============================================================
  TreinoService._private();
  static final instancia = TreinoService._private();

  // ============================================================
  // REFERÊNCIA PRINCIPAL
  // ============================================================
  late CollectionReference<Map<String, dynamic>> _ref =
  FirebaseFirestore.instance.collection('treinos');

  // ============================================================
  // CONSTRUTOR PARA TESTES COM FAKE FIRESTORE
  // ============================================================
  TreinoService.test(FirebaseFirestore fake) {
    _ref = fake.collection('treinos');
  }

  // ============================================================
  // INÍCIO DA SEMANA - SEM HORAS, SEM MINUTOS, SEM SEGUNDOS
  // ============================================================
  DateTime _inicioSemana(DateTime d) {
    // Zera horário 100%
    final hojeZerado = DateTime(d.year, d.month, d.day);

    // Segunda-feira da semana atual
    final segunda = hojeZerado.subtract(Duration(days: hojeZerado.weekday - 1));

    // Retorna exatamente segunda às 00:00:00.000
    return DateTime(segunda.year, segunda.month, segunda.day, 0, 0, 0, 0, 0);
  }

  // ============================================================
  // COMPARAR DATAS (SEM LEVAR HORÁRIO EM CONTA)
  // ============================================================
  bool _mesmaData(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ============================================================
  // SALVAR TREINO
  // ============================================================
  Future<String> salvarTreino(Treino t) async {
    final doc = await _ref.add(t.toMap());
    return doc.id;
  }

  // ============================================================
  // ATUALIZAR TREINO
  // ============================================================
  Future<void> atualizarTreino(String id, Treino treino) async {
    await _ref.doc(id).update(treino.toMap());
  }

  // ============================================================
  // EXCLUIR TREINO
  // ============================================================
  Future<void> excluirTreino(String id) async {
    await _ref.doc(id).delete();
  }

  // ============================================================
  // ATRIBUIR TREINO AO ALUNO
  // ============================================================
  Future<void> atribuirTreino(String treinoId, String alunoId) async {
    await _ref.doc(treinoId).update({'alunoId': alunoId});
  }

  // ============================================================
  // FINALIZAR TREINO — GUARDA A SEGUNDA-FEIRA CERTA
  // ============================================================
  Future<void> finalizarTreino(String treinoId) async {
    final agora = DateTime.now();
    final segunda = _inicioSemana(agora);

    print("FINALIZANDO TREINO");
    print("Data atual      : $agora");
    print("Segunda da semana: $segunda");

    await _ref.doc(treinoId).update({
      'concluido': true,
      'concluidoEm': Timestamp.fromDate(agora),
      'validadeSemana': Timestamp.fromDate(segunda),
    });
  }

  // ============================================================
  // RESET AUTOMÁTICO SEMANAL
  // ============================================================
  Future<void> _resetSemanal(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    final validade = (data['validadeSemana'] as Timestamp?)?.toDate();
    final segundaAtual = _inicioSemana(DateTime.now());

    if (validade != null && _mesmaData(validade, segundaAtual)) {
      return; // mesma semana → não reseta
    }

    // Semana mudou → resetar treino
    await doc.reference.update({
      'concluido': false,
      'concluidoEm': null,
      'validadeSemana': Timestamp.fromDate(segundaAtual),
    });
  }

  // ============================================================
  // RESET SEMANAL MANUAL (apenas se a UI precisar)
  // ============================================================
  Future<void> resetarTreinoSemana(String treinoId) async {
    final segundaAtual = _inicioSemana(DateTime.now());

    await _ref.doc(treinoId).update({
      'concluido': false,
      'concluidoEm': null,
      'validadeSemana': Timestamp.fromDate(segundaAtual),
    });
  }

  // ============================================================
  // STREAM DO PERSONAL
  // ============================================================
  Stream<List<Treino>> streamTreinosDoPersonal(String personalId) {
    return _ref
        .where('personalId', isEqualTo: personalId)
        .snapshots()
        .map((snap) {
      return snap.docs.map((e) => Treino.fromDoc(e)).toList();
    });
  }

  // ============================================================
  // STREAM DO ALUNO — COM RESET AUTOMÁTICO
  // ============================================================
  Stream<List<Treino>> streamTreinosDoAluno(String alunoId) {
    return _ref.where('alunoId', isEqualTo: alunoId).snapshots().asyncMap(
          (snap) async {
        final lista = <Treino>[];
        for (var doc in snap.docs) {
          await _resetSemanal(doc);
          lista.add(Treino.fromDoc(doc));
        }
        return lista;
      },
    );
  }

  // ============================================================
  // STREAM POR DIA — COM RESET AUTOMÁTICO
  // ============================================================
  Stream<List<Treino>> streamTreinosPorDia(
      String alunoId, String diaSemana) {
    return _ref
        .where('alunoId', isEqualTo: alunoId)
        .where('diaSemana', isEqualTo: diaSemana)
        .snapshots()
        .asyncMap((snap) async {
      final lista = <Treino>[];

      for (var doc in snap.docs) {
        await _resetSemanal(doc);
        lista.add(Treino.fromDoc(doc));
      }

      return lista;
    });
  }
}
