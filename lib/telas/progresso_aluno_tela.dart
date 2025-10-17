import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressoAlunoTela extends StatefulWidget {
  const ProgressoAlunoTela({super.key});

  @override
  State<ProgressoAlunoTela> createState() => _ProgressoAlunoTelaState();
}

class _ProgressoAlunoTelaState extends State<ProgressoAlunoTela> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Center(
        child: Text('Não autenticado', style: TextStyle(color: Colors.white)),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('progresso')
          .where('alunoId', isEqualTo: uid)
          .orderBy('data', descending: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.amber));
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return _semDados();
        }

        final docs = snap.data!.docs;
        final ultimo = docs.first.data() as Map<String, dynamic>;
        final medidas = Map<String, dynamic>.from(ultimo['medidas'] ?? {});

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _secaoMedidas(ultimo, medidas),
            const SizedBox(height: 16),
            _secaoGraficoPeso(docs),
            const SizedBox(height: 16),
            _secaoGraficoMedidas(docs),
          ],
        );
      },
    );
  }

  // 🔹 Seção de medições corporais
  Widget _secaoMedidas(Map<String, dynamic> dados, Map<String, dynamic> medidas) {
    return _cardSecao(
      titulo: "Medições Corporais",
      child: Column(
        children: [
          _medidaItem('Peso', '${dados['peso'] ?? '-'} kg'),
          _medidaItem('Altura', '${dados['altura'] ?? '-'} m'),
          _medidaItem('Braço Direito', '${medidas['bracoDireito'] ?? '-'} cm'),
          _medidaItem('Braço Esquerdo', '${medidas['bracoEsquerdo'] ?? '-'} cm'),
          _medidaItem('Coxa Direita', '${medidas['coxaDireita'] ?? '-'} cm'),
          _medidaItem('Coxa Esquerda', '${medidas['coxaEsquerda'] ?? '-'} cm'),
          _medidaItem('Cintura', '${medidas['cintura'] ?? '-'} cm'),
          _medidaItem('Quadril', '${medidas['quadril'] ?? '-'} cm'),
          if (dados['observacoes'] != null && dados['observacoes'] != '')
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Observações: ${dados['observacoes']}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }

  // 🔹 Gráfico de evolução de peso
  Widget _secaoGraficoPeso(List<QueryDocumentSnapshot> docs) {
    final dados = docs.map((d) => d.data() as Map<String, dynamic>).toList();
    final pontos = <FlSpot>[];
    final rotulos = <String>[];

    for (var i = 0; i < dados.length; i++) {
      final dado = dados[i];
      final peso = (dado['peso'] ?? 0).toDouble();
      final data = (dado['data'] is Timestamp)
          ? (dado['data'] as Timestamp).toDate()
          : DateTime.tryParse(dado['data'] ?? '');
      if (data != null) {
        pontos.add(FlSpot(i.toDouble(), peso));
        rotulos.add('${data.day}/${data.month}');
      }
    }

    return _cardSecao(
      titulo: "Evolução de Peso",
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < rotulos.length) {
                      return Text(
                        rotulos[index],
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}kg',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: pontos,
                isCurved: true,
                color: Colors.amber,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.amber.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Gráfico de evolução das medidas
  Widget _secaoGraficoMedidas(List<QueryDocumentSnapshot> docs) {
    final dados = docs.map((d) => d.data() as Map<String, dynamic>).toList();
    final pontos = <FlSpot>[];
    final rotulos = <String>[];

    for (var i = 0; i < dados.length; i++) {
      final dado = dados[i];
      final medidas = Map<String, dynamic>.from(dado['medidas'] ?? {});
      final media = [
        medidas['bracoDireito'] ?? 0,
        medidas['bracoEsquerdo'] ?? 0,
        medidas['coxaDireita'] ?? 0,
        medidas['coxaEsquerda'] ?? 0,
        medidas['cintura'] ?? 0,
        medidas['quadril'] ?? 0,
      ].whereType<num>().isEmpty
          ? 0
          : ([
        medidas['bracoDireito'] ?? 0,
        medidas['bracoEsquerdo'] ?? 0,
        medidas['coxaDireita'] ?? 0,
        medidas['coxaEsquerda'] ?? 0,
        medidas['cintura'] ?? 0,
        medidas['quadril'] ?? 0,
      ].whereType<num>().reduce((a, b) => a + b) /
          6);

      final data = (dado['data'] is Timestamp)
          ? (dado['data'] as Timestamp).toDate()
          : DateTime.tryParse(dado['data'] ?? '');
      if (data != null) {
        pontos.add(FlSpot(i.toDouble(), media.toDouble()));
        rotulos.add('${data.day}/${data.month}');
      }
    }

    return _cardSecao(
      titulo: "Evolução de Medidas Corporais",
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < rotulos.length) {
                      return Text(
                        rotulos[index],
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (v, _) => Text(
                    '${v.toInt()}cm',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: pontos,
                isCurved: true,
                color: Colors.cyanAccent,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.cyanAccent.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Sem dados
  Widget _semDados() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.fitness_center, color: Colors.amber, size: 60),
            SizedBox(height: 16),
            Text(
              'Nenhum progresso cadastrado pelo personal ainda',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Utilitários visuais
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
