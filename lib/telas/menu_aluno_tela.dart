import 'package:flutter/material.dart';

class MenuAlunoTela extends StatelessWidget {
  const MenuAlunoTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Menu do Aluno"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _cardMenu(
              context,
              titulo: "Meus Treinos",
              icone: Icons.fitness_center,
              rota: "/treino-aluno",
            ),
            _cardMenu(
              context,
              titulo: "Minha Dieta",
              icone: Icons.restaurant,
              rota: "/dieta-aluno",
            ),
            _cardMenu(
              context,
              titulo: "Progresso",
              icone: Icons.show_chart,
              rota: "/progresso",
            ),
            _cardMenu(
              context,
              titulo: "Perfil",
              icone: Icons.person,
              rota: "/perfil",
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardMenu(BuildContext context,
      {required String titulo, required IconData icone, required String rota}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, rota),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 48, color: Colors.amber),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
