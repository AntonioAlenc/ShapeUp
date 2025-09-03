import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/treino.dart';
import 'firebase_lembrete_service.dart';


class FirebaseTreinoService {
  final CollectionReference treinosRef =
  FirebaseFirestore.instance.collection('treinos');

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // 🔹 Criar treino
  Future<void> adicionarTreino(Treino treino) async {
    await treinosRef.doc(treino.id).set(treino.toMap());
  }

  // 🔹 Buscar treino por ID
  Future<Treino?> buscarTreinoPorId(String id) async {
    final doc = await treinosRef.doc(id).get();
    if (doc.exists) {
      return Treino.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // 🔹 Listar todos os treinos
  Future<List<Treino>> listarTreinos() async {
    final snapshot = await treinosRef.get();
    return snapshot.docs
        .map((doc) => Treino.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // 🔹 Atualizar treino
  Future<void> atualizarTreino(Treino treino) async {
    await treinosRef.doc(treino.id).update(treino.toMap());
  }

  // 🔹 Deletar treino
  Future<void> deletarTreino(String id) async {
    await treinosRef.doc(id).delete();
  }

  // ---------------------------------------------------------------------------
  // 🔹 Atribuir treino a um aluno (subcoleção dentro de /users/{alunoUid})
  Future<void> atribuirTreinoParaAluno({
    required String treinoId,
    required String alunoUid,
    required List<int> diasSemana, // 1=Seg .. 7=Dom
    required String horarioHHmm,    // "07:30"
  }) async {
    final treinoDoc = await treinosRef.doc(treinoId).get();
    if (!treinoDoc.exists) return;

    final treino = Treino.fromMap(treinoDoc.data() as Map<String, dynamic>, treinoDoc.id);

    final atrib = await _db
        .collection('users').doc(alunoUid)
        .collection('treinosAtribuidos')
        .add({
      'treinoId': treino.id,
      'treinoNome': treino.nome,
      'exercicios': treino.exercicios.map((e) => e.toMap()).toList(),
      'diasSemana': diasSemana,
      'horario': horarioHHmm,
      'ativo': true,
      'atribuidoPor': _auth.currentUser?.uid ?? 'system',
      'atribuidoEm': FieldValue.serverTimestamp(),
    });

    // 🔔 agenda lembretes locais no dispositivo atual
    await FirebaseLembreteService.agendarParaDiasSemana(
      idBase: atrib.id.hashCode & 0x7fffffff,
      titulo: 'Treino: ${treino.nome}',
      mensagem: 'Hora do treino!',
      diasSemana: diasSemana,
      horarioHHmm: horarioHHmm,
    );
  }

  // 🔹 Listar treinos de um aluno (stream para UI reativa)
  Stream<List<Treino>> treinosDoAluno(String alunoUid) {
    return _db
        .collection('users').doc(alunoUid)
        .collection('treinosAtribuidos')
        .where('ativo', isEqualTo: true)
        .snapshots()
        .map((q) => q.docs.map((d) {
      final m = d.data();
      return Treino(
        id: m['treinoId'] ?? '',
        nome: m['treinoNome'] ?? '',
        descricao: m['descricao'] ?? '',
        frequencia: m['diasSemana']?.toString() ?? '',
        exercicios: (m['exercicios'] as List)
            .map((e) => Exercicio.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        alunoId: alunoUid,
        personalId: m['atribuidoPor'] ?? '',
      );
    }).toList());
  }

  // 🔹 Buscar UID do aluno pelo e-mail (para atribuição)
  Future<String?> buscarAlunoPorEmail(String email) async {
    if (email.isEmpty) return null;
    final q = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return q.docs.first.id;
  }
}
