import 'package:flutter/material.dart';
import '../servicos/auth_service.dart';

class PerfilTela extends StatefulWidget {
  const PerfilTela({super.key});

  @override
  State<PerfilTela> createState() => _PerfilTelaState();
}

class _PerfilTelaState extends State<PerfilTela> {
  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaAtualCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();

  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final u = AuthService.instancia.usuario;
    _nomeCtrl.text = u?.displayName ?? '';
    _emailCtrl.text = u?.email ?? '';
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaAtualCtrl.dispose();
    _novaSenhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final auth = AuthService.instancia;
    final nome = _nomeCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final senhaAtual = _senhaAtualCtrl.text;
    final novaSenha = _novaSenhaCtrl.text;

    try {
      // Atualiza nome
      if (nome.isNotEmpty && nome != (auth.usuario?.displayName ?? '')) {
        await auth.atualizarNome(nome);
      }

      // Atualiza email
      if (email.isNotEmpty && email != (auth.usuario?.email ?? '')) {
        if (senhaAtual.isEmpty) {
          throw Exception('Informe a senha atual para alterar o e-mail.');
        }
        await auth.atualizarEmail(novoEmail: email, senhaAtual: senhaAtual);
      }

      // Atualiza senha
      if (novaSenha.isNotEmpty) {
        if (senhaAtual.isEmpty) {
          throw Exception('Informe a senha atual para alterar a senha.');
        }
        await auth.atualizarSenha(
          senhaAtual: senhaAtual,
          novaSenha: novaSenha,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 36,
                child: Icon(Icons.person, size: 36),
              ),
              const SizedBox(height: 16),

              // Nome
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe seu nome'
                    : null,
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.mail_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _senhaAtualCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha atual (obrigatória para alterar e-mail/senha)',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _novaSenhaCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova senha (opcional)',
                  prefixIcon: Icon(Icons.lock_reset),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: const Icon(Icons.save_outlined),
                  label: _salvando
                      ? const Text('Salvando...')
                      : const Text('Salvar alterações'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
