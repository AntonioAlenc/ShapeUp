import 'package:flutter/material.dart';

class PerfilAlunoTela extends StatelessWidget {
  const PerfilAlunoTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.amber),
        title: const Text(
          'Perfil do Aluno',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.person, size: 100, color: Colors.amber),
          const SizedBox(height: 16),
          _infoItem('Nome', 'João da Silva'),
          _infoItem('E-mail', 'joao@email.com'),
          _infoItem('Idade', '25 anos'),
          _infoItem('Peso', '72 kg'),
          _infoItem('Altura', '1,75 m'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Ação futura de edição
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.edit, color: Colors.black),
            label: const Text(
              'Editar Perfil',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String titulo, String valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(color: Colors.white70)),
          Text(valor, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
