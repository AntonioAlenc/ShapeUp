import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            const _infoItem('Nome:', 'João'),
            const _infoItem('Sexo:', 'M'),
            const _infoItem('Idade:', '21'),
            const _infoItem('Altura:', '180cm'),
            const _infoItem('Peso:', '81Kg'),
            const _infoItem('Idioma:', 'PT-BR'),
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
