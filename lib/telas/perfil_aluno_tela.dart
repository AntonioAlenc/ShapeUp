import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'personalizacao_dados_perfil_aluno.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class PerfilAlunoTela extends StatelessWidget {
  const PerfilAlunoTela({super.key});

  Future<void> _sair(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
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

  Future<XFile?> _selecionarImagemWebOuMobile() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  // 🔥 MÉTODO FINAL – COMPLETO, FUNCIONA NO WEB E MOBILE
  Future<void> _trocarFoto(BuildContext context, String uid) async {
    final imagem = await _selecionarImagemWebOuMobile(); // AGORA FUNCIONA NO WEB

    if (imagem == null) return;

    final url = await _uploadFoto(imagem, uid);

    if (url == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({"fotoUrl": url});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto alterada com sucesso!")),
      );
    }
  }


  Future<String?> _uploadFoto(XFile imagem, String uid) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('fotos_perfil')
          .child('$uid.jpg');

      if (kIsWeb) {
        Uint8List bytes = await imagem.readAsBytes();
        await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        return await ref.getDownloadURL();
      }

      final file = File(imagem.path);
      await ref.putFile(file);
      return await ref.getDownloadURL();

    } catch (e) {
      print("🔥 Erro ao fazer upload da imagem: $e");
      return null;
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

        String dataNascimentoTexto = "-";
        String idadeTexto = "-";
        if (aluno["dataNascimento"] != null) {
          final ts = aluno["dataNascimento"] as Timestamp;
          final nascimento = ts.toDate();
          dataNascimentoTexto =
          "${nascimento.day.toString().padLeft(2, '0')}/${nascimento.month.toString().padLeft(2, '0')}/${nascimento.year}";
          idadeTexto = _calcularIdade(nascimento).toString();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  // FOTO DO PERFIL FINAL
                  Center(
                    child: GestureDetector(
                      onTap: () => _trocarFoto(context, user.uid),

                      child: aluno["fotoUrl"] != null &&
                          aluno["fotoUrl"].toString().isNotEmpty
                          ? ClipOval(
                        child: Image.network(
                          aluno["fotoUrl"],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.black,
                            child: Icon(Icons.person, size: 60, color: Colors.amber),
                          ),
                        ),
                      )
                          : const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.person, size: 60, color: Colors.amber),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _infoItem("Nome:", aluno["nome"] ?? "-"),
                  _infoItem("Sexo:", aluno["sexo"] ?? "-"),
                  _infoItem("Objetivo:", aluno["objetivo"] ?? "-"),
                  _infoItem("Data Nasc.:", dataNascimentoTexto),
                  _infoItem("Idade:", idadeTexto),
                  _infoItem("Altura:", aluno["altura"]?.toString() ?? "-"),
                  _infoItem("Peso:", aluno["peso"]?.toString() ?? "-"),

                  const SizedBox(height: 12),

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
                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          user.uid,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

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

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PersonalizacaoDadosPerfilAluno(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        "Editar Dados",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

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
