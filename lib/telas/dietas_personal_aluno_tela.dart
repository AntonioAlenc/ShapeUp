import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DietasPersonalAlunoTela extends StatefulWidget {
  final String nomeAluno;
  final String alunoId;

  const DietasPersonalAlunoTela({
    super.key,
    required this.nomeAluno,
    required this.alunoId,
  });

  @override
  State<DietasPersonalAlunoTela> createState() =>
      _DietasPersonalAlunoTelaState();
}

class _DietasPersonalAlunoTelaState extends State<DietasPersonalAlunoTela>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final List<String> periodos = [
    "manha",
    "almoco",
    "lanche",
    "jantar",
  ];

  final List<String> periodosLabel = [
    "☀️ Manhã",
    "🍽 Almoço",
    "☕ Lanche",
    "🌙 Jantar",
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  void _cadastrarRefeicao(String periodo) {
    final textoController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Adicionar em ${periodo.toUpperCase()}",
          style: const TextStyle(color: Colors.amber),
        ),
        content: TextField(
          controller: textoController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Descrição da refeição",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            const Text("Cancelar", style: TextStyle(color: Colors.amber)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              if (textoController.text.trim().isEmpty) return;

              final uid = FirebaseAuth.instance.currentUser!.uid;

              await FirebaseFirestore.instance.collection("dietas").add({
                "alunoId": widget.alunoId,
                "personalId": uid,
                "periodo": periodo,
                "texto": textoController.text.trim(),
                "criadoEm": FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  void _editarRefeicao(String dietaId, String textoAtual) {
    final textoController = TextEditingController(text: textoAtual);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Editar Refeição",
            style: TextStyle(color: Colors.amber)),
        content: TextField(
          controller: textoController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Descrição",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
            focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            const Text("Cancelar", style: TextStyle(color: Colors.amber)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('dietas')
                  .doc(dietaId)
                  .update({
                "texto": textoController.text.trim(),
                "atualizadoEm": FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  void _excluirRefeicao(String dietaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
        const Text("Excluir?", style: TextStyle(color: Colors.amber)),
        content: const Text(
          "Isso não pode ser desfeito.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
              const Text("Cancelar", style: TextStyle(color: Colors.amber))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance.collection("dietas").doc(dietaId).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Dietas — ${widget.nomeAluno}"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          tabs: [
            for (final label in periodosLabel) Tab(text: label),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          final periodo = periodos[tabController.index];
          _cadastrarRefeicao(periodo);
        },
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          for (int i = 0; i < periodos.length; i++)
            _telaPeriodo(periodos[i], uid),
        ],
      ),
    );
  }

  Widget _telaPeriodo(String periodo, String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('dietas')
          .where('alunoId', isEqualTo: widget.alunoId)
          .where('personalId', isEqualTo: uid)
          .where('periodo', isEqualTo: periodo)
          .orderBy('criadoEm', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "Nenhuma refeição cadastrada",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i];
            final data = d.data() as Map<String, dynamic>;

            return Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(
                  data["texto"] ?? "",
                  style:
                  const TextStyle(color: Colors.white, fontSize: 16),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon:
                      const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () =>
                          _editarRefeicao(d.id, data["texto"] ?? ""),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _excluirRefeicao(d.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
