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

  // 🔹 Lista de avaliações simuladas (mantida por enquanto)
  final List<Map<String, dynamic>> _avaliacoes = [
    {"aluno": "João Silva", "estrelas": 4.5},
    {"aluno": "Maria Souza", "estrelas": 5.0},
    {"aluno": "Carlos Pereira", "estrelas": 4.0},
    {"aluno": "Ana Lima", "estrelas": 3.5},
    {"aluno": "Lucas Silveira", "estrelas": 4.0},
  ];

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
            : const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Icon(Icons.person, color: Colors.black),
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

  // 🔹 Tela inicial do personal
  Widget _telaInicio(BuildContext context) {
    // média das avaliações simuladas
    final double mediaAvaliacoes =
        _avaliacoes.fold(0.0, (sum, item) => sum + item["estrelas"]) /
            _avaliacoes.length;

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
          // Card de Gerenciar Alunos
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

          // 🔹 Card de Quantidade de Alunos (dinâmico do Firestore)
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
              final alunosResumo = alunos.take(4).toList();

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
                    for (var aluno in alunosResumo)
                      _linhaAluno(aluno['nome'] ?? "Sem nome"),
                    if (totalAlunos > 4)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () {
                            // 👉 abre a aba "Alunos"
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

          // Card de Avaliações
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AVALIAÇÕES :",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    5,
                        (index) => Icon(
                      index < mediaAvaliacoes
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    4,
                        (index) => const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, color: Colors.amber),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
