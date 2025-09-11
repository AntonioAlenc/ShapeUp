import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../modelos/treino.dart';
import '../servicos/treino_service.dart';

class TreinoAlunoTela extends StatelessWidget {
  const TreinoAlunoTela({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Não autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Treinos')),
      body: StreamBuilder<List<Treino>>(
        stream: TreinoService.instancia.streamTreinosDoAluno(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return const Center(
              child: Text('Nenhum treino atribuído',
                  style: TextStyle(color: Colors.white)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final t = lista[i];
              return Card(
                child: ExpansionTile(
                  title: Text(t.nome),
                  subtitle: Text(t.frequencia),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (t.descricao.isNotEmpty) Text(t.descricao),
                          const SizedBox(height: 8),
                          const Text('Exercícios:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          ...t.exercicios.map((e) => Row(
                                children: [
                                  const Icon(Icons.fitness_center, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(e)),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
