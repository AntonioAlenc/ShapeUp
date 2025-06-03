import 'package:flutter/material.dart';

class MenuAlunoTela extends StatelessWidget {
  const MenuAlunoTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Olá, Aluno!'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _menuItem(
              context,
              icone: Icons.fitness_center,
              titulo: 'Treinos',
              cor: Colors.blue,
              rota: '/treinos',
            ),
            _menuItem(
              context,
              icone: Icons.restaurant_menu,
              titulo: 'Dieta',
              cor: Colors.green,
              rota: '/dieta',
            ),
            _menuItem(
              context,
              icone: Icons.bar_chart,
              titulo: 'Progresso',
              cor: Colors.purple,
              rota: '/progresso',
            ),
            _menuItem(
              context,
              icone: Icons.chat,
              titulo: 'Chat',
              cor: Colors.teal,
              rota: '/chat',
            ),
            _menuItem(
              context,
              icone: Icons.alarm,
              titulo: 'Lembretes',
              cor: Colors.deepOrange,
              rota: '/lembretes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context,
      {required IconData icone,
      required String titulo,
      required Color cor,
      required String rota}) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, rota);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 48, color: cor),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 16,
                color: cor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
