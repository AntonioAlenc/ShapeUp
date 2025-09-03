import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../servicos/auth_service.dart';

class LoginTela extends StatefulWidget {
  const LoginTela({super.key});

  @override
  State<LoginTela> createState() => _LoginTelaState();
}

class _LoginTelaState extends State<LoginTela> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final email = _emailController.text.trim();
      final senha = _senhaController.text;

      final user = await AuthService.instancia.entrarEmailSenha(
        email: email,
        senha: senha,
      );

      if (user == null) throw Exception('Falha inesperada.');

      // (Opcional) Exigir verificação de e-mail:
      // if (!AuthService.instancia.emailVerificado) {
      //   await AuthService.instancia.enviarVerificacaoEmail();
      //   if (!mounted) return;
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text('Verifique seu e-mail para confirmar o cadastro.'),
      //   ));
      // }

      // Busca o perfil para decidir rota
      final snap = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      final dados = snap.data() ?? {};
      final tipo = (dados['tipo'] ?? 'aluno').toString();

      final rota = (tipo == 'personal') ? '/menu-personal' : '/menu-aluno';

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(rota);
    } catch (e) {
      final msg = AuthService.instancia.traduzErro(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha no login: $msg')),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('imagens/LogoVazada.png', width: 150),
                  const SizedBox(height: 40),

                  // E-mail
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: const TextStyle(color: Colors.amber),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.amber),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o e-mail';
                      }
                      if (!value.contains('@')) return 'E-mail inválido';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Senha
                  TextFormField(
                    controller: _senhaController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: const TextStyle(color: Colors.amber),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.lock, color: Colors.amber),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe a senha';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/recuperacao'),
                      child: const Text(
                        'Esqueci minha senha',
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: _carregando ? null : _entrar,
                      child: _carregando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('ENTRAR',
                              style: TextStyle(color: Colors.black)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Não tem uma conta?',
                          style: TextStyle(color: Colors.white)),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/cadastro'),
                        child: const Text('Cadastre-se',
                            style: TextStyle(color: Colors.amber)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
