import 'package:flutter/material.dart';

class AlunosTela extends StatelessWidget {
  const AlunosTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Meus Alunos"),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          "Lista de alunos em breve...",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
