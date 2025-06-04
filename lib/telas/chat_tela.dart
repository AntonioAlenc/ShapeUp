import 'package:flutter/material.dart';

class ChatTela extends StatefulWidget {
  const ChatTela({super.key});

  @override
  State<ChatTela> createState() => _ChatTelaState();
}

class _ChatTelaState extends State<ChatTela> {
  final TextEditingController _mensagemController = TextEditingController();
  final List<_Mensagem> _mensagens = [];

  void _enviarMensagem() {
    final texto = _mensagemController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        _mensagens.add(_Mensagem(texto: texto, isMeu: true));
        _mensagemController.clear();
      });

      // Simulação de resposta automática (opcional)
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _mensagens.add(_Mensagem(texto: 'Recebido!', isMeu: false));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Chat', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              reverse: true,
              itemCount: _mensagens.length,
              itemBuilder: (context, index) {
                final msg = _mensagens[_mensagens.length - 1 - index];
                return Align(
                  alignment: msg.isMeu ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: msg.isMeu ? Colors.amber : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg.texto,
                      style: TextStyle(
                        color: msg.isMeu ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mensagemController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _enviarMensagem(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.amber),
                  onPressed: _enviarMensagem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Mensagem {
  final String texto;
  final bool isMeu;

  _Mensagem({required this.texto, required this.isMeu});
}
