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

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    try {
      final user = await AuthService.instancia.entrarEmailSenha(
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
      );
      if (user == null) throw Exception("Falha inesperada.");

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!snap.exists) throw Exception("Usuário sem perfil.");

      final dados = snap.data() ?? {};
      final tipo = (dados['tipo'] ?? 'aluno').toString().toLowerCase();

      final rota = (tipo == 'personal') ? '/menu-personal' : '/menu-aluno';
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, rota);
    } catch (e) {
      String msg = e.toString();
      if (msg.contains("wrong-password")) {
        msg = "Senha incorreta.";
      } else if (msg.contains("user-not-found")) {
        msg = "Usuário não encontrado.";
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
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
                  Image.asset("imagens/LogoVazada.png", width: 150),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      labelStyle: TextStyle(color: Colors.amber),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber, width: 2),
                      ),
                    ),
                    validator: (v) => v == null || !v.contains("@")
                        ? "Informe um e-mail válido"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senhaController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Senha",
                      labelStyle: TextStyle(color: Colors.amber),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber, width: 2),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.length < 6 ? "Senha inválida" : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _carregando ? null : _entrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _carregando
                        ? const CircularProgressIndicator()
                        : const Text("ENTRAR"),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, "/cadastro"),
                    child: const Text("Criar conta",
                        style: TextStyle(color: Colors.amber)),
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
