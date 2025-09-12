import 'package:flutter/material.dart';
import 'aluno_detalhes_tela.dart';

class AlunosTela extends StatelessWidget {
  const AlunosTela({super.key});

  @override
  Widget build(BuildContext context) {
    final alunos = [
      {"nome": "João Silva", "idade": "21 anos", "objetivo": "Hipertrofia"},
      {"nome": "Maria Souza", "idade": "28 anos", "objetivo": "Emagrecimento"},
      {"nome": "Carlos Pereira", "idade": "35 anos", "objetivo": "Condicionamento"},
      {"nome": "Ana Lima", "idade": "24 anos", "objetivo": "Funcional"},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Meus Alunos"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alunos.length,
        itemBuilder: (context, index) {
          final aluno = alunos[index];
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
                aluno["nome"]!,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${aluno["idade"]} • ${aluno["objetivo"]}",
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.amber),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AlunoDetalhesTela(nomeAluno: aluno["nome"]!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
