import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/mensagem.dart';

class FirebaseMensagemService {
  final CollectionReference mensagensRef =
      FirebaseFirestore.instance.collection('mensagens');

  // Enviar nova mensagem
  Future<void> enviarMensagem(Mensagem mensagem) async {
    await mensagensRef.doc(mensagem.id).set(mensagem.toMap());
  }

  // Buscar mensagens entre dois usuários
  Future<List<Mensagem>> buscarMensagens(String usuario1, String usuario2) async {
    final snapshot = await mensagensRef
        .where('remetenteId', whereIn: [usuario1, usuario2])
        .where('destinatarioId', whereIn: [usuario1, usuario2])
        .orderBy('dataHora', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => Mensagem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Buscar todas as mensagens de um usuário (opcional)
  Future<List<Mensagem>> listarMensagensDe(String usuarioId) async {
    final snapshot = await mensagensRef
        .where('remetenteId', isEqualTo: usuarioId)
        .orderBy('dataHora', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Mensagem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Deletar uma mensagem (opcional)
  Future<void> deletarMensagem(String id) async {
    await mensagensRef.doc(id).delete();
  }
}
