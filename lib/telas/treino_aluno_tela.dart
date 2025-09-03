import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modelos/treino.dart';
import '../servicos/firebase_treino_service.dart';

class TreinoAlunoTela extends StatelessWidget {
  const TreinoAlunoTela({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final _service = FirebaseTreinoService();

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
      body: StreamBuilder<List<Treino>>(
        stream: _service.treinosDoAluno(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum treino atribuído',
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
                exibirBotaoFinalizar: true,
              );
            },
          );
        },
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
          // TODO: implementar navegação real
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
                  // TODO: registrar conclusão do treino no Firestore
                  ScaffoldMessenger.of(_scaffoldKey.currentContext!)
                      .showSnackBar(const SnackBar(
                    content: Text('Treino finalizado!'),
                  ));
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

// 🔑 Para usar SnackBar corretamente dentro de StatelessWidget,
// podemos declarar uma GlobalKey:
final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
GlobalKey<ScaffoldMessengerState>();
