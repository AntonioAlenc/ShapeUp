import 'package:flutter/material.dart';
import '../servicos/auth_service.dart';

class RecuperacaoSenhaTela extends StatefulWidget {
  const RecuperacaoSenhaTela({super.key});

  @override
  State<RecuperacaoSenhaTela> createState() => _RecuperacaoSenhaTelaState();
}

class _RecuperacaoSenhaTelaState extends State<RecuperacaoSenhaTela> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _carregando = false;

  Future<void> _enviarRecuperacao() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    try {
      await AuthService.instancia
          .recuperarSenha(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('E-mail de recuperação enviado!'),
          backgroundColor: Colors.amber,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  InputDecoration _dec(String label, IconData icone) => InputDecoration(
    hintText: label,
    hintStyle: const TextStyle(color: Colors.black54),
    prefixIcon: Icon(icone, color: Colors.black),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.black54),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.black, width: 2),
    ),
    contentPadding:
    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Icon(Icons.lock, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              "Esqueceu a Senha?",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Não se preocupe, enviaremos\num e-mail para você",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 40),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _dec("Digite seu e-mail", Icons.email),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite seu e-mail';
                          }
                          if (!value.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _carregando ? null : _enviarRecuperacao,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _carregando
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.amber,
                            ),
                          )
                              : const Text(
                            "Restaurar Senha",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text(
                          "Voltar ao Login",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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
