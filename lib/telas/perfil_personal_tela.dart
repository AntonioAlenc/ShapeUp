import 'package:flutter/material.dart';

class PerfilPersonalTela extends StatelessWidget {
  const PerfilPersonalTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.amber),
        title: const Text(
          'Perfil do Personal',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.fitness_center, size: 100, color: Colors.amber),
          const SizedBox(height: 16),
          _infoItem('Nome', 'Ana Treinadora'),
          _infoItem('E-mail', 'ana@personal.com'),
          _infoItem('Idade', '32 anos'),
          _infoItem('Especialidade', 'Hipertrofia e Funcional'),
          _infoItem('CREF', '123456-G/MS'),
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
