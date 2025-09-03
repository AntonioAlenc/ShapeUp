import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();
  static final instancia = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get usuario => _auth.currentUser;
  Stream<User?> get fluxoUsuario => _auth.authStateChanges();

  // ---------- CADASTRO ----------
  /// Cria usuário com e-mail/senha, envia verificação
  /// e grava/atualiza o perfil em /usuarios/{uid}
  Future<User?> cadastrarEmailSenha({
    required String nome,
    required String email,
    required String senha,
    String tipoUsuario = 'aluno', // << novo
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha.trim(),
    );

    // Atualiza displayName
    await cred.user?.updateDisplayName(nome.trim());

    // Envia verificação (não bloqueia o fluxo)
    try {
      await cred.user?.sendEmailVerification();
    } catch (_) {}

    // Perfil no Firestore
    await _db.collection('usuarios').doc(cred.user!.uid).set({
      'nome': nome.trim(),
      'email': email.trim(),
      'tipo': tipoUsuario, // << salvo
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return cred.user;
  }

  // ---------- LOGIN ----------
  Future<User?> entrarEmailSenha({
    required String email,
    required String senha,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha.trim(),
    );

    // carimbo de último login (idempotente)
    await _db.collection('usuarios').doc(cred.user!.uid).set({
      'email': cred.user!.email,
      'ultimoLoginEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return cred.user;
  }

  // ---------- LOGOUT ----------
  Future<void> sair() => _auth.signOut();

  // ---------- UTILIDADES ----------
  bool get emailVerificado => usuario?.emailVerified == true;

  Future<void> enviarVerificacaoEmail() async {
    final u = usuario;
    if (u != null && !u.emailVerified) {
      await u.sendEmailVerification();
    }
  }

  Future<void> enviarResetSenha(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ---------- GERENCIAR PERFIL ----------
  Future<void> atualizarNome(String nome) async {
    if (usuario == null) return;
    await usuario!.updateDisplayName(nome.trim());
    await _db.collection('usuarios').doc(usuario!.uid).set({
      'nome': nome.trim(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await usuario!.reload();
  }

  Future<void> atualizarEmail({
    required String novoEmail,
    required String senhaAtual,
  }) async {
    if (usuario == null) return;
    await _reauthComSenha(senhaAtual);
    await usuario!.updateEmail(novoEmail.trim());
    await _db.collection('usuarios').doc(usuario!.uid).set({
      'email': novoEmail.trim(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await usuario!.reload();
  }

  Future<void> atualizarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    if (usuario == null) return;
    await _reauthComSenha(senhaAtual);
    await usuario!.updatePassword(novaSenha.trim());
  }

  // ---------- PRIVADO ----------
  Future<void> _reauthComSenha(String senhaAtual) async {
    final u = usuario;
    if (u == null || u.email == null) return;
    final cred = EmailAuthProvider.credential(
      email: u.email!,
      password: senhaAtual.trim(),
    );
    await u.reauthenticateWithCredential(cred);
  }

  /// Converte erros do FirebaseAuth em mensagens amigáveis
  String traduzErro(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'user-disabled':
          return 'Usuário desativado.';
        case 'user-not-found':
          return 'Usuário não encontrado.';
        case 'wrong-password':
          return 'Senha incorreta.';
        case 'email-already-in-use':
          return 'E-mail já cadastrado.';
        case 'weak-password':
          return 'Senha muito fraca.';
        case 'invalid-credential':
          return 'Credencial incorreta ou expirada.';
        case 'operation-not-allowed':
          return 'Operação não permitida para este provedor.';
        case 'too-many-requests':
          return 'Muitas tentativas. Tente mais tarde.';
      }
    }
    return 'Falha inesperada. Tente novamente.';
  }
}
