import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DietasPersonalAlunoTela extends StatefulWidget {
  final String nomeAluno;

  const DietasPersonalAlunoTela({super.key, required this.nomeAluno});

  @override
  State<DietasPersonalAlunoTela> createState() => _DietasPersonalAlunoTelaState();
}

class _DietasPersonalAlunoTelaState extends State<DietasPersonalAlunoTela> {

  final CollectionReference dietasRef = FirebaseFirestore.instance.collection('dietas');

  // Função para cadastrar dieta no Firestore
  void _cadastrarDieta() {
    final refeicaoController = TextEditingController();
    final detalhesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            "Nova Dieta",
            style: TextStyle(color: Colors.white),
          ),
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
                // Salvar no Firestore a dieta, associada ao nome do aluno
                await dietasRef.add({
                  'aluno': widget.nomeAluno, // Associando ao aluno
                  'refeicao': refeicaoController.text,
                  'detalhes': detalhesController.text,
                  'dataCriacao': Timestamp.now(), // Salvando a data de criação
                });

                if (mounted) Navigator.pop(context); // Evita erro de contexto após await
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.amber),
                foregroundColor: WidgetStateProperty.all(Colors.black),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  // Edição de dieta
  void _editarDieta(String dietaId) {
    final refeicaoController = TextEditingController();
    final detalhesController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text(
            "Editar Dieta",
            style: TextStyle(color: Colors.white),
          ),
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
                await dietasRef.doc(dietaId).update({
                  'refeicao': refeicaoController.text,
                  'detalhes': detalhesController.text,
                });

                if (mounted) Navigator.pop(context);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.amber),
                foregroundColor: WidgetStateProperty.all(Colors.black),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Dietas de ${widget.nomeAluno}"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dietasRef
            .where('aluno', isEqualTo: widget.nomeAluno)
            .orderBy('dataCriacao')
            .snapshots(), // Substituímos por consulta filtrada por aluno
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar dietas"));
          }

          final dietas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: dietas.length,
            itemBuilder: (context, index) {
              final dieta = dietas[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    dieta['refeicao'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    dieta['detalhes'],
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.amber),
                    onPressed: () => _editarDieta(dieta.id),
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
