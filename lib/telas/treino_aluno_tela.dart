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
        body: Center(
            child: Text(
                'Não autenticado',
              style: TextStyle(color: Colors.white),
            ),
        ),
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
              child: Text(
                  'Nenhum treino atribuído',
                  style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final t = lista[i];
              return Card(
                color: Colors.grey[900],
                child:Theme(
                  data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                unselectedWidgetColor: Colors.amber,
                ),
                child: ExpansionTile(
                  iconColor: Colors.amber,
                  collapsedIconColor: Colors.amber,
                  title: Text(
                    t.nome,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    t.frequencia,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (t.descricao.isNotEmpty)
                            Text(
                              t.descricao,
                              style: const TextStyle(color: Colors.white),
                            ),
                          const SizedBox(height: 8),
                          const Text(
                                  'Exercícios:',
                                    style: TextStyle(fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                          const SizedBox(height: 4),
                          ...t.exercicios.map((e) => Row(
                                children: [
                                  const Icon(Icons.fitness_center, size: 16, color: Colors.amber),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(e, style:const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
