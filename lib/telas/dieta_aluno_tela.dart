import 'package:flutter/material.dart';

class DietaAlunoTela extends StatelessWidget {
  const DietaAlunoTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Minha Dieta', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _blocoRefeicao(
            titulo: 'Café da manhã',
            alimentos: [
              'Aveia - 50g',
              'Banana - 1 unidade',
              'Clara de ovo - 3 unidades',
            ],
          ),
          _blocoRefeicao(
            titulo: 'Almoço',
            alimentos: [
              'Arroz integral - 100g',
              'Frango grelhado - 150g',
              'Brócolis cozido - 80g',
            ],
          ),
          _blocoRefeicao(
            titulo: 'Pré-treino',
            alimentos: [
              'Batata-doce - 120g',
              'Peito de frango - 100g',
            ],
          ),
          _blocoRefeicao(
            titulo: 'Jantar',
            alimentos: [
              'Ovos mexidos - 2 unidades',
              'Abobrinha refogada - 80g',
            ],
          ),
          _blocoRefeicao(
            titulo: 'Ceia',
            alimentos: [
              'Iogurte natural - 1 pote',
              'Castanhas - 20g',
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Treino'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Dieta'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
        onTap: (index) {
          // Implementar navegação entre abas se necessário
        },
      ),
    );
  }

  Widget _blocoRefeicao({
    required String titulo,
    required List<String> alimentos,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...alimentos.map(
            (alimento) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                alimento,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
