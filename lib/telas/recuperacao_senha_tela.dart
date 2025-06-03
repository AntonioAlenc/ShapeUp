import 'package:flutter/material.dart';

class RecuperacaoSenhaTela extends StatefulWidget {
  const RecuperacaoSenhaTela({super.key});

  @override
  State<RecuperacaoSenhaTela> createState() => _RecuperacaoSenhaTelaState();
}

class _RecuperacaoSenhaTelaState extends State<RecuperacaoSenhaTela> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Informe seu e-mail cadastrado para receber instruções de recuperação.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite seu e-mail';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Aqui você poderia chamar FirebaseAuth.instance.sendPasswordResetEmail(...)
                    print('Recuperar senha para: ${_emailController.text}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('E-mail de recuperação enviado!')),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('ENVIAR INSTRUÇÕES'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
