import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../servicos/treino_service.dart';
import '../modelos/treino.dart';

class TreinoAlunoTela extends StatefulWidget {
  const TreinoAlunoTela({super.key});

  @override
  State<TreinoAlunoTela> createState() => _TreinoAlunoTelaState();
}

class _TreinoAlunoTelaState extends State<TreinoAlunoTela>
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

    // Selecionar aba do dia atual automaticamente
    final dow = DateTime.now().weekday - 1; // 0 = segunda
    if (dow >= 0 && dow < dias.length) {
      _tabController.index = dow;
    }
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

  // ---------------------------------------------------------
  // 🔥 Cartão visual do treino
  // ---------------------------------------------------------
  Widget _cardTreino(BuildContext context, Treino t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.concluido ? Colors.grey[850] : Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: t.concluido ? Colors.green : Colors.amber,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.nome,
            style: TextStyle(
              color: t.concluido ? Colors.green : Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          if (t.descricao.isNotEmpty)
            Text(
              t.descricao,
              style: const TextStyle(color: Colors.white70),
            ),

          if (t.frequencia.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                "Frequência: ${t.frequencia}",
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),

          const SizedBox(height: 12),

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

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: t.concluido
                  ? null
                  : () async {
                await TreinoService.instancia.finalizarTreino(t.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                        Text('Treino "${t.nome}" finalizado!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                t.concluido ? Colors.green : Colors.amber,
                foregroundColor:
                t.concluido ? Colors.white : Colors.black,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child:
              Text(t.concluido ? "Concluído ✔" : "Finalizar"),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔥 CONSTRUÇÃO PRINCIPAL
  // ---------------------------------------------------------
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
        const Text('Meus Treinos', style: TextStyle(color: Colors.amber)),
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
            stream: TreinoService.instancia.streamTreinosPorDia(uid, dia),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final lista = snap.data ?? [];

              if (lista.isEmpty) {
                return Center(
                  child: Text(
                    "Nenhum treino para ${dia.toUpperCase()}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lista.length,
                itemBuilder: (context, i) {
                  return Column(
                    children: [
                      _cardTreino(context, lista[i]),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
