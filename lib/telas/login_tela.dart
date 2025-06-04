import 'package:flutter/material.dart';

class LoginTela extends StatefulWidget {
  const LoginTela({super.key});

  @override
  State<LoginTela> createState() => _LoginTelaState();
}

class _LoginTelaState extends State<LoginTela> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

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
                  Image.asset(
                    'imagens/LogoVazada.png',
                    width: 150,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: const TextStyle(color: Colors.amber),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.amber),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.amber, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.amber),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o e-mail';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senhaController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: const TextStyle(color: Colors.amber),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.amber),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.amber, width: 2),
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
                      onPressed: () {
                        Navigator.pushNamed(context, '/recuperacao');
                      },
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final email = _emailController.text;
                          final tipoUsuario = email.contains('personal') ? 'personal' : 'aluno';

                          if (tipoUsuario == 'personal') {
                            Navigator.pushReplacementNamed(context, '/menu-personal');
                          } else {
                            Navigator.pushReplacementNamed(context, '/menu-aluno');
                          }
                        }
                      },
                      child: const Text('ENTRAR', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Não tem uma conta?', style: TextStyle(color: Colors.white)),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/cadastro');
                        },
                        child: const Text(
                          'Cadastre-se',
                          style: TextStyle(color: Colors.amber),
                        ),
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
