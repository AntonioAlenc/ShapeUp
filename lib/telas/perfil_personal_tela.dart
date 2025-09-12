import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilPersonalTela extends StatelessWidget {
  const PerfilPersonalTela({super.key});

  Future<void> _sair(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
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
              _infoItem('Nome:', 'Antônio'),
              _infoItem('Sexo:', 'M'),
              _infoItem('Idade:', '21'),
              _infoItem('Altura:', '180cm'),
              _infoItem('Peso:', '81Kg'),
              _infoItem('Idioma:', 'PT-BR'),
              _infoItem('CREF:', '0000-G/MS'),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _sair(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text("Sair"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Text(valor, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
//att