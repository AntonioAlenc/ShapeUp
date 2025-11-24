import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/treino.dart';

class TreinoService {
  // ============================================================
  // SINGLETON PADRÃO
  // ============================================================
  TreinoService._private();
  static final instancia = TreinoService._private();

  // ============================================================
  // REFERÊNCIA PRINCIPAL (pode ser substituída em testes)
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
  // INÍCIO DA SEMANA (segunda-feira)
  // ============================================================
  DateTime _inicioSemana(DateTime d) {
    final segunda = d.subtract(Duration(days: d.weekday - 1));
    return DateTime(segunda.year, segunda.month, segunda.day);
  }

  // ============================================================
  // SALVAR
  // ============================================================
  Future<String> salvarTreino(Treino t) async {
    final doc = await _ref.add(t.toMap());
    return doc.id;
  }

  // ============================================================
  // ATUALIZAR
  // ============================================================
  Future<void> atualizarTreino(String id, Treino treino) async {
    await _ref.doc(id).update(treino.toMap());
  }

  // ============================================================
  // EXCLUIR
  // ============================================================
  Future<void> excluirTreino(String id) async {
    await _ref.doc(id).delete();
  }

  // ============================================================
  // ATRIBUIR ALUNO
  // ============================================================
  Future<void> atribuirTreino(String treinoId, String alunoId) async {
    await _ref.doc(treinoId).update({'alunoId': alunoId});
  }

  // ============================================================
  // FINALIZAR TREINO
  // ============================================================
  Future<void> finalizarTreino(String treinoId) async {
    final agora = DateTime.now();
    final segunda = _inicioSemana(agora);

    await _ref.doc(treinoId).update({
      'concluido': true,
      'concluidoEm': Timestamp.fromDate(agora),
      'validadeSemana': Timestamp.fromDate(segunda),
    });
  }

  // ============================================================
  // RESET SEMANAL AUTOMÁTICO
  // ============================================================
  Future<void> _resetSemanal(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final validade = (data['validadeSemana'] as Timestamp?)?.toDate();
    final segundaAtual = _inicioSemana(DateTime.now());

    if (validade != null && validade == segundaAtual) return;

    await doc.reference.update({
      'concluido': false,
      'concluidoEm': null,
      'validadeSemana': Timestamp.fromDate(segundaAtual),
    });
  }

  // ============================================================
  // STREAM DO PERSONAL
  // ============================================================
  Stream<List<Treino>> streamTreinosDoPersonal(String personalId) {
    return _ref.where('personalId', isEqualTo: personalId).snapshots().map(
          (snap) {
        return snap.docs.map((e) => Treino.fromDoc(e)).toList();
      },
    );
  }

  // ============================================================
  // STREAM DO ALUNO
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
  // STREAM POR DIA — para as abas
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
