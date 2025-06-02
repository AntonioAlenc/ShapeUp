import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/lembrete.dart';

class FirebaseLembreteService {
  final CollectionReference lembretesRef =
      FirebaseFirestore.instance.collection('lembretes');

  // Adicionar novo lembrete
  Future<void> adicionarLembrete(Lembrete lembrete) async {
    await lembretesRef.doc(lembrete.id).set(lembrete.toMap());
  }

  // Buscar lembrete por ID
  Future<Lembrete?> buscarLembretePorId(String id) async {
    final doc = await lembretesRef.doc(id).get();
    if (doc.exists) {
      return Lembrete.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Listar lembretes de um aluno
  Future<List<Lembrete>> listarLembretesPorAluno(String alunoId) async {
    final snapshot = await lembretesRef
        .where('alunoId', isEqualTo: alunoId)
        .orderBy('horario', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => Lembrete.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Atualizar lembrete
  Future<void> atualizarLembrete(Lembrete lembrete) async {
    await lembretesRef.doc(lembrete.id).update(lembrete.toMap());
  }

  // Deletar lembrete
  Future<void> deletarLembrete(String id) async {
    await lembretesRef.doc(id).delete();
  }
}
