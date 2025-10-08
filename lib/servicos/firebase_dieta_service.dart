import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/dieta.dart';

class FirebaseDietaService {
  final CollectionReference dietasRef =
  FirebaseFirestore.instance.collection('dietas');

  // Adicionar dieta
  Future<void> adicionarDieta(Dieta dieta) async {
    await dietasRef.doc(dieta.id).set({
      ...dieta.toMap(),
      'criadoEm': FieldValue.serverTimestamp(), // 🔹 garante a ordenação
    });
  }

  // Buscar dieta por ID
  Future<Dieta?> buscarDietaPorId(String id) async {
    final doc = await dietasRef.doc(id).get();
    if (doc.exists) {
      return Dieta.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Listar todas as dietas
  Future<List<Dieta>> listarDietas() async {
    final snapshot = await dietasRef.get();
    return snapshot.docs
        .map((doc) => Dieta.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Atualizar dieta
  Future<void> atualizarDieta(Dieta dieta) async {
    await dietasRef.doc(dieta.id).update({
      ...dieta.toMap(),
      'atualizadoEm': FieldValue.serverTimestamp(), // 🔹 registra atualização
    });
  }

  // Deletar dieta
  Future<void> deletarDieta(String id) async {
    await dietasRef.doc(id).delete();
  }
  // Atribuir dieta ao aluno
  Future<void> atribuirDieta(String dietaId, String alunoId) async {
    await dietasRef.doc(dietaId).update({
      'alunoId': alunoId,
      'atualizadoEm': FieldValue.serverTimestamp(), // 🔹 registro de atualização
    });
  }

}
