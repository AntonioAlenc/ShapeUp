import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TreinosPersonalAlunoTela extends StatefulWidget {
  final String nomeAluno;
  final String alunoId; 

  const TreinosPersonalAlunoTela({
    super.key,
    required this.nomeAluno,
    required this.alunoId,
  });

  @override
  State<TreinosPersonalAlunoTela> createState() => _TreinosPersonalAlunoTelaState();
}

class _TreinosPersonalAlunoTelaState extends State<TreinosPersonalAlunoTela> {
  void _cadastrarTreino() {
    final nomeController = TextEditingController();
    final descController = TextEditingController();
    List<Map<String, TextEditingController>> exercicios = [];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text("Novo Treino", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Nome do treino",
                    labelStyle: TextStyle(color: Colors.white70),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: "Descrição",
                    labelStyle: TextStyle(color: Colors.white70),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Exercícios", style: TextStyle(color: Colors.amber)),
                const SizedBox(height: 8),
                Column(
                  children: exercicios.asMap().entries.map((entry) {
                    final i = entry.key;
                    final ex = entry.value;
                    return Card(
                      color: Colors.grey[700],
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            TextField(
                              controller: ex["nome"],
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "Nome",
                                labelStyle: TextStyle(color: Colors.white70),
                              ),
                            ),
                            TextField(
                              controller: ex["series"],
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "Séries",
                                labelStyle: TextStyle(color: Colors.white70),
                              ),
                            ),
                            TextField(
                              controller: ex["obs"],
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: "Observação",
                                labelStyle: TextStyle(color: Colors.white70),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    exercicios.removeAt(i);
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      exercicios.add({
                        "nome": TextEditingController(),
                        "series": TextEditingController(),
                        "obs": TextEditingController(),
                      });
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.amber),
                  label: const Text("Adicionar exercício", style: TextStyle(color: Colors.amber)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.amber)),
            ),
            ElevatedButton(
              onPressed: () async {
                final listaEx = exercicios.map((ex) {
                  return {
                    "nome": ex["nome"]!.text.trim(),
                    "series": ex["series"]!.text.trim(),
                    "observacao": ex["obs"]!.text.trim(),
                  };
                }).where((ex) => ex["nome"]!.isNotEmpty).toList();

                if (nomeController.text.trim().isEmpty) return;

                final uid = FirebaseAuth.instance.currentUser!.uid;
                final treinosRef = FirebaseFirestore.instance.collection('treinos');

                await treinosRef.add({
                  'nome': nomeController.text.trim(),
                  'descricao': descController.text.trim(),
                  'exercicios': listaEx,
                  'alunoId': widget.alunoId,
                  'personalId': uid, 
                  'dataCriacao': Timestamp.now(),
                });

                nomeController.dispose();
                descController.dispose();
                for (var ex in exercicios) {
                  ex.values.forEach((c) => c.dispose());
                }

                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editarTreino(String treinoId, String nomeAtual, String descricaoAtual, List<Map<String, dynamic>> exerciciosAtuais) async {
    final nomeController = TextEditingController(text: nomeAtual);
    final descController = TextEditingController(text: descricaoAtual);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text("Editar Treino", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Nome do treino",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: "Descrição",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.amber)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.trim().isEmpty) return;

                final uid = FirebaseAuth.instance.currentUser!.uid; 

                await FirebaseFirestore.instance.collection('treinos').doc(treinoId).update({
                  'nome': nomeController.text.trim(),
                  'descricao': descController.text.trim(),
                  'exercicios': exerciciosAtuais,
                  'personalId': uid, 
                });

                nomeController.dispose();
                descController.dispose();

                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarExclusaoTreino(String treinoId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Excluir treino?", style: TextStyle(color: Colors.amber)),
        content: const Text("Esta ação não pode ser desfeita.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar", style: TextStyle(color: Colors.amber))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await FirebaseFirestore.instance.collection('treinos').doc(treinoId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Treino excluído")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Falha ao excluir: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Treinos de ${widget.nomeAluno}"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('treinos')
            .where('alunoId', isEqualTo: widget.alunoId)
            .where('personalId', isEqualTo: uid) 
            .snapshots(includeMetadataChanges: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erro: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          }

          final docs = (snapshot.data?.docs ?? []).toList();
          docs.sort((a, b) {
            final da = (a.data() as Map<String, dynamic>)['dataCriacao'];
            final db = (b.data() as Map<String, dynamic>)['dataCriacao'];
            final ta = da is Timestamp ? da.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
            final tb = db is Timestamp ? db.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
            return tb.compareTo(ta);
          });

          if (docs.isEmpty) {
            return const Center(
              child: Text("Nenhum treino cadastrado para este aluno", style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final treino = docs[index];
              final data = treino.data() as Map<String, dynamic>;
              final exercicios = List<Map<String, dynamic>>.from(data['exercicios'] ?? []);

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text((data['nome'] ?? "-").toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text((data['descricao'] ?? "-").toString(), style: const TextStyle(color: Colors.white70)),
                  children: [
                    ...exercicios.map((ex) => ListTile(
                      title: Text((ex['nome'] ?? '-').toString(), style: const TextStyle(color: Colors.amber)),
                      subtitle: Text("Séries: ${ex['series'] ?? '-'}\nObs: ${ex['observacao'] ?? '-'}", style: const TextStyle(color: Colors.white70)),
                    )),
                    const Divider(color: Colors.white12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: "Editar treino",
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () => _editarTreino(
                            treino.id,
                            (data['nome'] ?? "").toString(),
                            (data['descricao'] ?? "").toString(),
                            exercicios,
                          ),
                        ),
                        IconButton(
                          tooltip: "Excluir treino",
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarExclusaoTreino(treino.id),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cadastrarTreino,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
