import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/dieta.dart';

class FirebaseDietaService {
  // Instância Firestore (real ou fake)
  final FirebaseFirestore firestore;

  // Construtor padrão
  FirebaseDietaService() : firestore = FirebaseFirestore.instance;

  // Construtor especial para testes
  FirebaseDietaService.test(this.firestore);

  // Getter da coleção
  CollectionReference get dietasRef =>
      firestore.collection('dietas');

  // Adicionar dieta
  Future<void> adicionarDieta(Dieta dieta) async {
    await dietasRef.doc(dieta.id).set({
      ...dieta.toMap(),
      'criadoEm': FieldValue.serverTimestamp(),
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
      'atualizadoEm': FieldValue.serverTimestamp(),
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
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }
}
