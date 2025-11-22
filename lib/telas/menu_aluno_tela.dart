import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// importe suas telas reais
import 'treino_aluno_tela.dart';
import 'dieta_aluno_tela.dart';
import 'progresso_aluno_tela.dart';
import 'perfil_aluno_tela.dart';

class MenuAlunoTela extends StatefulWidget {
  const MenuAlunoTela({super.key});

  @override
  State<MenuAlunoTela> createState() => _MenuAlunoTelaState();
}

class _MenuAlunoTelaState extends State<MenuAlunoTela>
    with SingleTickerProviderStateMixin {
  int _indiceSelecionado = 0;
  String? numeroPersonal;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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

    // 🔹 configuração da animação
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
      const ProgressoAlunoTela(),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _indiceSelecionado = 4; // 👉 Abre a aba "Perfil"
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
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardSecao(
                titulo: "Treinos Recentes",
                child: _streamTreinos(user.uid),
              ),
              const SizedBox(height: 16),
              _cardSecao(
                titulo: "Dietas Recentes",
                child: _streamDietas(user.uid),
              ),
              const SizedBox(height: 16),
              _cardSecao(
                titulo: "Progresso",
                child: _graficoProgresso(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _streamTreinos(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('treinos')
          .where('alunoId', isEqualTo: uid)
          .orderBy('dataCriacao', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text("Nenhum treino atribuído.",
              style: TextStyle(color: Colors.white70));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var doc in docs) _itemTreino(doc.data() as Map<String, dynamic>),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _indiceSelecionado = 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("VER TODOS OS TREINOS"),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _streamDietas(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('dietas')
          .where('alunoId', isEqualTo: uid)
          .orderBy('criadoEm', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text("Nenhuma dieta atribuída.",
              style: TextStyle(color: Colors.white70));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var doc in docs) _itemDieta(doc.data() as Map<String, dynamic>),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _indiceSelecionado = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("VER TODAS AS DIETAS"),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _graficoProgresso() {
    return SizedBox(
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
              Text(mes, style: const TextStyle(color: Colors.white70)),
            ],
          );
        }).toList(),
      ),
    );
  }

  // 🔹 Itens com ícone e animação sutil
  Widget _itemTreino(Map<String, dynamic> treino) {
    final descricao = treino['descricao'] ?? "Treino";
    final exercicios = (treino['exercicios'] as List?) ?? [];
    final data = treino['dataCriacao'] != null
        ? (treino['dataCriacao'] as Timestamp).toDate()
        : null;

    final hoje = DateTime.now();
    final ehHoje = data != null &&
        data.year == hoje.year &&
        data.month == hoje.month &&
        data.day == hoje.day;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.transparent, // 🔹 Fundo removido
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      descricao,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (ehHoje)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: const Text(
                          "Hoje",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                if (data != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (exercicios.isNotEmpty)
                  ...exercicios.take(3).map((ex) {
                    if (ex is Map<String, dynamic>) {
                      final nome = ex['nome'] ?? 'Exercício';
                      final series = ex['series'] ?? '';
                      final observacao = ex['observacao'] ?? '';
                      final pausa = ex['pausa'] ?? '';
                      final detalhes = [
                        if (series.isNotEmpty) series,
                        if (observacao.isNotEmpty) observacao,
                        if (pausa.isNotEmpty) "Pausa: $pausa",
                      ].join(' • ');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• ",
                                style: TextStyle(
                                    color: Colors.amber, fontSize: 14)),
                            Expanded(
                              child: Text(
                                "$nome${detalhes.isNotEmpty ? ' • $detalhes' : ''}",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (ex is String) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          "• $ex",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 8),
            height: 1,
            color: Colors.white12,
          ),
        ],
      ),
    );
  }



  Widget _itemDieta(Map<String, dynamic> dieta) {
    final refeicao = dieta['refeicao'] ?? "Dieta";
    final detalhes = dieta['detalhes'] ?? "Sem detalhes";
    final data = dieta['criadoEm'] != null
        ? (dieta['criadoEm'] as Timestamp).toDate()
        : null;

    final hoje = DateTime.now();
    final ehHoje = data != null &&
        data.year == hoje.year &&
        data.month == hoje.month &&
        data.day == hoje.day;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.transparent, // 🔹 Fundo removido
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu,
                    color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                Text(
                  refeicao,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (ehHoje)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Text(
                      "Hoje",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            if (data != null)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}",
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            Text(
              "Detalhes: $detalhes",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 1,
              color: Colors.white12,
            ),
          ],
        ),
      ),
    );
  }




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
          Text(titulo,
              style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
