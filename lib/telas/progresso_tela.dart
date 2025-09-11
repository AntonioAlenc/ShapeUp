import 'package:flutter/material.dart';

class ProgressoTela extends StatelessWidget {
  const ProgressoTela({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 valores simulados
    final valores = {
      "Jan": 15.0,
      "Fev": 12.0,
      "Mar": 18.0,
      "Abr": 25.0,
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 🔹 Medições corporais
        _cardSecao(
          titulo: "Medições Corporais",
          child: Column(
            children: [
              _medidaItem('Peso', '72 kg'),
              _medidaItem('Altura', '1,75 m'),
              _medidaItem('Braço direito', '32 cm'),
              _medidaItem('Braço esquerdo', '32 cm'),
              _medidaItem('Cintura', '88 cm'),
              _medidaItem('Quadril', '94 cm'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 🔹 Futuro: abrir formulário de edição
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Atualizar Medidas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 🔹 Gráfico simulado 1 (área/carga/massa)
        _cardSecao(
          titulo: "Evolução",
          child: SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 193, 7, 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 193, 7, 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 🔹 Gráfico simulado 2 (barras por mês)
        _cardSecao(
          titulo: "Progresso Mensal",
          child: SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: valores.entries.map((entry) {
                final mes = entry.key;
                final valor = entry.value;
                final altura = (valor / 30) * 180; // escala

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 40,
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
    );
  }

  Widget _medidaItem(String nome, String valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nome, style: const TextStyle(color: Colors.white)),
          Text(valor, style: const TextStyle(color: Colors.white)),
        ],
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
