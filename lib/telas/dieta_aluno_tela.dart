import 'package:flutter/material.dart';

class DietaAlunoTela extends StatelessWidget {
  const DietaAlunoTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _blocoRefeicao(
            context,
            titulo: 'Café da Manhã',
            alimentos: [
              '2 Bananas',
              '20g de Aveia',
            ],
          ),
          _blocoRefeicao(
            context,
            titulo: 'Almoço',
            alimentos: [
              '120g de Arroz',
              '50g de Feijão',
              '180g de Frango',
              'Salada Livre',
              'Refri (Apenas 0)',
            ],
          ),
          _blocoRefeicao(
            context,
            titulo: 'Lanche da Tarde',
            alimentos: [
              '2 Fatias de Pão Integral',
              '10g de Muçarela',
              '20g de Whey',
            ],
          ),
          _blocoRefeicao(
            context,
            titulo: 'Jantar',
            alimentos: [
              'Omelete com 3 ovos',
              'Salada de tomate',
            ],
          ),
        ],
      ),
    );
  }

  Widget _blocoRefeicao(
      BuildContext context, {
        required String titulo,
        required List<String> alimentos,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          ...alimentos.map(
                (alimento) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                alimento,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$titulo marcado como feito!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Feito"),
            ),
          ),
        ],
      ),
    );
  }
}
//att