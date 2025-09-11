import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();
  static final AuthService instancia = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Usuário atual logado
  User? get usuarioAtual => _auth.currentUser;

  /// Stream para ouvir mudanças de login/logout
  Stream<User?> get mudancasUsuario => _auth.authStateChanges();

  /// Cadastro com e-mail e senha
  Future<User?> cadastrarEmailSenha({
    required String email,
    required String senha,
    required String nome,
    required String tipoUsuario, // "aluno" ou "personal"
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final uid = cred.user!.uid;

      // salva no Firestore
      await _db.collection('users').doc(uid).set({
        'nome': nome,
        'email': email,
        'tipo': tipoUsuario,
        'idade': null,
        'peso': null,
        'altura': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return cred.user;
    } on FirebaseAuthException catch (e) {
      // repassa erro traduzido
      throw Exception(e.code);
    }
  }

  /// Login com e-mail e senha
  Future<User?> entrarEmailSenha({
    required String email,
    required String senha,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  /// Logout
  Future<void> sair() async {
    await _auth.signOut();
  }
}
