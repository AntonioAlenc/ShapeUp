import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TreinosPersonalAlunoTela extends StatefulWidget {
  final String nomeAluno;

  const TreinosPersonalAlunoTela({super.key, required this.nomeAluno});

  @override
  State<TreinosPersonalAlunoTela> createState() => _TreinosPersonalAlunoTelaState();
}

class _TreinosPersonalAlunoTelaState extends State<TreinosPersonalAlunoTela> {

  // Função para cadastrar treino no Firestore
  void _cadastrarTreino() {
    final nomeController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[800],  // Escurecendo o fundo do AlertDialog
        title: const Text(
          "Novo Treino",
          style: TextStyle(color: Colors.white),  // Texto do título branco
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              style: const TextStyle(color: Colors.white),  // Texto no campo branco
              decoration: const InputDecoration(
                labelText: "Nome do treino",
                labelStyle: TextStyle(color: Colors.white70), // Rótulo em cor clara
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 16),  // Aumentando o espaçamento entre os campos
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),  // Texto no campo branco
              maxLines: null,  // Permite quebra de linha
              decoration: const InputDecoration(
                labelText: "Descrição",
                labelStyle: TextStyle(color: Colors.white70), // Rótulo em cor clara
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
              // Salvar no Firestore
              final treinosRef = FirebaseFirestore.instance.collection('treinos');
              await treinosRef.add({
                'nome': nomeController.text,
                'descricao': descController.text,
                'dataCriacao': Timestamp.now(),
              });

              // Fechar o Dialog após salvar
              Navigator.pop(context);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.amber),
              foregroundColor: WidgetStateProperty.all(Colors.black),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  // Função para editar treino (similar ao cadastrar, mas atualiza)
  void _editarTreino(String treinoId) {
    final nomeController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[800],  // Escurecendo o fundo do AlertDialog
        title: const Text(
          "Editar Treino",
          style: TextStyle(color: Colors.white),  // Texto do título branco
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              style: const TextStyle(color: Colors.white),  // Texto no campo branco
              decoration: const InputDecoration(
                labelText: "Nome do treino",
                labelStyle: TextStyle(color: Colors.white70), // Rótulo em cor clara
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 16),  // Aumentando o espaçamento entre os campos
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),  // Texto no campo branco
              maxLines: null,  // Permite quebra de linha
              decoration: const InputDecoration(
                labelText: "Descrição",
                labelStyle: TextStyle(color: Colors.white70), // Rótulo em cor clara
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
              // Atualizar o treino no Firestore
              final treinosRef = FirebaseFirestore.instance.collection('treinos');
              await treinosRef.doc(treinoId).update({
                'nome': nomeController.text,
                'descricao': descController.text,
              });

              Navigator.pop(context);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.amber),
              foregroundColor: WidgetStateProperty.all(Colors.black),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Treinos de ${widget.nomeAluno}"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('treinos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar treinos"));
          }

          final treinos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: treinos.length,
            itemBuilder: (context, index) {
              final treino = treinos[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    treino['nome'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    treino['descricao'],
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.amber),
                    onPressed: () => _editarTreino(treino.id),
                  ),
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
