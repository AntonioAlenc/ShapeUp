import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VincularAlunoTela extends StatefulWidget {
  const VincularAlunoTela({super.key});

  @override
  State<VincularAlunoTela> createState() => _VincularAlunoTelaState();
}

class _VincularAlunoTelaState extends State<VincularAlunoTela> {
  final _formKey = GlobalKey<FormState>();
  final _uidAlunoController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _uidAlunoController.dispose();
    super.dispose();
  }

  Future<void> _vincularAluno() async {
    if (!_formKey.currentState!.validate()) return;

    final personalId = FirebaseAuth.instance.currentUser?.uid;
    if (personalId == null) return;

    final uidAluno = _uidAlunoController.text.trim();

    setState(() => _carregando = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(uidAluno);
      final doc = await docRef.get();

      if (!doc.exists || (doc.data()?['tipo'] != 'aluno')) {
        throw Exception("UID inválido ou não é um aluno.");
      }

      await docRef.update({
        'personalId': personalId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Aluno vinculado com sucesso!')),
        );
        Navigator.pop(context);
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

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.amber),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.amber),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.amber, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vincular Aluno")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _uidAlunoController,
                style: const TextStyle(color: Colors.white),
                decoration: _dec("UID do Aluno"),
                validator: (v) =>
                v == null || v.isEmpty ? "Digite o UID do aluno" : null,
              ),
              const SizedBox(height: 20),
              _carregando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _vincularAluno,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 32,
                  ),
                ),
                child: const Text("Vincular"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
