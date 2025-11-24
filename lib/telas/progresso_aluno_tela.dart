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

  // 🔥 NOVO DROPDOWN DE MEDIDAS
  String medidaSelecionada = "quadril"; // medida padrão
  final List<String> metricas = [
    "peso",
    "quadril",
    "cintura",
    "bracoDireito",
    "bracoEsquerdo",
    "coxaDireita",
    "coxaEsquerda",
  ];

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
          .orderBy('data', descending: false) // 🔥 AGORA EM ORDEM CRESCENTE
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.amber));
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return _semDados();
        }

        // 🔥 docs já vêm em ordem crescente
        final docs = snap.data!.docs;
        final ultimo = docs.last.data() as Map<String, dynamic>;
        final medidas = Map<String, dynamic>.from(ultimo['medidas'] ?? {});

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _botaoPDF(),
            _secaoMedidas(ultimo, medidas),
            const SizedBox(height: 16),

            // 🔥 Dropdown Seleção de Medida
            _dropdownSelecao(),

            const SizedBox(height: 16),

            // 🔥 Gráfico único adaptável
            RepaintBoundary(
              key: _graficoKey,
              child: _graficoMedidaSelecionada(docs),
            )
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PDF
  // ---------------------------------------------------------------------------

  Widget _botaoPDF() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  }

  Future<void> _gerarRelatorioPDF(
      List<QueryDocumentSnapshot> docs) async {
    try {
      RenderRepaintBoundary boundary =
      _graficoKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? graficoBytes = byteData?.buffer.asUint8List();

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(children: [
            pw.Text("ShapeUp - Relatório de Progresso",
                style:
                pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            if (graficoBytes != null)
              pw.Image(pw.MemoryImage(graficoBytes), width: 400),
          ]),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao gerar PDF: $e")),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Seleção de Medida
  // ---------------------------------------------------------------------------

  Widget _dropdownSelecao() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: Row(
          children: [
            const Icon(Icons.stacked_line_chart, color: Colors.black),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<String>(
                value: medidaSelecionada,
                isExpanded: true,
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.black,
                items: metricas.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child:
                    Text(m, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() => medidaSelecionada = v!);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Gráfico dinâmico
  // ---------------------------------------------------------------------------

  Widget _graficoMedidaSelecionada(List<QueryDocumentSnapshot> docs) {
    final spots = <FlSpot>[];
    final labels = <String>[];

    for (int i = 0; i < docs.length; i++) {
      final dado = docs[i].data() as Map<String, dynamic>;

      final data = (dado['data'] is Timestamp)
          ? (dado['data'] as Timestamp).toDate()
          : DateTime.tryParse(dado['data']) ?? DateTime.now();

      labels.add("${data.day}/${data.month}");

      double valor;

      if (medidaSelecionada == "peso") {
        valor = (dado["peso"] ?? 0).toDouble();
      } else {
        final medidas =
        Map<String, dynamic>.from(dado["medidas"] ?? {});
        valor = (medidas[medidaSelecionada] ?? 0).toDouble();
      }

      spots.add(FlSpot(i.toDouble(), valor));
    }

    return _cardSecao(
      titulo: "Evolução de $medidaSelecionada",
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final index = v.toInt();
                      return (index >= 0 && index < labels.length)
                          ? Text(labels[index],
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10))
                          : const SizedBox();
                    }),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, _) => Text(
                      "${v.toInt()} cm",
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 10),
                    )),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: medidaSelecionada == "peso"
                    ? Colors.amber
                    : Colors.cyanAccent,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: (medidaSelecionada == "peso"
                      ? Colors.amber
                      : Colors.cyanAccent)
                      .withOpacity(0.25),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Componentes gerais
  // ---------------------------------------------------------------------------

  Widget _cardSecao({required String titulo, required Widget child}) {
    return Container(
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
            const SizedBox(height: 10),
            child
          ]),
    );
  }

  Widget _semDados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.fitness_center, color: Colors.amber, size: 60),
          SizedBox(height: 16),
          Text(
            'Nenhum progresso registrado',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _secaoMedidas(
      Map<String, dynamic> dados, Map<String, dynamic> medidas) {
    return _cardSecao(
      titulo: "Medições Corporais",
      child: Column(
        children: [
          _item("Peso", "${dados["peso"]} kg"),
          _item("Altura", "${dados["altura"]} m"),
          _item("Braço Direito", "${medidas["bracoDireito"]} cm"),
          _item("Braço Esquerdo", "${medidas["bracoEsquerdo"]} cm"),
          _item("Coxa Direita", "${medidas["coxaDireita"]} cm"),
          _item("Coxa Esquerda", "${medidas["coxaEsquerda"]} cm"),
          _item("Cintura", "${medidas["cintura"]} cm"),
          _item("Quadril", "${medidas["quadril"]} cm"),
        ],
      ),
    );
  }

  Widget _item(String nome, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nome, style: const TextStyle(color: Colors.white)),
          Text(valor, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
