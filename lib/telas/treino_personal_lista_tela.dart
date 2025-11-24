import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../modelos/treino.dart';
import '../servicos/treino_service.dart';
import 'treino_detalhe_tela.dart';

class TreinoPersonalListaTela extends StatefulWidget {
  const TreinoPersonalListaTela({super.key});

  @override
  State<TreinoPersonalListaTela> createState() => _TreinoPersonalListaTelaState();
}

class _TreinoPersonalListaTelaState extends State<TreinoPersonalListaTela>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final dias = const [
    "segunda",
    "terca",
    "quarta",
    "quinta",
    "sexta",
    "sabado",
    "domingo",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: dias.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _tabItem(String label) {
    return Tab(
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.amber,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text('Não autenticado', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Meus Treinos', style: TextStyle(color: Colors.amber)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.amber,
          tabs: dias.map((d) => _tabItem(d)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: dias.map((dia) {
          return StreamBuilder<List<Treino>>(
            stream: TreinoService.instancia.streamTreinosDoPersonal(uid),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final lista = (snap.data ?? [])
                  .where((t) => t.diaSemana == dia)
                  .toList();

              if (lista.isEmpty) {
                return Center(
                  child: Text(
                    'Sem treinos para ${dia.toUpperCase()}',
                    style: const TextStyle(color: Colors.white70),
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
                            Navigator.pushNamed(
                                context, '/treino-criar',
                                arguments: t);
                          } else if (v == 'atribuir') {
                            Navigator.pushNamed(
                                context, '/treino-atribuir',
                                arguments: t);
                          } else if (v == 'excluir') {
                            await TreinoService.instancia.excluirTreino(t.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Treino excluído')),
                              );
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'editar', child: Text('Editar')),
                          PopupMenuItem(
                              value: 'atribuir',
                              child: Text('Atribuir a aluno')),
                          PopupMenuItem(
                              value: 'excluir', child: Text('Excluir')),
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
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/treino-criar'),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}