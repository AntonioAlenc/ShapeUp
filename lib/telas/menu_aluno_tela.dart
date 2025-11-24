import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _buscarNumeroPersonal();

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

    if (!alunoDoc.exists) return;

    final personalId = alunoDoc.data()?['personalId'];
    if (personalId == null) return;

    final personalDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(personalId)
        .get();

    print("🔥 Telefone vindo do Firestore: ${personalDoc.data()?['telefone']}");

    if (!personalDoc.exists) return;

    final personal = personalDoc.data() as Map<String, dynamic>;

    final telefone = personal['telefone'];

    if (telefone != null && telefone.toString().isNotEmpty) {
      setState(() {
        numeroPersonal = telefone.toString();
      });
    }
  }


  Future<void> _abrirWhatsApp() async {
    if (numeroPersonal == null || numeroPersonal!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Seu personal não possui telefone cadastrado."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // remove tudo que não for número
    String numeroLimpo = numeroPersonal!.replaceAll(RegExp(r'[^0-9]'), '');

    // se começar com 0, remove
    if (numeroLimpo.startsWith('0')) {
      numeroLimpo = numeroLimpo.substring(1);
    }

    // se não começar com 55, adiciona
    if (!numeroLimpo.startsWith('55')) {
      numeroLimpo = "55$numeroLimpo";
    }

    final Uri url = Uri.parse("https://wa.me/$numeroLimpo");

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
              onTap: () => setState(() => _indiceSelecionado = 4),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: "Treino"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "Dieta"),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), label: "Progresso"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
            label: "WhatsApp",
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  // -------------------------------------------------------------
  // 🟡 TELA INICIAL (Início)
  // -------------------------------------------------------------
  Widget _telaInicio(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
          child: Text("Usuário não autenticado",
              style: TextStyle(color: Colors.white)));
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
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // 🔥 TREINOS RECENTES
  // -------------------------------------------------------------
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
              child: CircularProgressIndicator(color: Colors.amber));
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
                ),
                child: const Text("VER TODOS OS TREINOS"),
              ),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // ⭐ DIETAS RECENTES (NOVO MODELO)
  // -------------------------------------------------------------
  Widget _streamDietas(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('dietas')
          .where('alunoId', isEqualTo: uid)
          .orderBy(FieldPath.documentId, descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.amber));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text("Nenhuma dieta atribuída.",
              style: TextStyle(color: Colors.white70));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var doc in docs)
              _itemDieta(doc.data() as Map<String, dynamic>, doc.id),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => _indiceSelecionado = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: const Text("VER TODAS AS DIETAS"),
              ),
            )
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------
  // CARD DE 1 DIETA (compatível com novo modelo)
  // -------------------------------------------------------------
  Widget _itemDieta(Map<String, dynamic> dieta, String id) {
    final periodo = (dieta['periodo'] ?? '').toString();
    final texto = (dieta['texto'] ?? '').toString();

    final data = dieta['criadoEm'] is Timestamp
        ? (dieta['criadoEm'] as Timestamp).toDate()
        : null;

    final hoje = DateTime.now();
    final ehHoje = data != null &&
        data.year == hoje.year &&
        data.month == hoje.month &&
        data.day == hoje.day;

    final nomes = {
      "manha": "☀️ Manhã",
      "almoco": "🍽 Almoço",
      "lanche": "☕ Lanche",
      "jantar": "🌙 Jantar",
    };

    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
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
                  nomes[periodo] ?? "Refeição",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                if (ehHoje)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white38),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Hoje",
                        style:
                        TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),

            if (data != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      "${data.day.toString().padLeft(2, '0')}/"
                          "${data.month.toString().padLeft(2, '0')}/"
                          "${data.year}",
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

            Text(
              texto,
              style:
              const TextStyle(color: Colors.white70, fontSize: 14),
            ),

            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 1,
              color: Colors.white12,
            )
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // ITEM DE TREINO (mantido)
  // -------------------------------------------------------------
  Widget _itemTreino(Map<String, dynamic> treino) {
    final descricao = treino['descricao'] ?? "Treino";
    final exercicios = (treino['exercicios'] as List?) ?? [];
    final data = treino['dataCriacao'] != null
        ? (treino['dataCriacao'] as Timestamp).toDate()
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(descricao,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        if (data != null)
          Text(
            "${data.day}/${data.month}/${data.year}",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        const SizedBox(height: 6),
        ...exercicios.take(2).map((e) => Text("• ${e['nome']}",
            style: const TextStyle(color: Colors.white70))),
        Container(
          margin: const EdgeInsets.only(top: 10),
          height: 1,
          color: Colors.white12,
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // CARD PADRÃO
  // -------------------------------------------------------------
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
