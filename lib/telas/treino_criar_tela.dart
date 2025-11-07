import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../modelos/treino.dart';
import '../servicos/treino_service.dart';

class TreinoCriarTela extends StatefulWidget {
  const TreinoCriarTela({super.key});

  @override
  State<TreinoCriarTela> createState() => _TreinoCriarTelaState();
}

class _TreinoCriarTelaState extends State<TreinoCriarTela> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _desc = TextEditingController();
  final _freq = TextEditingController();
  Treino? _edicao;

  List<Map<String, TextEditingController>> _exerciciosControllers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Treino && _edicao == null) {
      _edicao = arg;
      _nome.text = arg.nome;
      _desc.text = arg.descricao;
      _freq.text = arg.frequencia;

      _exerciciosControllers = arg.exercicios.map((ex) {
        return {
          "nome": TextEditingController(text: ex["nome"] ?? ""),
          "series": TextEditingController(text: ex["series"] ?? ""),
          "obs": TextEditingController(text: ex["observacao"] ?? ""),
        };
      }).toList();
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _desc.dispose();
    _freq.dispose();
    for (var ex in _exerciciosControllers) {
      ex["nome"]?.dispose();
      ex["series"]?.dispose();
      ex["obs"]?.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // converter controllers em lista de maps
    final listaEx = _exerciciosControllers.map((ex) {
      return {
        "nome": ex["nome"]!.text.trim(),
        "series": ex["series"]!.text.trim(),
        "observacao": ex["obs"]!.text.trim(),
      };
    }).where((ex) => ex["nome"]!.isNotEmpty).toList();

    if (_edicao == null) {
      final novo = Treino.novo(
        nome: _nome.text.trim(),
        descricao: _desc.text.trim(),
        frequencia: _freq.text.trim(),
        exercicios: listaEx,
        personalId: uid,
      );
      final id = await TreinoService.instancia.salvarTreino(novo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Treino criado (id $id)')),
      );
    } else {
      final atualizado = _edicao!.copyWith(
        nome: _nome.text.trim(),
        descricao: _desc.text.trim(),
        frequencia: _freq.text.trim(),
        exercicios: listaEx,
        atualizadoEm: DateTime.now(),
      );
      await TreinoService.instancia.atualizarTreino(_edicao!.id, atualizado);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treino atualizado')),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.amber),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.amber),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.amber, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final editando = _edicao != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar Treino' : 'Criar Treino'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nome,
                style: const TextStyle(color: Colors.white),
                decoration: _dec('Nome do treino'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _desc,
                style: const TextStyle(color: Colors.white),
                decoration: _dec('Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _freq,
                style: const TextStyle(color: Colors.white),
                decoration: _dec('Frequência (ex.: 3x por semana)'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Informe a frequência' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                "Exercícios",
                style: TextStyle(color: Colors.amber, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Column(
                children: _exerciciosControllers.asMap().entries.map((entry) {
                  final i = entry.key;
                  final ex = entry.value;
                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: ex["nome"],
                            style: const TextStyle(color: Colors.white),
                            decoration: _dec("Nome do exercício"),
                            validator: (v) => v == null || v.isEmpty
                                ? "Informe o nome"
                                : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: ex["series"],
                            style: const TextStyle(color: Colors.white),
                            decoration: _dec("Séries (ex.: 3x12)"),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: ex["obs"],
                            style: const TextStyle(color: Colors.white),
                            decoration: _dec("Observação"),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _exerciciosControllers.removeAt(i);
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _exerciciosControllers.add({
                      "nome": TextEditingController(),
                      "series": TextEditingController(),
                      "obs": TextEditingController(),
                    });
                  });
                },
                icon: const Icon(Icons.add, color: Colors.amber),
                label: const Text("Adicionar exercício",
                    style: TextStyle(color: Colors.amber)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(editando ? 'Salvar alterações' : 'Criar treino'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
