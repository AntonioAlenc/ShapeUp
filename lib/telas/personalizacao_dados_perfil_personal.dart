import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PersonalizacaoDadosPerfilPersonal extends StatefulWidget {
  const PersonalizacaoDadosPerfilPersonal({super.key});

  @override
  State<PersonalizacaoDadosPerfilPersonal> createState() =>
      _PersonalizacaoDadosPerfilPersonalState();
}

class _PersonalizacaoDadosPerfilPersonalState
    extends State<PersonalizacaoDadosPerfilPersonal> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sexoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _dataNascController = TextEditingController();
  final TextEditingController _crefController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();

  final _alturaMask =
  MaskTextInputFormatter(mask: "#.##", filter: {"#": RegExp(r'[0-9]')});
  final _pesoMask =
  MaskTextInputFormatter(mask: "##0.0", filter: {"#": RegExp(r'[0-9]')});
  final _telefoneMask =
  MaskTextInputFormatter(mask: "+## (##) #####-####", filter: {"#": RegExp(r'[0-9]')});
  final _dataMask =
  MaskTextInputFormatter(mask: "##/##/####", filter: {"#": RegExp(r'[0-9]')});

  Map<String, String> _originais = {};

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists) {
      final d = doc.data()!;

      String dataTxt = "";
      if (d['dataNascimento'] != null) {
        DateTime dt = (d['dataNascimento'] as Timestamp).toDate();
        dataTxt =
        "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
      }

      setState(() {
        _nomeController.text = d['nome'] ?? "";
        _sexoController.text = d['sexo'] ?? "";
        _alturaController.text = d['altura']?.toString() ?? "";
        _pesoController.text = d['peso']?.toString() ?? "";
        _dataNascController.text = dataTxt;
        _crefController.text = d['cref'] ?? "";
        _telefoneController.text = d['telefone'] ?? "";

        _originais = {
          "nome": _nomeController.text,
          "sexo": _sexoController.text,
          "altura": _alturaController.text,
          "peso": _pesoController.text,
          "dataNasc": _dataNascController.text,
          "cref": _crefController.text,
          "telefone": _telefoneController.text,
        };
      });
    }
  }

  bool _houveAlteracao() {
    return _nomeController.text != _originais["nome"] ||
        _sexoController.text != _originais["sexo"] ||
        _alturaController.text != _originais["altura"] ||
        _pesoController.text != _originais["peso"] ||
        _dataNascController.text != _originais["dataNasc"] ||
        _crefController.text != _originais["cref"] ||
        _telefoneController.text != _originais["telefone"];
  }

  Future<void> _salvar() async {
    if (!_houveAlteracao()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nenhuma alteração detectada")));
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Timestamp? tsNascimento;
    if (_dataNascController.text.isNotEmpty) {
      final p = _dataNascController.text.split('/');
      final dia = int.tryParse(p[0]);
      final mes = int.tryParse(p[1]);
      final ano = int.tryParse(p[2]);
      if (dia != null && mes != null && ano != null) {
        tsNascimento = Timestamp.fromDate(DateTime(ano, mes, dia));
      }
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      "nome": _nomeController.text,
      "sexo": _sexoController.text,
      "altura": _alturaController.text,
      "peso": _pesoController.text,
      "dataNascimento": tsNascimento,
      "cref": _crefController.text,
      "telefone": _telefoneController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dados atualizados com sucesso!")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Editar Dados"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _campo("Nome", _nomeController),
                _campo("Sexo", _sexoController),
                _campo("Altura (m)", _alturaController,
                    mascara: _alturaMask, tipo: TextInputType.number),
                _campo("Peso (kg)", _pesoController,
                    mascara: _pesoMask, tipo: TextInputType.number),
                _campo("Data de Nascimento", _dataNascController,
                    mascara: _dataMask, tipo: TextInputType.number),
                _campo("CREF", _crefController),
                _campo("Telefone", _telefoneController,
                    mascara: _telefoneMask, tipo: TextInputType.phone),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white),
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _salvar,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.amber),
                        child: const Text("Salvar Alterações"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl,
      {MaskTextInputFormatter? mascara, TextInputType tipo = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: tipo,
        inputFormatters: mascara != null ? [mascara] : [],
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.amber[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
