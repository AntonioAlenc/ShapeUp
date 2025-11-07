import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ProgressoAlunoTela extends StatefulWidget {
  const ProgressoAlunoTela({super.key});

  @override
  State<ProgressoAlunoTela> createState() => _ProgressoAlunoTelaState();
}

class _ProgressoAlunoTelaState extends State<ProgressoAlunoTela> {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final GlobalKey _graficoKey = GlobalKey();

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

        // 🔹 Botão para exportar o relatório em PDF
        final botaoPDF = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final snapData = await FirebaseFirestore.instance
                  .collection('progresso')
                  .where('alunoId', isEqualTo: uid)
                  .orderBy('data', descending: false)
                  .get();
              if (snapData.docs.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Nenhum progresso encontrado para exportar.'),
                  backgroundColor: Colors.amber,
                ));
                return;
              }
              await _gerarRelatorioPDF(snapData.docs);
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Exportar Relatório em PDF"),
          ),
        );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            botaoPDF,
            _secaoMedidas(ultimo, medidas),
            const SizedBox(height: 16),
            RepaintBoundary(
              key: _graficoKey,
              child: Column(
                children: [
                  _secaoGraficoPeso(docs),
                  const SizedBox(height: 16),
                  _secaoGraficoMedidas(docs),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 🔹 Função para gerar PDF
  Future<void> _gerarRelatorioPDF(List<QueryDocumentSnapshot> docs) async {
    try {
      RenderRepaintBoundary boundary =
      _graficoKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? graficoBytes = byteData?.buffer.asUint8List();

      final pdf = pw.Document();
      final dataGeracao = DateTime.now();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Center(
                child: pw.Text(
                  "Relatório de Progresso - ShapeUp",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.amber800,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  "Gerado em: ${dataGeracao.day}/${dataGeracao.month}/${dataGeracao.year}",
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              if (graficoBytes != null) ...[
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Image(pw.MemoryImage(graficoBytes),
                      width: 400, height: 200, fit: pw.BoxFit.contain),
                ),
              ],
              pw.SizedBox(height: 16),
              ...docs.map((d) {
                final data = d.data() as Map<String, dynamic>;
                final medidas =
                Map<String, dynamic>.from(data['medidas'] ?? {});
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.amber),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "📅 ${DateTime.parse(data['data']).day.toString().padLeft(2, '0')}/${DateTime.parse(data['data']).month.toString().padLeft(2, '0')}/${DateTime.parse(data['data']).year}",
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.amber800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text("Peso: ${data['peso']} kg"),
                      ...medidas.entries.map((m) =>
                          pw.Text("${m.key}: ${m.value} cm",
                              style: const pw.TextStyle(fontSize: 11))),
                      if (data['observacoes'] != null &&
                          data['observacoes'].toString().isNotEmpty)
                        pw.Text("Obs: ${data['observacoes']}",
                            style: pw.TextStyle(
                                fontStyle: pw.FontStyle.italic,
                                color: PdfColors.grey700)),
                    ],
                  ),
                );
              }),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao gerar PDF: $e'),
        backgroundColor: Colors.redAccent,
      ));
    }
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
                        style:
                        const TextStyle(color: Colors.white70, fontSize: 10),
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
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 10),
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
                        style:
                        const TextStyle(color: Colors.white70, fontSize: 10),
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
                    style:
                    const TextStyle(color: Colors.white70, fontSize: 10),
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
