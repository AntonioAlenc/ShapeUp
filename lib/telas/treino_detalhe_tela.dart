import 'package:flutter/material.dart';
import '../modelos/treino.dart';

class TreinoDetalheTela extends StatelessWidget {
  final Treino treino;
  const TreinoDetalheTela({super.key, required this.treino});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(treino.nome),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: treino.exercicios.length,
        itemBuilder: (context, i) {
          final ex = treino.exercicios[i];
          return Card(
            color: Colors.grey[850],
            child: ListTile(
              title: Text(
                ex['nome'] ?? 'Exercício',
                style: const TextStyle(color: Colors.amber, fontSize: 16),
              ),
              subtitle: Text(
                "Séries: ${ex['series'] ?? '-'}\nObs: ${ex['observacao'] ?? '-'}",
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}
