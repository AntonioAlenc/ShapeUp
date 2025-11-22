import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/treino.dart';

class TreinoService {
  // Construtor padrão (produção)
  TreinoService({FirebaseFirestore? instance})
      : firestore = instance ?? FirebaseFirestore.instance;

  // Construtor exclusivo para testes (impede conexão com Firebase real)
  TreinoService.test(this.firestore);

  // Instância padrão (não afeta testes porque você usará o construtor test)
  static TreinoService instancia = TreinoService();

  // Firestore interno usado pelo serviço
  final FirebaseFirestore firestore;

  // Getter da coleção treinos
  CollectionReference get treinosRef =>
      firestore.collection('treinos');

  // Criar treino
  Future<String> salvarTreino(Treino treino) async {
    final doc = await treinosRef.add({
      ...treino.toMap(),
      'dataCriacao': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Atualizar treino existente
  Future<void> atualizarTreino(String id, Treino treino) async {
    await treinosRef.doc(id).update({
      ...treino.toMap(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  // Excluir treino
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
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => Treino.fromDoc(d)).toList());
  }

  // Stream: treinos atribuídos ao aluno
  Stream<List<Treino>> streamTreinosDoAluno(String alunoId) {
    return treinosRef
        .where('alunoId', isEqualTo: alunoId)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => Treino.fromDoc(d)).toList());
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
