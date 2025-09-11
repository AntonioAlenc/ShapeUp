import 'package:flutter/material.dart';
import '../servicos/auth_service.dart';

class CadastroTela extends StatefulWidget {
  const CadastroTela({super.key});

  @override
  State<CadastroTela> createState() => _CadastroTelaState();
}

class _CadastroTelaState extends State<CadastroTela> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String _tipoUsuario = 'aluno';
  bool _carregando = false;

  Future<void> _criarConta() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    try {
      await AuthService.instancia.cadastrarEmailSenha(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
        tipoUsuario: _tipoUsuario,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          _tipoUsuario == 'personal' ? '/menu-personal' : '/menu-aluno',
        );
      }
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('email-already-in-use')) {
        msg = 'Este e-mail já está cadastrado. Tente fazer login.';
      } else if (msg.contains('weak-password')) {
        msg = 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      } else if (msg.contains('invalid-email')) {
        msg = 'O e-mail informado é inválido.';
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
      appBar: AppBar(
        title: const Text("Criar Conta"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _campoTexto(_nomeController, "Nome completo"),
              const SizedBox(height: 16),
              _campoTexto(_emailController, "E-mail",
                  teclado: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _campoTexto(_senhaController, "Senha", senha: true),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _tipoUsuario,
                dropdownColor: Colors.grey[900],
                items: const [
                  DropdownMenuItem(value: "aluno", child: Text("Aluno")),
                  DropdownMenuItem(
                      value: "personal", child: Text("Personal Trainer")),
                ],
                onChanged: (v) => setState(() => _tipoUsuario = v ?? 'aluno'),
                decoration: const InputDecoration(
                  labelText: "Tipo de usuário",
                  labelStyle: TextStyle(color: Colors.amber),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _carregando ? null : _criarConta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _carregando
                    ? const CircularProgressIndicator()
                    : const Text("CRIAR CONTA"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text("Já tenho conta",
                    style: TextStyle(color: Colors.amber)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController c, String label,
      {bool senha = false, TextInputType teclado = TextInputType.text}) {
    return TextFormField(
      controller: c,
      obscureText: senha,
      keyboardType: teclado,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v == null || v.isEmpty ? "Preencha este campo" : null,
    );
  }
}
