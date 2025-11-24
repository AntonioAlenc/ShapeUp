import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'treinos_personal_aluno_tela.dart';
import 'dietas_personal_aluno_tela.dart';
import 'progresso_personal_aluno_tela.dart'; // 🔹 novo import

class AlunoDetalhesTela extends StatelessWidget {
  final String nomeAluno;
  final String alunoId;

  const AlunoDetalhesTela({
    super.key,
    required this.nomeAluno,
    required this.alunoId,
  });

  Future<void> _desvincularAluno(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(alunoId)
          .update({'personalId': null});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aluno desvinculado com sucesso")),
        );
        Navigator.pop(context); // volta para lista de alunos
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao desvincular: $e")),
        );
      }
    }
  }

  void _confirmarDesvinculo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Confirmar",
          style: TextStyle(color: Colors.amber),
        ),
        content: const Text(
          "Tem certeza que deseja desvincular este aluno?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.amber)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // fecha o dialog
              _desvincularAluno(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Desvincular"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Aluno: $nomeAluno"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(alunoId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(
              child: Text(
                "Dados do aluno não encontrados",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final aluno = snap.data!.data() as Map<String, dynamic>;
          final alunoIdCurto =
          alunoId.length > 6 ? alunoId.substring(0, 6) : alunoId;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🔹 Exibir informações básicas do aluno
                Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                    title: Text(
                      aluno["nome"] ?? "-",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ID: $alunoIdCurto...",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "Idade: ${aluno["idade"] ?? "-"}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Objetivo: ${aluno["objetivo"] ?? "-"}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _editarObjetivo(context, alunoId),
                              child: const Icon(Icons.edit, color: Colors.amber, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                //Botões de navegação
                _botaoMenu(
                  context,
                  titulo: "Treinos",
                  icone: Icons.fitness_center,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TreinosPersonalAlunoTela(
                          nomeAluno: nomeAluno,
                          alunoId: alunoId,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _botaoMenu(
                  context,
                  titulo: "Dietas",
                  icone: Icons.restaurant_menu,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DietasPersonalAlunoTela(
                          nomeAluno: nomeAluno,
                          alunoId: alunoId, // 🔹 passamos o ID aqui também
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 🔹 Novo botão Progresso
                _botaoMenu(
                  context,
                  titulo: "Progresso",
                  icone: Icons.trending_up,
                  onTap: () {
                    final sexo = aluno["sexo"] ?? "masculino"; // 🔹 padrão seguro
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProgressoPersonalAlunoTela(
                          nomeAluno: nomeAluno,
                          alunoId: alunoId,
                          sexo: sexo,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // 🔹 Botão Desvincular (apenas se já estiver vinculado)
                if (aluno["personalId"] != null)
                  ElevatedButton.icon(
                    onPressed: () => _confirmarDesvinculo(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.link_off),
                    label: const Text(
                      "Desvincular Aluno",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _editarObjetivo(BuildContext context, String alunoId) async {
    TextEditingController objetivoController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Editar Objetivo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: objetivoController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Novo objetivo",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.amber, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.amber, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final novoObjetivo = objetivoController.text.trim();
                          if (novoObjetivo.isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(alunoId)
                                .update({"objetivo": novoObjetivo});
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Salvar",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _botaoMenu(BuildContext context,
      {required String titulo,
        required IconData icone,
        required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
