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
  bool _lembrarMe = false; // 🔹 novo controle do checkbox

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

      // 🔹 Aqui você pode salvar a flag do "lembrar-me" em SharedPreferences
      // se quiser manter a sessão mesmo após fechar o app
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

  InputDecoration _dec(String label, IconData icone) => InputDecoration(
    hintText: label,
    hintStyle: const TextStyle(color: Colors.amber),
    prefixIcon: Icon(icone, color: Colors.amber),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.amber),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.amber, width: 2),
    ),
    contentPadding:
    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber, // fundo superior amarelo
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Image.asset("imagens/LogoVazada.png", width: 180),
            const SizedBox(height: 10),
            const Text(
              "FITNESS APP",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: _dec("E-mail", Icons.email),
                          validator: (v) => v == null || !v.contains("@")
                              ? "Informe um e-mail válido"
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _senhaController,
                          style: const TextStyle(color: Colors.white),
                          obscureText: true,
                          decoration: _dec("Senha", Icons.lock),
                          validator: (v) =>
                          v == null || v.length < 6 ? "Senha inválida" : null,
                        ),

                        // 🔹 Botão "Esqueci minha senha?"
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/recuperacao'),
                            child: const Text(
                              "Esqueci minha senha?",
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        // 🔹 Checkbox "Lembrar-me"
                        CheckboxListTile(
                          value: _lembrarMe,
                          onChanged: (v) =>
                              setState(() => _lembrarMe = v ?? false),
                          title: const Text(
                            "Lembrar-me",
                            style: TextStyle(color: Colors.white70),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.amber,
                          checkColor: Colors.black,
                          contentPadding: EdgeInsets.zero,
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _carregando ? null : _entrar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _carregando
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                                : const Text(
                              "ENTRAR",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, "/cadastro"),
                          child: const Text(
                            "Criar conta",
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
