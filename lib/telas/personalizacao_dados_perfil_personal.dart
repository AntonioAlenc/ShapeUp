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
  final TextEditingController _idiomaController = TextEditingController();
  final TextEditingController _crefController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();

  
  final _alturaMask =
  MaskTextInputFormatter(mask: "#.##", filter: {"#": RegExp(r'[0-9]')});
  final _pesoMask =
  MaskTextInputFormatter(mask: "##0.0", filter: {"#": RegExp(r'[0-9]')});
  final _telefoneMask = MaskTextInputFormatter(
      mask: "+## (##) #####-####", filter: {"#": RegExp(r'[0-9]')});

  
  Map<String, String> _dadosOriginais = {};

  @override
  void initState() {
    super.initState();
    _carregarDadosPersonal();
  }

  Future<void> _carregarDadosPersonal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final personalDoc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (personalDoc.exists) {
      final dados = personalDoc.data()!;
      setState(() {
        _nomeController.text = dados['nome'] ?? '';
        _sexoController.text = dados['sexo'] ?? '';
        _alturaController.text = dados['altura']?.toString() ?? '';
        _pesoController.text = dados['peso']?.toString() ?? '';
        _idiomaController.text = dados['idioma'] ?? 'PT-BR';
        _crefController.text = dados['cref'] ?? '';
        _telefoneController.text = dados['telefone'] ?? '';

        _dadosOriginais = {
          'nome': _nomeController.text,
          'sexo': _sexoController.text,
          'altura': _alturaController.text,
          'peso': _pesoController.text,
          'idioma': _idiomaController.text,
          'cref': _crefController.text,
          'telefone': _telefoneController.text,
        };
      });
    }
  }

  bool _houveAlteracao() {
    return _nomeController.text != _dadosOriginais['nome'] ||
        _sexoController.text != _dadosOriginais['sexo'] ||
        _alturaController.text != _dadosOriginais['altura'] ||
        _pesoController.text != _dadosOriginais['peso'] ||
        _idiomaController.text != _dadosOriginais['idioma'] ||
        _crefController.text != _dadosOriginais['cref'] ||
        _telefoneController.text != _dadosOriginais['telefone'];
  }

  Future<void> _salvarAlteracoes() async {
    if (!_houveAlteracao()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Nenhuma alteração para salvar."),
            backgroundColor: Colors.amber[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'nome': _nomeController.text,
      'sexo': _sexoController.text,
      'altura': _alturaController.text,
      'peso': _pesoController.text,
      'idioma': _idiomaController.text,
      'cref': _crefController.text,
      'telefone': _telefoneController.text,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Dados atualizados com sucesso!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _confirmarCancelar() async {
    if (!_houveAlteracao()) {
      Navigator.pop(context);
      return;
    }

    final sair = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancelar alterações"),
          content: const Text("Deseja sair sem salvar as alterações?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Não"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Sim",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (sair == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Dados"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _confirmarCancelar,
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _campoTexto("Nome", _nomeController,
                    obrigatorio: true, tipo: TextInputType.text),
                _campoTexto("Sexo", _sexoController,
                    obrigatorio: false, tipo: TextInputType.text),
                _campoTexto("Altura (m)", _alturaController,
                    obrigatorio: false,
                    tipo: TextInputType.number,
                    mascara: _alturaMask),
                _campoTexto("Peso (kg)", _pesoController,
                    obrigatorio: false,
                    tipo: TextInputType.number,
                    mascara: _pesoMask),
                _campoTexto("Idioma", _idiomaController,
                    obrigatorio: false, tipo: TextInputType.text),
                _campoTexto("CREF", _crefController,
                    obrigatorio: false, tipo: TextInputType.text),
                _campoTexto("Telefone", _telefoneController,
                    obrigatorio: false,
                    tipo: TextInputType.phone,
                    mascara: _telefoneMask),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirmarCancelar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancelar",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _salvarAlteracoes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Salvar Alterações",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _campoTexto(
      String label,
      TextEditingController controller, {
        bool obrigatorio = false,
        TextInputType tipo = TextInputType.text,
        MaskTextInputFormatter? mascara,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        inputFormatters: mascara != null ? [mascara] : [],
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.amber[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (valor) {
          if (obrigatorio && (valor == null || valor.trim().isEmpty)) {
            return "Preencha o campo $label";
          }
          if (tipo == TextInputType.number &&
              valor != null &&
              valor.isNotEmpty &&
              double.tryParse(valor.replaceAll(',', '.')) == null) {
            return "$label deve ser numérico";
          }
          return null;
        },
      ),
    );
  }
}
