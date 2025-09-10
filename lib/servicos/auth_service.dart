import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();
  static final AuthService instancia = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get usuarioAtual => _auth.currentUser;

  Stream<User?> get mudancasUsuario => _auth.authStateChanges();

  Future<User?> cadastrarEmailSenha({
    required String email,
    required String senha,
    required String nome,
    required String tipoUsuario,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Salva no Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'nome': nome,
        'email': email,
        'createdAt': DateTime.now(),
      });

      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

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
      throw Exception(e.message);
    }
  }

  Future<void> sair() async {
    await _auth.signOut();
  }

  traduzErro(Object e) {}
}
