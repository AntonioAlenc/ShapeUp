import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/progresso.dart';

class FirebaseProgressoService {
  final CollectionReference progressoRef =
      FirebaseFirestore.instance.collection('progresso');

  // Adicionar novo registro de progresso
  Future<void> adicionarProgresso(Progresso progresso) async {
    await progressoRef.doc(progresso.id).set(progresso.toMap());
  }

  // Buscar progresso por ID
  Future<Progresso?> buscarProgressoPorId(String id) async {
    final doc = await progressoRef.doc(id).get();
    if (doc.exists) {
      return Progresso.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Listar todos os registros de um aluno
  Future<List<Progresso>> listarProgressoPorAluno(String alunoId) async {
    final snapshot = await progressoRef
        .where('alunoId', isEqualTo: alunoId)
        .orderBy('data', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => Progresso.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Atualizar registro
  Future<void> atualizarProgresso(Progresso progresso) async {
    await progressoRef.doc(progresso.id).update(progresso.toMap());
  }

  // Deletar registro
  Future<void> deletarProgresso(String id) async {
    await progressoRef.doc(id).delete();
  }
}
