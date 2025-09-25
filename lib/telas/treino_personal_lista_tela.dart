import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../modelos/treino.dart';
import '../servicos/treino_service.dart';
import 'treino_detalhe_tela.dart'; // 🔹 import necessário

class TreinoPersonalListaTela extends StatelessWidget {
  const TreinoPersonalListaTela({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Não autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Treinos'),
      ),
      body: StreamBuilder<List<Treino>>(
        stream: TreinoService.instancia.streamTreinosDoPersonal(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final lista = snap.data ?? [];

          if (lista.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum treino criado',
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
                child: ListTile(
                  title: Text(
                    t.nome,
                    style: const TextStyle(color: Colors.amber),
                  ),
                  subtitle: Text(
                    '${t.frequencia} • ${t.exercicios.length} exercícios',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'editar') {
                        Navigator.pushNamed(context, '/treino-criar',
                            arguments: t);
                      } else if (v == 'atribuir') {
                        Navigator.pushNamed(context, '/treino-atribuir',
                            arguments: t);
                      } else if (v == 'excluir') {
                        await TreinoService.instancia.excluirTreino(t.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Treino excluído')),
                          );
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'editar', child: Text('Editar')),
                      PopupMenuItem(
                          value: 'atribuir', child: Text('Atribuir a aluno')),
                      PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TreinoDetalheTela(treino: t),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/treino-criar'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
//att
