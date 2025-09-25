import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DietasPersonalAlunoTela extends StatefulWidget {
  final String nomeAluno;
  final String alunoId; // 🔹 agora recebemos também o ID

  const DietasPersonalAlunoTela({
    super.key,
    required this.nomeAluno,
    required this.alunoId,
  });

  @override
  State<DietasPersonalAlunoTela> createState() => _DietasPersonalAlunoTelaState();
}

class _DietasPersonalAlunoTelaState extends State<DietasPersonalAlunoTela> {
  final CollectionReference dietasRef =
  FirebaseFirestore.instance.collection('dietas');

  void _cadastrarDieta() {
    final refeicaoController = TextEditingController();
    final detalhesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text("Nova Dieta", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: refeicaoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Refeição",
                  labelStyle: TextStyle(color: Colors.white70),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: detalhesController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: "Detalhes",
                  labelStyle: TextStyle(color: Colors.white70),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
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
                if (refeicaoController.text.trim().isEmpty) return;

                final uid = FirebaseAuth.instance.currentUser!.uid; // 🔹 personal logado

                await dietasRef.add({
                  'alunoId': widget.alunoId,
                  'personalId': uid, // 🔹 grava o personalId junto
                  'refeicao': refeicaoController.text.trim(),
                  'detalhes': detalhesController.text.trim(),
                  'dataCriacao': Timestamp.now(),
                });

                refeicaoController.dispose();
                detalhesController.dispose();

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

  void _editarDieta(String dietaId, String refeicaoAtual, String detalhesAtuais) {
    final refeicaoController = TextEditingController(text: refeicaoAtual);
    final detalhesController = TextEditingController(text: detalhesAtuais);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text("Editar Dieta", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: refeicaoController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Refeição",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: detalhesController,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: "Detalhes",
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
                if (refeicaoController.text.trim().isEmpty) return;

                await dietasRef.doc(dietaId).update({
                  'refeicao': refeicaoController.text.trim(),
                  'detalhes': detalhesController.text.trim(),
                });

                refeicaoController.dispose();
                detalhesController.dispose();

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

  Future<void> _confirmarExclusaoDieta(String dietaId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Excluir dieta?", style: TextStyle(color: Colors.amber)),
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
      await dietasRef.doc(dietaId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dieta excluída")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Falha ao excluir: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid; // 🔹 pega o personal logado

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Dietas de ${widget.nomeAluno}"),
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
        stream: dietasRef
            .where('alunoId', isEqualTo: widget.alunoId)
            .where('personalId', isEqualTo: uid) // 🔹 garante compatibilidade com regras
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
            return tb.compareTo(ta); // desc
          });

          if (docs.isEmpty) {
            return const Center(
              child: Text("Nenhuma dieta cadastrada para este aluno", style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final dietaDoc = docs[index];
              final data = dietaDoc.data() as Map<String, dynamic>;

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text((data['refeicao'] ?? "-").toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text((data['detalhes'] ?? "-").toString(),
                      style: const TextStyle(color: Colors.white70)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: "Editar",
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () => _editarDieta(
                          dietaDoc.id,
                          (data['refeicao'] ?? "").toString(),
                          (data['detalhes'] ?? "").toString(),
                        ),
                      ),
                      IconButton(
                        tooltip: "Excluir",
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarExclusaoDieta(dietaDoc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cadastrarDieta,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
