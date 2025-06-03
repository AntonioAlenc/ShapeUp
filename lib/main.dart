import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'telas/carregamento_tela.dart';
import 'telas/login_tela.dart';
import 'telas/recuperacao_senha_tela.dart';
import 'telas/cadastro_tela.dart';
import 'telas/menu_aluno_tela.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShapeUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const CarregamentoTela(),
        '/login': (context) => const LoginTela(),
        '/recuperacao': (context) => const RecuperacaoSenhaTela(),
        '/cadastro': (context) => const CadastroTela(),
        '/menu-aluno': (context) => const MenuAlunoTela(),
      },
    );
  }
}
