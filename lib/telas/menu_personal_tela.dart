import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class MenuPersonalTela extends StatelessWidget {
  const MenuPersonalTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Olá, Treinador!'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        elevation: 0,
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
              icone: Icons.group,
              titulo: 'Alunos',
              rota: '/alunos',
            ),
            _menuItem(
              context,
              icone: Icons.fitness_center,
              titulo: 'Criar Treino',
              rota: '/criar-treino',
            ),
            _menuItem(
              context,
              icone: Icons.restaurant_menu,
              titulo: 'Criar Dieta',
              rota: '/criar-dieta',
            ),
            _menuItem(
              context,
              icone: Icons.chat_bubble,
              titulo: 'WhatsApp',
              rota: 'whatsapp:',
            ),
            _menuItem(
              context,
              icone: Icons.bar_chart,
              titulo: 'Evolução',
              rota: '/evolucao-aluno',
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context,
      {required IconData icone,
        required String titulo,
        required String rota}) {
    return InkWell(
      onTap: () async {
        if (rota.startsWith('whatsapp:')) {
          final msg = Uri.encodeComponent('Olá! Vim pelo app ShapeUp.');
          final uri = Uri.parse('https://wa.me/?text=' + msg);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Navigator.pushNamed(context, rota);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 48, color: Colors.amber),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
