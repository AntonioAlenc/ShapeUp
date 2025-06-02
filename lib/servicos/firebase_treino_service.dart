import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/treino.dart';

class FirebaseTreinoService {
  final CollectionReference treinosRef =
      FirebaseFirestore.instance.collection('treinos');

  // Criar treino
  Future<void> adicionarTreino(Treino treino) async {
    await treinosRef.doc(treino.id).set(treino.toMap());
  }

  // Buscar treino por ID
  Future<Treino?> buscarTreinoPorId(String id) async {
    final doc = await treinosRef.doc(id).get();
    if (doc.exists) {
      return Treino.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Listar todos os treinos
  Future<List<Treino>> listarTreinos() async {
    final snapshot = await treinosRef.get();
    return snapshot.docs
        .map((doc) => Treino.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Atualizar treino
  Future<void> atualizarTreino(Treino treino) async {
    await treinosRef.doc(treino.id).update(treino.toMap());
  }

  // Deletar treino
  Future<void> deletarTreino(String id) async {
    await treinosRef.doc(id).delete();
  }
}
