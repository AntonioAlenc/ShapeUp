import 'package:flutter/material.dart';

class ProgressoTela extends StatelessWidget {
  const ProgressoTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.amber),
        title: const Text(
          'Progresso',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Medições Corporais',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _medidaItem('Peso', '72 kg'),
          _medidaItem('Altura', '1,75 m'),
          _medidaItem('Braço direito', '32 cm'),
          _medidaItem('Braço esquerdo', '32 cm'),
          _medidaItem('Cintura', '88 cm'),
          _medidaItem('Quadril', '94 cm'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Ação futura para editar medidas
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Atualizar Medidas',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medidaItem(String nome, String valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nome,
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            valor,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
