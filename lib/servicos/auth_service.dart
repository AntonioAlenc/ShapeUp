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

  /// Função auxiliar para calcular idade
  int _calcularIdade(DateTime nascimento) {
    final hoje = DateTime.now();
    int idade = hoje.year - nascimento.year;
    if (hoje.month < nascimento.month ||
        (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
      idade--;
    }
    return idade;
  }

  /// Cadastro com e-mail e senha
  Future<User?> cadastrarEmailSenha({
    required String email,
    required String senha,
    required String nome,
    required String tipoUsuario, // "aluno" ou "personal"
    required DateTime? dataNascimento, // 🔹 novo parâmetro
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final uid = cred.user!.uid;

      // base comum para todos os usuários
      final baseData = {
        'nome': nome,
        'email': email,
        'tipo': tipoUsuario,
        'createdAt': FieldValue.serverTimestamp(),
        'peso': null,
        'altura': null,
        'fotoUrl': null,
        'dataNascimento': dataNascimento != null
            ? Timestamp.fromDate(dataNascimento)
            : null,
        'idade': dataNascimento != null ? _calcularIdade(dataNascimento) : null,
      };

      if (tipoUsuario == 'aluno') {
        await _db.collection('users').doc(uid).set({
          ...baseData,
          'sexo': null,
          'objetivo': null,
          'personalId': null,
        });
      } else if (tipoUsuario == 'personal') {
        await _db.collection('users').doc(uid).set({
          ...baseData,
          'telefone': null,
          'especialidade': null,
        });
      } else {
        // fallback genérico
        await _db.collection('users').doc(uid).set(baseData);
      }

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

  /// Recuperação de senha
  Future<void> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
}
