import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/treino.dart';
import '../servicos/treino_service.dart';

class TreinoAlunoTela extends StatelessWidget {
  const TreinoAlunoTela({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(
        child: Text(
          'Não autenticado',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: StreamBuilder<List<Treino>>(
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (context, i) {
              final t = lista[i];
              return Column(
                children: [
                  _cardTreino(context, t),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _cardTreino(BuildContext context, Treino t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do treino
          Text(
            t.nome,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Descrição
          if (t.descricao.isNotEmpty)
            Text(
              t.descricao,
              style: const TextStyle(color: Colors.white70),
            ),

          // Frequência
          if (t.frequencia.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                "Frequência: ${t.frequencia}",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),

          const SizedBox(height: 12),

          // Lista de exercícios (nome, séries, obs)
          ...t.exercicios.map(
                (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "${e['nome'] ?? ''} - ${e['series'] ?? ''}\nObs: ${e['observacao'] ?? ''}",
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Botão Finalizar
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // 🔹 Futuro: salvar no Firestore "concluidoEm"
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Treino "${t.nome}" finalizado!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Finalizar"),
            ),
          ),
        ],
      ),
    );
  }
}
