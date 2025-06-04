import 'package:flutter/material.dart';

class CadastroTela extends StatefulWidget {
  const CadastroTela({super.key});

  @override
  State<CadastroTela> createState() => _CadastroTelaState();
}

class _CadastroTelaState extends State<CadastroTela> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  String _tipoUsuario = 'aluno';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _campoTexto(
                  controller: _nomeController,
                  label: 'Nome completo',
                ),
                const SizedBox(height: 16),
                _campoTexto(
                  controller: _emailController,
                  label: 'E-mail',
                  teclado: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _campoTexto(
                  controller: _senhaController,
                  label: 'Senha',
                  senha: true,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text('Tipo de usuário:', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.grey[900],
                        value: _tipoUsuario,
                        items: const [
                          DropdownMenuItem(
                            value: 'aluno',
                            child: Text('Aluno'),
                          ),
                          DropdownMenuItem(
                            value: 'personal',
                            child: Text('Personal Trainer'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _tipoUsuario = value);
                          }
                        },
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.amber),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.amber),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.amber),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print('Criar conta: ${_emailController.text} como $_tipoUsuario');

                        final rota = _tipoUsuario == 'personal'
                            ? '/menu-personal'
                            : '/menu-aluno';

                        Navigator.pushReplacementNamed(context, rota);
                      }
                    },
                    child: const Text('CRIAR CONTA'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Já tenho conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    bool senha = false,
    TextInputType teclado = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: senha,
      keyboardType: teclado,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.amber),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.amber),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Preencha o campo' : null,
    );
  }
}
