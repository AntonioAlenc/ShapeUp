import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/usuario.dart';

class FirebaseUsuarioService {
  final CollectionReference usuariosRef =
      FirebaseFirestore.instance.collection('usuarios');

  // Criar novo usuário
  Future<void> adicionarUsuario(Usuario usuario) async {
    await usuariosRef.doc(usuario.id).set(usuario.toMap());
  }

  // Buscar um usuário por ID
  Future<Usuario?> buscarUsuarioPorId(String id) async {
    final doc = await usuariosRef.doc(id).get();
    if (doc.exists) {
      return Usuario.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Listar todos os usuários
  Future<List<Usuario>> listarUsuarios() async {
    final snapshot = await usuariosRef.get();
    return snapshot.docs
        .map((doc) => Usuario.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Atualizar usuário
  Future<void> atualizarUsuario(Usuario usuario) async {
    await usuariosRef.doc(usuario.id).update(usuario.toMap());
  }

  // Remover usuário
  Future<void> deletarUsuario(String id) async {
    await usuariosRef.doc(id).delete();
  }
}
