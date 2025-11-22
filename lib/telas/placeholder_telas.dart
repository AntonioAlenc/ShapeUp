
import 'package:flutter/material.dart';

class AlunosTela extends StatelessWidget {
  const AlunosTela({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
        title: const Text('Alunos', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text('Tela de Alunos', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class CriarTreinoTela extends StatelessWidget {
  const CriarTreinoTela({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
        title: const Text('Criar Treino', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text('Tela para criação de treino', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class CriarDietaTela extends StatelessWidget {
  const CriarDietaTela({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
        title: const Text('Criar Dieta', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text('Tela para criação de dieta', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class EvolucaoAlunoTela extends StatelessWidget {
  const EvolucaoAlunoTela({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
        title: const Text('Evolução do Aluno', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text('Tela de evolução do aluno', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class LembretesTela extends StatelessWidget {
  const LembretesTela({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
        title: const Text('Lembretes', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text('Tela de lembretes', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
