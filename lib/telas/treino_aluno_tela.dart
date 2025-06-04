import 'package:flutter/material.dart';

class TreinoAlunoTela extends StatelessWidget {
  const TreinoAlunoTela({super.key});

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
        title: const Text('Treinos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _blocoTreino(
            titulo: 'Peito/Ombros',
            exercicios: [
              'Supino Inclinado c/ Halteres\nSéries: 2x5-10\nIntervalo: 60s',
              'Crucifixo Inclinado na Polia\nSéries: 3x5-10\nIntervalo: 60s',
              'Supino Reto c/ Barra\nSéries: 2x10-15\nIntervalo: 120s',
              'Elevação Lateral c/ Halteres\nSéries: 4x6-8\nIntervalo: 90s',
              'Elevação Frontal c/ Corda\nSéries: 3x8-10\nIntervalo: 60s',
            ],
            exibirBotaoFinalizar: true,
          ),
          const SizedBox(height: 16),
          _blocoTreino(
            titulo: 'Costas/Abdominal',
            exercicios: [
              'Remada Curvada c/ Barra Reta\nSéries: 3x12\nIntervalo: 60s',
              'Abdominal Infra no Banco\nSéries: 3x15\nIntervalo: 45s',
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Treino completo'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Dieta Completa'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
        onTap: (index) {
          // Implementar navegação real com base no index
        },
      ),
    );
  }

  Widget _blocoTreino({
    required String titulo,
    required List<String> exercicios,
    bool exibirBotaoFinalizar = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 12),
          ...exercicios.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                e,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (exibirBotaoFinalizar)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica futura
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Finalizar'),
              ),
            ),
        ],
      ),
    );
  }
}
