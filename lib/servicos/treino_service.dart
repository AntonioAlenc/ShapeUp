import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/treino.dart';

class TreinoService {
  TreinoService._();
  static final TreinoService instancia = TreinoService._();

  final CollectionReference treinosRef = FirebaseFirestore.instance.collection('treinos');

  //Criar treino
  Future<String> salvarTreino(Treino treino) async {
    final doc = await treinosRef.add(treino.toMap());
    return doc.id;
  }

  //Atualziar treino existente
  Future<void> atualizarTreino(String id, Treino treino) async {
    await treinosRef.doc(id).update({
      ...treino.toMap(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  //Excluir treino
  Future<void> excluirTreino(String id) async {
    await treinosRef.doc(id).delete();
  }

  // Buscar treino por ID
  Future<Treino?> buscarPorId(String id) async {
    final doc = await treinosRef.doc(id).get();
    if (!doc.exists) return null;
    return Treino.fromDoc(doc);
  }

  // Stream: treinos do personal
  Stream<List<Treino>> streamTreinosDoPersonal(String personalId) {
    return treinosRef
        .where('personalId', isEqualTo: personalId)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Treino.fromDoc(d)).toList());
  }

  // Stream: treinos atribuídos ao aluno
  Stream<List<Treino>> streamTreinosDoAluno(String alunoId) {
    return treinosRef
        .where('alunoId', isEqualTo: alunoId)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Treino.fromDoc(d)).toList());
  }

  // Atribuir treino ao aluno
  Future<void> atribuirTreino(String treinoId, String alunoId) async {
    await treinosRef.doc(treinoId).update({
      'alunoId': alunoId,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  // Remover atribuição de treino
  Future<void> removerAtribuicao(String treinoId) async {
    await treinosRef.doc(treinoId).update({
      'alunoId': null,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }
}