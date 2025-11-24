import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'personalizacao_dados_perfil_personal.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class PerfilPersonalTela extends StatelessWidget {
  const PerfilPersonalTela({super.key});

  Future<void> _sair(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  int _calcularIdade(DateTime nascimento) {
    final hoje = DateTime.now();
    int idade = hoje.year - nascimento.year;

    if (hoje.month < nascimento.month ||
        (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
      idade--;
    }
    return idade;
  }

  Future<XFile?> _selecionarImagem() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  Future<String?> _uploadFoto(XFile imagem, String uid) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('fotos_perfil')
          .child('$uid.jpg');

      if (kIsWeb) {
        Uint8List bytes = await imagem.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        return await ref.getDownloadURL();
      }

      final file = File(imagem.path);
      await ref.putFile(file);
      return await ref.getDownloadURL();

    } catch (e) {
      print("Erro upload: $e");
      return null;
    }
  }

  Future<void> _trocarFoto(BuildContext context, String uid) async {
    final imagem = await _selecionarImagem();
    if (imagem == null) return;

    final url = await _uploadFoto(imagem, uid);
    if (url == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fotoUrl': url,
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto atualizada com sucesso!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text("Não autenticado", style: TextStyle(color: Colors.white)),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final personal = snap.data!.data() as Map<String, dynamic>;

        String dataNascimentoTexto = "-";
        String idadeTexto = "-";

        if (personal["dataNascimento"] != null) {
          final ts = personal["dataNascimento"] as Timestamp;
          final nascimento = ts.toDate();

          dataNascimentoTexto =
          "${nascimento.day.toString().padLeft(2, '0')}/${nascimento.month.toString().padLeft(2, '0')}/${nascimento.year}";
          idadeTexto = _calcularIdade(nascimento).toString();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _trocarFoto(context, user.uid),
                  child: personal["fotoUrl"] != null &&
                      personal["fotoUrl"].toString().isNotEmpty
                      ? ClipOval(
                      child: Image.network(
                        personal["fotoUrl"],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.black,
                          child: Icon(Icons.person, size: 60, color: Colors.amber),
                        ),
                      ))
                      : const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, size: 60, color: Colors.amber),
                  ),
                ),

                const SizedBox(height: 20),

                _info('Nome:', personal["nome"]),
                _info('Sexo:', personal["sexo"]),
                _info('Data Nasc.:', dataNascimentoTexto),
                _info('Idade:', idadeTexto),
                _info('Altura:', personal["altura"]?.toString()),
                _info('Peso:', personal["peso"]?.toString()),
                _info('CREF:', personal["cref"]),
                _info('Telefone:', personal["telefone"]),

                const SizedBox(height: 20),

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
                      const Text("Meu código (UID):",
                          style: TextStyle(color: Colors.amber)),
                      SelectableText(
                        user.uid,
                        style: const TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const PersonalizacaoDadosPerfilPersonal(),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text("Editar Dados"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.amber,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _sair(context),
                    icon: const Icon(Icons.logout),
                    label: const Text("Sair"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.amber,
                      padding: const EdgeInsets.all(14),
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

  Widget _info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black)),
          Text(value?.toString() ?? "-",
              style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
