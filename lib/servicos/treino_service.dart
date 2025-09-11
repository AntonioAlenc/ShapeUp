import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/treino.dart';

class TreinoService {
  TreinoService._();
  static final TreinoService instancia = TreinoService._();

  final _col = FirebaseFirestore.instance.collection('treinos');

  Future<String> salvarTreino(Treino treino) async {
    final data = treino.toMap();
    final doc = await _col.add(data);
    return doc.id;
  }

  Future<void> atualizarTreino(String id, Treino treino) async {
    await _col.doc(id).update({
      ...treino.toMap(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> excluirTreino(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<Treino>> streamTreinosDoPersonal(String personalId) {
    return _col
        .where('personalId', isEqualTo: personalId)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Treino.fromDoc(d)).toList());
  }

  Stream<List<Treino>> streamTreinosDoAluno(String alunoId) {
    return _col
        .where('alunoId', isEqualTo: alunoId)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Treino.fromDoc(d)).toList());
  }

  Future<void> atribuirTreino(String treinoId, String alunoId) async {
    await _col.doc(treinoId).update({
      'alunoId': alunoId,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<Treino?> buscarPorId(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return Treino.fromDoc(doc);
  }
}
