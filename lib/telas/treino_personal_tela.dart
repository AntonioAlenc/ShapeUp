import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/treino.dart';
import '../servicos/firebase_treino_service.dart';

class TreinoPersonalTela extends StatefulWidget {
  const TreinoPersonalTela({super.key});

  @override
  State<TreinoPersonalTela> createState() => _TreinoPersonalTelaState();
}

class _TreinoPersonalTelaState extends State<TreinoPersonalTela> {
  final _service = FirebaseTreinoService();
  final _auth = FirebaseAuth.instance;

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
        title: const Text(
          'Meus Treinos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Treino>>(
        stream: _listarMeusTreinos(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum treino cadastrado',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final treinos = snap.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: treinos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              final t = treinos[i];
              return _blocoTreino(
                titulo: t.nome,
                exercicios: t.exercicios
                    .map((e) =>
                '${e.nome}\nSéries: ${e.series}x${e.reps}\nDescanso: ${e.descansoSeg}s')
                    .toList(),
                aoEditar: () {
                  // TODO: abrir tela de edição
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Editar treino: ${t.nome}')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Retorna stream apenas dos treinos do treinador logado
  Stream<List<Treino>> _listarMeusTreinos() {
    final uid = _auth.currentUser?.uid ?? '';
    return _service.treinosRef
        .where('personalId', isEqualTo: uid)
        .snapshots()
        .map((q) =>
        q.docs.map((d) => Treino.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());
  }

  Widget _blocoTreino({
    required String titulo,
    required List<String> exercicios,
    required VoidCallback aoEditar,
  }) {
    return Container(
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
          ...exercicios.map(
                (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                e,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: aoEditar,
              icon: const Icon(Icons.edit, color: Colors.black),
              label: const Text('Editar', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
