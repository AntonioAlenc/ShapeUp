import 'package:flutter/material.dart';

class TreinoPersonalTela extends StatelessWidget {
  const TreinoPersonalTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Treinos do Aluno',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _blocoTreino(
            titulo: 'Peito/Ombros',
            exercicios: [
              'Supino Inclinado c/ Halteres\nSéries: 2x5-10\nIntervalo: 60s',
              'Crucifixo Inclinado na Polia\nSéries: 3x5-10\nIntervalo: 60s',
              'Supino Reto c/ Barra\nSéries: 2x10-15\nIntervalo: 120s',
              'Elevação Lateral c/ Halteres\nSéries: 4x6-8\nIntervalo: 90s',
              'Elevação Frontal c/ Corda\nSéries: 3x8-10\nIntervalo: 60s',
            ],
            aoEditar: () {
              // Ação futura de edição
            },
          ),
          const SizedBox(height: 16),
          _blocoTreino(
            titulo: 'Costas/Abdominal',
            exercicios: [
              'Remada Curvada c/ Barra Reta\nSéries: 3x12\nIntervalo: 60s',
              'Abdominal Infra no Banco\nSéries: 3x15\nIntervalo: 45s',
            ],
            aoEditar: () {
              // Ação futura de edição
            },
          ),
        ],
      ),
    );
  }

  Widget _blocoTreino({
    required String titulo,
    required List<String> exercicios,
    required VoidCallback aoEditar,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
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
          ...exercicios.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                e,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: aoEditar,
              icon: const Icon(Icons.edit, color: Colors.black),
              label: const Text('Editar', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
