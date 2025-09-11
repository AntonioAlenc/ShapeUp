import 'package:flutter/material.dart';

class MenuPersonalTela extends StatelessWidget {
  const MenuPersonalTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Menu do Personal"),
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
              titulo: "Gerenciar Treinos",
              icone: Icons.fitness_center,
              rota: "/treino-lista-personal",
            ),
            _cardMenu(
              context,
              titulo: "Gerenciar Dietas",
              icone: Icons.restaurant_menu,
              rota: "/dieta-personal",
            ),
            _cardMenu(
              context,
              titulo: "Alunos",
              icone: Icons.group,
              rota: "/alunos",
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
