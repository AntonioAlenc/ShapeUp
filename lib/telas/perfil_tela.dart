import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../servicos/auth_service.dart';
import 'login_tela.dart';

class PerfilTela extends StatefulWidget {
  const PerfilTela({super.key});

  @override
  State<PerfilTela> createState() => _PerfilTelaState();
}

class _PerfilTelaState extends State<PerfilTela> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _idadeController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();

  User? get user => AuthService.instancia.usuarioAtual;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (snap.exists) {
      final data = snap.data()!;
      _nomeController.text = data['nome'] ?? '';
      _idadeController.text = data['idade']?.toString() ?? '';
      _pesoController.text = data['peso']?.toString() ?? '';
      _alturaController.text = data['altura']?.toString() ?? '';
      setState(() {});
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'nome': _nomeController.text,
      'idade': int.tryParse(_idadeController.text),
      'peso': double.tryParse(_pesoController.text),
      'altura': double.tryParse(_alturaController.text),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Perfil atualizado!")),
    );
  }

  Future<void> _logout() async {
    await AuthService.instancia.sair();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginTela()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meu Perfil"),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: "Nome"),
                validator: (v) =>
                    v != null && v.isNotEmpty ? null : "Digite seu nome",
              ),
              TextFormField(
                controller: _idadeController,
                decoration: const InputDecoration(labelText: "Idade"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _pesoController,
                decoration: const InputDecoration(labelText: "Peso (kg)"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _alturaController,
                decoration: const InputDecoration(labelText: "Altura (m)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _salvar, child: const Text("Salvar")),
            ],
          ),
        ),
      ),
    );
  }
}
