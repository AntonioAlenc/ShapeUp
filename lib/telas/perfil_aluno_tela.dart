import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilAlunoTela extends StatelessWidget {
  const PerfilAlunoTela({super.key});

  Future<void> _sair(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          "Não autenticado",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
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
        final personalId = aluno["personalId"];

        return Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _infoItem("Nome:", aluno["nome"] ?? "-"),
                _infoItem("Sexo:", aluno["sexo"] ?? "-"),
                _infoItem("Idade:", aluno["idade"]?.toString() ?? "-"),
                _infoItem("Altura:", aluno["altura"]?.toString() ?? "-"),
                _infoItem("Peso:", aluno["peso"]?.toString() ?? "-"),
                _infoItem("Idioma:", aluno["idioma"] ?? "PT-BR"),

                const SizedBox(height: 12),

                // 🔹 Exibir UID do aluno
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Meu código (UID):",
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        user.uid,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 🔹 Exibir vinculação com personal
                FutureBuilder<DocumentSnapshot>(
                  future: personalId != null
                      ? FirebaseFirestore.instance.collection('users').doc(personalId).get()
                      : null,
                  builder: (context, personalSnap) {
                    if (personalSnap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (personalId == null) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Ainda não vinculado a um personal",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final personal = personalSnap.data?.data() as Map<String, dynamic>?;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Personal vinculado: ${personal?["nome"] ?? personalId.substring(0, 6)}",
                        style: const TextStyle(color: Colors.amber),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 🔹 Botão de sair
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _sair(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      "Sair",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _infoItem extends StatelessWidget {
  final String titulo;
  final String valor;

  const _infoItem(this.titulo, this.valor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
//att
