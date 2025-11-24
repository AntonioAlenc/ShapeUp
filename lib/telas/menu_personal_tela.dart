import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'alunos_tela.dart';
import 'perfil_personal_tela.dart';
import 'vincular_aluno_tela.dart';

class MenuPersonalTela extends StatefulWidget {
  const MenuPersonalTela({super.key});

  @override
  State<MenuPersonalTela> createState() => _MenuPersonalTelaState();
}

class _MenuPersonalTelaState extends State<MenuPersonalTela> {
  int _indiceSelecionado = 0;

  late final List<Widget> _telas;

  @override
  void initState() {
    super.initState();
    _telas = [
      _telaInicio(context),
      const AlunosTela(),
      const PerfilPersonalTela(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _indiceSelecionado = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          _titulos[_indiceSelecionado],
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: _indiceSelecionado == 2
            ? []
            : [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _indiceSelecionado = 2;
                });
              },
              child: const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.person, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: _telas[_indiceSelecionado],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSelecionado,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Alunos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  final List<String> _titulos = [
    "Olá, Treinador",
    "Meus Alunos",
    "Perfil",
  ];

  Widget _telaInicio(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text("Não autenticado", style: TextStyle(color: Colors.white)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // -----------------------------
          // CARD GERENCIAR ALUNOS
          // -----------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  "Gerenciar Alunos",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VincularAlunoTela(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.amber,
                  ),
                  icon: const Icon(Icons.person_add),
                  label: const Text("Vincular Alunos"),
                ),
              ],
            ),
          ),

          // -----------------------------
          // LISTA DE ALUNOS
          // -----------------------------
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('personalId', isEqualTo: user.uid)
                .where('tipo', isEqualTo: 'aluno')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Nenhum aluno vinculado",
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }

              final alunos = snapshot.data!.docs;
              final totalAlunos = alunos.length;

              // MOSTRA ATÉ 10 ALUNOS
              final alunosResumo = alunos.take(10).toList();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quantia de Alunos : $totalAlunos alunos",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(color: Colors.black),
                    const SizedBox(height: 8),

                    // Lista de até 10 nomes
                    for (var aluno in alunosResumo)
                      _linhaAluno(aluno['nome'] ?? "Sem nome"),

                    if (totalAlunos > 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _indiceSelecionado = 1;
                            });
                          },
                          child: const Text(
                            "MAIS",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // ❌ AVALIAÇÕES REMOVIDO COMPLETAMENTE
        ],
      ),
    );
  }

  Widget _linhaAluno(String nome) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            nome,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
