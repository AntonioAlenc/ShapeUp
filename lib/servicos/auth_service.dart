import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final instancia = AuthService._();
  final _auth = FirebaseAuth.instance;

  User? get usuario => _auth.currentUser;
  Stream<User?> get fluxoUsuario => _auth.authStateChanges();

  Future<User?> entrarEmailSenha({
    required String email,
    required String senha,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    return cred.user;
  }

  Future<void> sair() => _auth.signOut();

  // ========== GERENCIAR PERFIL ==========
  Future<void> atualizarNome(String nome) async {
    if (usuario == null) return;
    await usuario!.updateDisplayName(nome.trim());
    await usuario!.reload();
  }

  Future<void> atualizarEmail({
    required String novoEmail,
    required String senhaAtual, // reautenticação exigida pelo Firebase
  }) async {
    if (usuario == null) return;
    final cred = EmailAuthProvider.credential(
      email: usuario!.email!,
      password: senhaAtual,
    );
    await usuario!.reauthenticateWithCredential(cred);
    await usuario!.updateEmail(novoEmail.trim());
    await usuario!.reload();
  }

  Future<void> atualizarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    if (usuario == null) return;
    final cred = EmailAuthProvider.credential(
      email: usuario!.email!,
      password: senhaAtual,
    );
    await usuario!.reauthenticateWithCredential(cred);
    await usuario!.updatePassword(novaSenha);
  }
}
