import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// importe suas telas reais
import 'treino_aluno_tela.dart';
import 'dieta_aluno_tela.dart';
import 'progresso_tela.dart';
import 'perfil_aluno_tela.dart';

class MenuAlunoTela extends StatefulWidget {
  const MenuAlunoTela({super.key});

  @override
  State<MenuAlunoTela> createState() => _MenuAlunoTelaState();
}

class _MenuAlunoTelaState extends State<MenuAlunoTela> {
  int _indiceSelecionado = 0;
  String? numeroPersonal;

  // 🔹 valores simulados do progresso mensal
  final Map<String, double> valores = {
    "Jan": 15.0,
    "Fev": 12.0,
    "Mar": 18.0,
    "Abr": 25.0,
  };

  @override
  void initState() {
    super.initState();
    _buscarNumeroPersonal();
  }

  Future<void> _buscarNumeroPersonal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final alunoDoc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (alunoDoc.exists && alunoDoc.data()?['personalId'] != null) {
      final personalId = alunoDoc['personalId'];
      final personalDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(personalId)
          .get();

      if (personalDoc.exists && personalDoc.data()?['telefone'] != null) {
        setState(() {
          numeroPersonal = personalDoc['telefone'];
        });
      }
    }
  }

  Future<void> _abrirWhatsApp() async {
    if (numeroPersonal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seu personal não possui telefone cadastrado."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String numeroFormatado =
    numeroPersonal!.replaceAll(' ', '').replaceAll('-', '');

    final Uri url = Uri.parse("https://wa.me/$numeroFormatado");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível abrir o WhatsApp."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 5) {
      _abrirWhatsApp();
      return;
    }

    setState(() {
      _indiceSelecionado = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> telas = [
      _telaInicio(context),
      const TreinoAlunoTela(),
      const DietaAlunoTela(),
      const ProgressoTela(),
      const PerfilAlunoTela(),
    ];

    final List<String> titulos = [
      "Início",
      "Treino",
      "Dieta",
      "Progresso",
      "Perfil",
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          titulos[_indiceSelecionado],
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),
      body: telas[_indiceSelecionado],
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
            icon: Icon(Icons.fitness_center),
            label: "Treino",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "Dieta",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: "Progresso",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
            label: "WhatsApp",
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  // 🔹 Tela inicial (dashboard do aluno)
  Widget _telaInicio(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          "Usuário não autenticado",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Treino do dia (último criado)
          _cardSecao(
            titulo: "Treino de Hoje",
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('treinos')
                  .where('alunoId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Text(
                    "Nenhum treino atribuído.",
                    style: TextStyle(color: Colors.white70),
                  );
                }

                final treino = docs.first.data() as Map<String, dynamic>;
                final exercicios = (treino['exercicios'] as List?) ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      treino['titulo'] ?? "Treino",
                      style:
                      const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    for (var ex in exercicios.take(3))
                      Text("• $ex",
                          style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _indiceSelecionado = 1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("VER TREINO"),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 🔹 Dieta do dia (última criada)
          _cardSecao(
            titulo: "Refeições do Dia",
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('dietas')
                  .where('alunoId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Text(
                    "Nenhuma dieta atribuída.",
                    style: TextStyle(color: Colors.white70),
                  );
                }

                final dieta = docs.first.data() as Map<String, dynamic>;
                final refeicoes = (dieta['refeicoes'] as List?) ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dieta['titulo'] ?? "Dieta",
                      style:
                      const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    for (var r in refeicoes.take(3))
                      Text("• $r",
                          style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _indiceSelecionado = 2);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("VER DIETA"),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 🔹 Progresso (mantém gráfico atual)
          _cardSecao(
            titulo: "Progresso",
            child: SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: valores.entries.map((entry) {
                  final mes = entry.key;
                  final valor = entry.value;
                  final altura = (valor / 30) * 180;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 30,
                        height: altura,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mes,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Card
  Widget _cardSecao({required String titulo, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
