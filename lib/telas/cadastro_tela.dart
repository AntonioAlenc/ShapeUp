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
  bool _aceitouTermos = false; // 🔹 novo controle do checkbox

  Future<void> _criarConta() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Você precisa aceitar os Termos & Privacidade."),
      ));
      return;
    }

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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Topo amarelo com título
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Vamos",
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "Criar",
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Sua Conta",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 🔹 Formulário
            Expanded(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _dec("Nome completo", Icons.person),
                          validator: (v) => v == null || v.isEmpty
                              ? "Preencha este campo"
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          decoration: _dec("E-mail", Icons.email),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Preencha este campo";
                            }
                            if (!v.contains("@")) return "E-mail inválido";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _senhaController,
                          style: const TextStyle(color: Colors.white),
                          obscureText: true,
                          decoration: _dec("Senha", Icons.lock),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Preencha este campo";
                            }
                            if (v.length < 6) return "Mínimo 6 caracteres";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _tipoUsuario,
                          dropdownColor: Colors.black,
                          style: const TextStyle(color: Colors.white),
                          items: const [
                            DropdownMenuItem(
                              value: "aluno",
                              child: Text("Aluno",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: "personal",
                              child: Text("Personal Trainer",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _tipoUsuario = v ?? 'aluno'),
                          decoration: InputDecoration(
                            hintText: "Aluno ou Treinador",
                            hintStyle: const TextStyle(color: Colors.amber),
                            prefixIcon:
                            const Icon(Icons.people, color: Colors.amber),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                              const BorderSide(color: Colors.amber),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: Colors.amber, width: 2),
                            ),
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 🔹 Checkbox Termos
                        CheckboxListTile(
                          value: _aceitouTermos,
                          onChanged: (v) =>
                              setState(() => _aceitouTermos = v ?? false),
                          title: const Text.rich(
                            TextSpan(
                              text: "Eu aceito os ",
                              style: TextStyle(color: Colors.white70),
                              children: [
                                TextSpan(
                                  text: "Termos & Privacidade",
                                  style: TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.amber,
                          checkColor: Colors.black,
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _carregando ? null : _criarConta,
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
                              "Cadastrar",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, '/login'),
                          child: const Text(
                            "Possui uma conta? Entrar",
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
            ),
          ],
        ),
      ),
    );
  }
}
//att