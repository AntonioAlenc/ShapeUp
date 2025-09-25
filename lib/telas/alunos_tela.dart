import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'aluno_detalhes_tela.dart';

class AlunosTela extends StatelessWidget {
  const AlunosTela({super.key});

  @override
  Widget build(BuildContext context) {
    final personalId = FirebaseAuth.instance.currentUser?.uid;

    if (personalId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Não autenticado",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('tipo', isEqualTo: 'aluno')
            .where('personalId', isEqualTo: personalId)
            .snapshots(includeMetadataChanges: true),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const Center(
              child: Text(
                "Erro ao carregar alunos",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          var docs = snap.data?.docs ?? [];

          // 🔹 ordena os alunos pelo nome no Flutter
          docs.sort((a, b) {
            final nomeA = (a['nome'] ?? '').toString();
            final nomeB = (b['nome'] ?? '').toString();
            return nomeA.compareTo(nomeB);
          });

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum aluno vinculado",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final totalAlunos = docs.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Contador no topo
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Total de alunos vinculados: $totalAlunos",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              // 🔹 Lista de alunos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final alunoDoc = docs[index];
                    final aluno = alunoDoc.data() as Map<String, dynamic>;
                    final nome = aluno["nome"] ?? "Aluno sem nome";
                    final idade = aluno["idade"]?.toString() ?? "-";
                    final objetivo = aluno["objetivo"] ?? "-";
                    final alunoId = alunoDoc.id;

                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.amber,
                          child: Icon(Icons.person, color: Colors.black),
                        ),
                        title: Text(
                          nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "$idade • $objetivo",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.amber),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AlunoDetalhesTela(
                                nomeAluno: nome,
                                alunoId: alunoId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
