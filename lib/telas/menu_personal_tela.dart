import 'package:flutter/material.dart';

class MenuPersonalTela extends StatefulWidget {
  const MenuPersonalTela({super.key});

  @override
  State<MenuPersonalTela> createState() => _MenuPersonalTelaState();
}

class _MenuPersonalTelaState extends State<MenuPersonalTela> {
  int _indiceSelecionado = 0;

  // 🔹 Lista de telas exibidas em cada aba
  late final List<Widget> _telas;

  @override
  void initState() {
    super.initState();
    _telas = [
      _telaInicio(context),
      _telaTreinos(context),
      _telaDietas(context),
      _telaAlunos(context),
      _telaPerfil(context),
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
          _indiceSelecionado == 0
              ? "Olá, Treinador"
              : _titulos[_indiceSelecionado],
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
            icon: Icon(Icons.fitness_center),
            label: "Treinos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Dietas",
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

  // 🔹 Títulos da AppBar
  final List<String> _titulos = [
    "Olá, Treinador",
    "Treinos",
    "Dietas",
    "Meus Alunos",
    "Perfil",
  ];

  // 🔹 Telas simuladas
  Widget _telaInicio(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _cardMenu(
            context,
            titulo: "Meus Alunos",
            icone: Icons.group,
          ),
          const SizedBox(height: 16),
          _cardMenu(
            context,
            titulo: "Treinos",
            icone: Icons.fitness_center,
          ),
          const SizedBox(height: 16),
          _cardMenu(
            context,
            titulo: "Dietas",
            icone: Icons.restaurant_menu,
          ),
        ],
      ),
    );
  }

  Widget _telaTreinos(BuildContext context) {
    return const Center(
      child: Text(
        "Tela de Treinos",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _telaDietas(BuildContext context) {
    return const Center(
      child: Text(
        "Tela de Dietas",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _telaAlunos(BuildContext context) {
    return const Center(
      child: Text(
        "Tela de Alunos",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _telaPerfil(BuildContext context) {
    return const Center(
      child: Text(
        "Tela de Perfil",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // 🔹 Card do menu inicial
  Widget _cardMenu(BuildContext context,
      {required String titulo, required IconData icone}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icone, size: 28, color: Colors.black),
              const SizedBox(width: 12),
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.black),
        ],
      ),
    );
  }
}
