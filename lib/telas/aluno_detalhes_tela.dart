import 'package:flutter/material.dart';
import 'treinos_personal_aluno_tela.dart';
import 'dietas_personal_aluno_tela.dart';

class AlunoDetalhesTela extends StatelessWidget {
  final String nomeAluno;

  const AlunoDetalhesTela({super.key, required this.nomeAluno});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Aluno: $nomeAluno"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _botaoMenu(
              context,
              titulo: "Treinos",
              icone: Icons.fitness_center,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TreinosPersonalAlunoTela(nomeAluno: nomeAluno),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _botaoMenu(
              context,
              titulo: "Dietas",
              icone: Icons.restaurant_menu,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DietasPersonalAlunoTela(nomeAluno: nomeAluno),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoMenu(BuildContext context,
      {required String titulo, required IconData icone, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icone, size: 28, color: Colors.black),
                const SizedBox(width: 12),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
